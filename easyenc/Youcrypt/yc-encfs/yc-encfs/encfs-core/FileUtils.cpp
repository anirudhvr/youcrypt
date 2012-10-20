/*****************************************************************************
 * Author:   Valient Gough <vgough@pobox.com>
 *
 *****************************************************************************
 * Copyright (c) 2004, Valient Gough
 * 
 * This program is free software; you can distribute it and/or modify it under 
 * the terms of the GNU General Public License (GPL), as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 */

// defines needed for RedHat 7.3...
#ifdef linux
#define _XOPEN_SOURCE 500 // make sure pwrite() is pulled in
#endif
#define _BSD_SOURCE // pick up setenv on RH7.3

#include "encfs.h"
#include "config.h"

#include "readpassphrase.h"
#include "autosprintf.h"

#include "FileUtils.h"
#include "ConfigReader.h"
#include "FSConfig.h"

#include "DirNode.h"
#include "Cipher.h"
#include "StreamNameIO.h"
#include "BlockNameIO.h"
#include "NullNameIO.h"
#include "YCNameIO.h"
#include "Context.h"

#include <rlog/rlog.h>
#include <rlog/Error.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <unistd.h>
#include <cctype>
#include <cstdio>
#include <cstdlib>
#include <cerrno>
#include <cstring>

#include <iostream>
#include <sstream>

#include "i18n.h"

#include <boost/version.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/archive/xml_iarchive.hpp>
#include <boost/archive/xml_oarchive.hpp>
#include <boost/serialization/split_free.hpp>
#include <boost/serialization/vector.hpp>
#include <boost/serialization/binary_object.hpp>
#include <boost/serialization/string.hpp>

// disable rlog section grouping for this file.. seems to cause problems
#undef RLOG_SECTION
#define RLOG_SECTION

using namespace rel;
using namespace rlog;
using namespace std;
using namespace gnu;
namespace fs = boost::filesystem;
namespace serial = boost::serialization;

static const int DefaultBlockSize = 1024;
// The maximum length of text passwords.  If longer are needed,
// use the extpass option, as extpass can return arbitrary length binary data.
static const int MaxPassBuf = 512;

static const int NormalKDFDuration = 500; // 1/2 a second
static const int ParanoiaKDFDuration = 3000; // 3 seconds

// environment variable names for values encfs stores in the environment when
// calling an external password program.
static const char ENCFS_ENV_ROOTDIR[] = "encfs_root";
static const char ENCFS_ENV_STDOUT[] = "encfs_stdout";
static const char ENCFS_ENV_STDERR[] = "encfs_stderr";


//static int V5SubVersion = 20040518;
//static int V5SubVersion = 20040621; // add external IV chaining
static int V5SubVersion = 20040813; // fix MACFileIO block size issues
static int V5SubVersionDefault = 0;

// 20080813 was really made on 20080413 -- typo on date..
//const int V6SubVersion = 20080813; // switch to v6/XML, add allowHoles option
//const int V6SubVersion = 20080816; // add salt and iteration count
const int V6SubVersion = 20100713; // add version field for boost 1.42+

const int YCSubVersion = 0;  // Initial YC XML (just EncFS V6).

struct ConfigInfo ConfigFileMapping[] = {
    {".youcryptfs.xml", Config_YC, "YCFS_CONFIG", readV6Config, writeV6Config, 
     YCSubVersion, YCSubVersion},
    {".encfs6.xml", Config_V6, "ENCFS6_CONFIG", readV6Config, writeV6Config, 
	V6SubVersion, 0 },
    // backward compatible support for older versions
    {".encfs5", Config_V5, "ENCFS5_CONFIG", readV5Config, writeV5Config, 
	V5SubVersion, V5SubVersionDefault },
    {".encfs4", Config_V4, NULL, readV4Config, writeV4Config, 0, 0 },
    // no longer support earlier versions
    {".encfs3", Config_V3, NULL, NULL, NULL, 0, 0 },
    {".encfs2", Config_Prehistoric, NULL, NULL, NULL, 0, 0 },
    {".encfs", Config_Prehistoric, NULL, NULL, NULL, 0, 0 },
    {NULL,Config_None, NULL, NULL, NULL, 0, 0}};


#include "boost-versioning.h"

// define serialization helpers
namespace boost
{
    namespace serialization
    {

        template<class Elem, class ElemCast>
        class ArchVector {
            friend class access;
            vector<Elem> &_v;
            template<class A>
            void serialize(A &ar, const unsigned int version)  {
                unsigned int count = _v.size();
                ar & make_nvp("count", count);
                _v.resize(count);
                for (auto beg=_v.begin(), en=_v.end();
                     beg != en; beg++) {
                    ElemCast cst(*beg);
                    ar & make_nvp(ElemCast::className(), 
                                  cst);
                }
            }

        public:
            ArchVector(std::vector<Elem> &v): _v(v) {}
        };

        class EncKey {
            vector<unsigned char> &key;
        public:
            static const char *className() { return "userKey"; }
            EncKey(vector<unsigned char> &k): key(k){}
            
            template<class A>
            void serialize(A &ar, const unsigned int)  {
                unsigned int count = key.size();
                ar & make_nvp("keyDataSize", count);
                key.resize(count);
                ar & make_nvp("keyData", serial::make_binary_object(
                                  const_cast<unsigned char *>(&key.front()), 
                                  key.size()));
            }
        };

        class WhiteList {
            string &filename;
        public:
            static const char *className() { return "whiteList"; }
            WhiteList(string &s): filename(s) {}
            template <class A>
            void serialize(A &ar, const unsigned int) {
                ar & make_nvp("filename", filename);
            }
        };
        typedef ArchVector<std::vector<unsigned char>, EncKey> Keys;
        typedef ArchVector<std::string, WhiteList> WhiteLists;

        template<class T, class U,
                 const char *elemName, const char *sizeName>
        class SerializeVectorAs {
            vector<T> &v;

            friend class access;
            template <class A>
            void serialize (A &ar, SerializeVectorAs &s, const unsigned int){
                unsigned int size = v.size();
                ar & make_nvp(sizeName, size);
                v.resize(size);
                for (typename vector<T>::iterator beg=v.begin(), en=v.end(); 
                     beg != en; ++beg)
                    ar & make_nvp(elemName, static_cast<U &>(*beg));
            }
        };
        // typedef SerializeVectorAs<std::vector<unsigned char>, 
        //                           EncKey,     "userKey", "count"> AKeys;


        template<class Archive>
        void serialize(Archive &ar, EncFSConfig &cfg, 
                unsigned int version)
        {
            (void)version;
            // version 20 (aka 20100613)
            ar & make_nvp("version", cfg.subVersion);

            ar & make_nvp("creator", cfg.creator);
            ar & make_nvp("cipherAlg", cfg.cipherIface);
            ar & make_nvp("nameAlg", cfg.nameIface);
            ar & make_nvp("keySize", cfg.keySize);
            ar & make_nvp("blockSize", cfg.blockSize);
            ar & make_nvp("uniqueIV", cfg.uniqueIV);
            ar & make_nvp("chainedNameIV", cfg.chainedNameIV);
            ar & make_nvp("externalIVChaining", cfg.externalIVChaining);
            ar & make_nvp("blockMACBytes", cfg.blockMACBytes);
            ar & make_nvp("blockMACRandBytes", cfg.blockMACRandBytes);
            ar & make_nvp("allowHoles", cfg.allowHoles);

            int encodedSize = cfg.keyData.size();
            ar & make_nvp("encodedKeySize", encodedSize);
            cfg.keyData.resize(encodedSize);
            ar & make_nvp("encodedKeyData",
                          serial::make_binary_object(
                              cfg.getKeyData(), encodedSize));

            /* easyenc */
            ar & make_nvp("users", cfg.easyencNumUsers);
            Keys keys(cfg.easyencKeys);
            ar & make_nvp("userKeys", keys);
            
            /* Rajsekar: easyenc whitelist */
            WhiteLists whiteList(*cfg.ignoreList);
            ar & make_nvp("ignoreList", whiteList);
			       

            // version 20080816
            int size = cfg.salt.size();
            ar & make_nvp("saltLen", size);
            cfg.salt.resize(size);
            ar & make_nvp("saltData",
                    serial::make_binary_object(cfg.getSaltData(), size));
            ar & make_nvp("kdfIterations", cfg.kdfIterations);
            ar & make_nvp("desiredKDFDuration", cfg.desiredKDFDuration);
        }



        template<class Archive>
        void serialize(Archive &ar, Interface &i, const unsigned int version)
        {
            (void)version;
            ar & make_nvp("name", i.name());
            ar & make_nvp("major", i.current());
            ar & make_nvp("minor", i.revision());
        }
    }
}

EncFS_Root::EncFS_Root()
{
}

EncFS_Root::~EncFS_Root()
{
}


bool fileExists( const char * fileName )
{
    struct stat buf;
    if(!lstat( fileName, &buf ))
    {
	return true;
    } else
    {
	// XXX show perror?
	return false;
    }
}

bool isDirectory( const char *fileName )
{
    struct stat buf;
    if( !lstat( fileName, &buf ))
    {
	return S_ISDIR( buf.st_mode );
    } else
    {
	return false;
    }
}

bool isAbsolutePath( const char *fileName )
{
    if(fileName && fileName[0] != '\0' && fileName[0] == '/')
	return true;
    else
	return false;
}

const char *lastPathElement( const char *name )
{
    const char *loc = strrchr( name, '/' );
    return loc ? loc + 1 : name;
}

std::string parentDirectory( const std::string &path )
{
    size_t last = path.find_last_of( '/' );
    if(last == string::npos)
	return string("");
    else
	return path.substr(0, last);
}

bool userAllowMkdir( const char *path, mode_t mode )
{
    // TODO: can we internationalize the y/n names?  Seems strange to prompt in
    // their own language but then have to respond 'y' or 'n'.
    // xgroup(setup)
    cerr << autosprintf( _("The directory \"%s\" does not exist. Should it be created? (y,n) "), path );
    char answer[10];
    char *res = fgets( answer, sizeof(answer), stdin );

    if(res != 0 && toupper(answer[0]) == 'Y')
    {
	int result = mkdir( path, mode );
	if(result < 0)
	{
	    perror( _("Unable to create directory: ") );
	    return false;
	} else
	    return true;
    } else
    {
	// Directory not created, by user request
	cerr << _("Directory not created.") << "\n";
	return false;
    }
}

ConfigType readConfig_load( ConfigInfo *nm, const char *path, 
	const boost::shared_ptr<EncFSConfig> &config )
{
    if( nm->loadFunc )
    {
        try
        {
            if( (*nm->loadFunc)( path, config, nm ))
            {
                config->cfgType = nm->type;
                return nm->type;
            }
        } catch( rlog::Error & err )
        {
            err.log( _RLWarningChannel );
        }
        
        rError( _("Found config file %s, but failed to load"), path);
        return Config_None;
    } else
    {
        // No load function - must be an unsupported type..
        config->cfgType = nm->type;
        return nm->type;
    }
}

ConfigType readConfig( const string &rootDir, 
        const boost::shared_ptr<EncFSConfig> &config )
{
    ConfigInfo *nm = ConfigFileMapping;
    while(nm->fileName)
    {
	// allow environment variable to override default config path
	if( nm->environmentOverride != NULL )
	{
	    char *envFile = getenv( nm->environmentOverride );
	    if( envFile != NULL )
		return readConfig_load( nm, envFile, config );
	}
	// the standard place to look is in the root directory
	string path = rootDir + nm->fileName;
	if( fileExists( path.c_str() ) )
	    return readConfig_load( nm, path.c_str(), config);

	++nm;
    }

    return Config_None;
}

bool readV6Config( const char *configFile, 
        const boost::shared_ptr<EncFSConfig> &config,
	ConfigInfo *info)
{
    (void)info;

    fs::ifstream st( configFile );
    if(st.is_open())
    {
        try
        {
            boost::archive::xml_iarchive ia( st );
            ia >> BOOST_SERIALIZATION_NVP( *config );
        
            return true;
        } catch(boost::archive::archive_exception &e)
        {
            rError("Archive exception: %s", e.what());
            return false;
        }
    } else
    {
        rInfo("Failed to load config file %s", configFile);
        return false;
    }
}

bool readV5Config( const char *configFile, 
        const boost::shared_ptr<EncFSConfig> &config,
	ConfigInfo *info)
{
    bool ok = false;

    // use Config to parse the file and query it..
    ConfigReader cfgRdr;
    if(cfgRdr.load( configFile ))
    {
	try
	{
	    config->subVersion = cfgRdr["subVersion"].readInt( 
		    info->defaultSubVersion );
	    if(config->subVersion > info->currentSubVersion)
	    {
		/* config file specifies a version outside our supported
		 range..   */
		rWarning(_("Config subversion %i found, but this version of"
			" encfs only supports up to version %i."),
			config->subVersion, info->currentSubVersion);
		return false;
	    }
	    if( config->subVersion < 20040813 )
	    {
		rError(_("This version of EncFS doesn't support "
			    "filesystems created before 2004-08-13"));
		return false;
	    }

	    cfgRdr["creator"] >> config->creator;
	    cfgRdr["cipher"] >> config->cipherIface;
	    cfgRdr["naming"] >> config->nameIface;
	    cfgRdr["keySize"] >> config->keySize;
	    cfgRdr["blockSize"] >> config->blockSize;

            string data;
	    cfgRdr["keyData"] >> data;
            config->assignKeyData(data);
	    config->uniqueIV = cfgRdr["uniqueIV"].readBool( false );
	    config->chainedNameIV = cfgRdr["chainedIV"].readBool( false );
	    config->externalIVChaining = cfgRdr["externalIV"].readBool( false );
	    config->blockMACBytes = cfgRdr["blockMACBytes"].readInt(0);
	    config->blockMACRandBytes = 
		cfgRdr["blockMACRandBytes"].readInt(0);

	    ok = true;
	} catch( rlog::Error &err)
	{
	    err.log( _RLWarningChannel );
	    rDebug("Error parsing data in config file %s", configFile);
	    ok = false;
	}
    }

    return ok;
}

bool readV4Config( const char *configFile, 
        const boost::shared_ptr<EncFSConfig> &config,
	ConfigInfo *info)
{
    bool ok = false;

    // use Config to parse the file and query it..
    ConfigReader cfgRdr;
    if(cfgRdr.load( configFile ))
    {
	try
	{
	    cfgRdr["cipher"] >> config->cipherIface;
	    cfgRdr["keySize"] >> config->keySize;
	    cfgRdr["blockSize"] >> config->blockSize;
            string data;
	    cfgRdr["keyData"] >> data;
            config->assignKeyData(data);

	    // fill in default for V4
	    config->nameIface = Interface("nameio/stream", 1, 0, 0);
	    config->creator = "EncFS 1.0.x";
	    config->subVersion = info->defaultSubVersion;
	    config->blockMACBytes = 0;
	    config->blockMACRandBytes = 0;
	    config->uniqueIV = false;
	    config->externalIVChaining = false;
	    config->chainedNameIV = false;

	    ok = true;
	} catch( rlog::Error &err)
	{
	    err.log( _RLWarningChannel );
	    rDebug("Error parsing config file %s", configFile);
	    ok = false;
	}
    }

    return ok;
}

bool saveConfig( ConfigType type, const string &rootDir,
	const boost::shared_ptr<EncFSConfig> &config )
{
    bool ok = false;

    ConfigInfo *nm = ConfigFileMapping;
    while(nm->fileName)
    {
	if( nm->type == type && nm->saveFunc )
	{
	    string path = rootDir + nm->fileName;
	    if( nm->environmentOverride != NULL )
	    {
		// use environment file if specified..
		const char *envFile = getenv( nm->environmentOverride );
		if( envFile != NULL )
		    path.assign( envFile );
	    }

	    try
	    {
		ok = (*nm->saveFunc)( path.c_str(), config );
	    } catch( rlog::Error &err )
	    {
		err.log( _RLWarningChannel );
		ok = false;
	    }
	    break;
	}
	++nm;
    }

    return ok;
}

bool writeV6Config( const char *configFile, 
        const boost::shared_ptr<EncFSConfig> &config )
{
    fs::ofstream st( configFile );
    if(!st.is_open())
        return false;

    st << *config;

    return true;
}

std::ostream &operator << (std::ostream &st, const EncFSConfig &cfg)
{
    boost::archive::xml_oarchive oa(st);
    oa << BOOST_SERIALIZATION_NVP( cfg );

    return st;
}

std::istream &operator >> (std::istream &st, EncFSConfig &cfg)
{
    boost::archive::xml_iarchive ia(st);
    ia >> BOOST_SERIALIZATION_NVP( cfg );

    return st;
}

bool writeV5Config( const char *configFile, 
        const boost::shared_ptr<EncFSConfig> &config )
{
    ConfigReader cfg;

    cfg["creator"] << config->creator;
    cfg["subVersion"] << config->subVersion;
    cfg["cipher"] << config->cipherIface;
    cfg["naming"] << config->nameIface;
    cfg["keySize"] << config->keySize;
    cfg["blockSize"] << config->blockSize;
    string key;
    key.assign((char *)config->getKeyData(), config->keyData.size());
    cfg["keyData"] << key;
    cfg["blockMACBytes"] << config->blockMACBytes;
    cfg["blockMACRandBytes"] << config->blockMACRandBytes;
    cfg["uniqueIV"] << config->uniqueIV;
    cfg["chainedIV"] << config->chainedNameIV;
    cfg["externalIV"] << config->externalIVChaining;

    return cfg.save( configFile );
}

bool writeV4Config( const char *configFile, 
        const boost::shared_ptr<EncFSConfig> &config )
{
    ConfigReader cfg;

    cfg["cipher"] << config->cipherIface;
    cfg["keySize"] << config->keySize;
    cfg["blockSize"] << config->blockSize;
    string key;
    key.assign((char *)config->getKeyData(), config->keyData.size());
    cfg["keyData"] << key;

    return cfg.save( configFile );
}

Cipher::CipherAlgorithm findCipherAlgorithm(const char *name,
	int keySize )
{
    Cipher::AlgorithmList algorithms = Cipher::GetAlgorithmList();
    Cipher::AlgorithmList::const_iterator it;
    for(it = algorithms.begin(); it != algorithms.end(); ++it)
    {
	if( !strcmp( name, it->name.c_str() )
		&& it->keyLength.allowed( keySize ))
	{
	    return *it;
	}
    }

    Cipher::CipherAlgorithm result;
    return result;
}

static
Cipher::CipherAlgorithm selectCipherAlgorithm()
{
    for(;;)
    {
	// figure out what cipher they want to use..
	// xgroup(setup)
	cout << _("The following cipher algorithms are available:") << "\n";
	Cipher::AlgorithmList algorithms = Cipher::GetAlgorithmList();
	Cipher::AlgorithmList::const_iterator it;
	int optNum = 1;
	for(it = algorithms.begin(); it != algorithms.end(); ++it, ++optNum)
	{
	    cout << optNum << ". " << it->name
		<< " : " << gettext(it->description.c_str()) << "\n";
	    if(it->keyLength.min() == it->keyLength.max())
	    {
		// shown after algorithm name and description.
		// xgroup(setup)
		cout << autosprintf(_(" -- key length %i bits")
			, it->keyLength.min()) << "\n";
	    } else
	    {
		cout << autosprintf(
			// shown after algorithm name and description.
			// xgroup(setup)
			_(" -- Supports key lengths of %i to %i bits"),
			it->keyLength.min(), it->keyLength.max()) << "\n";
	    }

	    if(it->blockSize.min() == it->blockSize.max())
	    {
		cout << autosprintf(
			// shown after algorithm name and description.
			// xgroup(setup)
			_(" -- block size %i bytes"), it->blockSize.min()) 
	    	    << "\n";
	    } else
	    {
		cout << autosprintf(
			// shown after algorithm name and description.
			// xgroup(setup)
			_(" -- Supports block sizes of %i to %i bytes"),
			it->blockSize.min(), it->blockSize.max()) << "\n";
	    }
	}

	// xgroup(setup)
	cout << "\n" << _("Enter the number corresponding to your choice: ");
	char answer[10];
	char *res = fgets( answer, sizeof(answer), stdin );
	int cipherNum = (res == 0 ? 0 : atoi( answer ));
	cout << "\n";

	if( cipherNum < 1 || cipherNum > (int)algorithms.size() )
	{
	    cerr << _("Invalid selection.") << "\n";
	    continue;
	}

	it = algorithms.begin();
	while(--cipherNum) // numbering starts at 1
	    ++it;

	Cipher::CipherAlgorithm alg = *it;
       	
	// xgroup(setup)
	cout << autosprintf(_("Selected algorithm \"%s\""), alg.name.c_str()) 
	    << "\n\n";

	return alg;
    }
}

static
Interface selectNameCoding()
{
    for(;;)
    {
	// figure out what cipher they want to use..
	// xgroup(setup)
	cout << _("The following filename encoding algorithms are available:")
		<< "\n";
	NameIO::AlgorithmList algorithms = NameIO::GetAlgorithmList();
	NameIO::AlgorithmList::const_iterator it;
	int optNum = 1;
	for(it = algorithms.begin(); it != algorithms.end(); ++it, ++optNum)
	{
	    cout << optNum << ". " << it->name
		<< " : " << gettext(it->description.c_str()) << "\n";
	}

	// xgroup(setup)
	cout << "\n" << _("Enter the number corresponding to your choice: ");
	char answer[10];
	char *res = fgets( answer, sizeof(answer), stdin );
	int algNum = (res == 0 ? 0 : atoi( answer ));
	cout << "\n";

	if( algNum < 1 || algNum > (int)algorithms.size() )
	{
	    cerr << _("Invalid selection.") << "\n";
	    continue;
	}

	it = algorithms.begin();
	while(--algNum) // numbering starts at 1
	    ++it;

	// xgroup(setup)
	cout << autosprintf(_("Selected algorithm \"%s\""), it->name.c_str()) 
	    << "\"\n\n";

	return it->iface;
    }
}

static
int selectKeySize( const Cipher::CipherAlgorithm &alg )
{
    if(alg.keyLength.min() == alg.keyLength.max())
    {
	cout << autosprintf(_("Using key size of %i bits"), 
		alg.keyLength.min()) << "\n";
	return alg.keyLength.min();
    }

    cout << autosprintf(
	// xgroup(setup)
	_("Please select a key size in bits.  The cipher you have chosen\n"
	  "supports sizes from %i to %i bits in increments of %i bits.\n"
	  "For example: "), alg.keyLength.min(), alg.keyLength.max(), 
	  alg.keyLength.inc()) << "\n";

    int numAvail = (alg.keyLength.max() - alg.keyLength.min()) 
	/ alg.keyLength.inc();

    if(numAvail < 5)
    {
	// show them all
	for(int i=0; i<=numAvail; ++i)
	{
	    if(i) 
		cout << ", ";
	    cout << alg.keyLength.min() + i * alg.keyLength.inc();
	}
    } else
    {
	// partial
	for(int i=0; i<3; ++i)
	{
	    if(i) 
		cout << ", ";
	    cout << alg.keyLength.min() + i * alg.keyLength.inc();
	}
	cout << " ... " << alg.keyLength.max() - alg.keyLength.inc();
	cout << ", " << alg.keyLength.max();
    }
    // xgroup(setup)
    cout << "\n" << _("Selected key size: ");

    char answer[10];
    char *res = fgets( answer, sizeof(answer), stdin );
    int keySize = (res == 0 ? 0 : atoi( answer ));
    cout << "\n";

    keySize = alg.keyLength.closest( keySize );

    // xgroup(setup)
    cout << autosprintf(_("Using key size of %i bits"), keySize) << "\n\n";

    return keySize;
}

static
int selectBlockSize( const Cipher::CipherAlgorithm &alg )
{
    if(alg.blockSize.min() == alg.blockSize.max())
    {
	cout << autosprintf(
		// xgroup(setup)
		_("Using filesystem block size of %i bytes"),
		alg.blockSize.min()) << "\n";
	return alg.blockSize.min();
    }

    cout << autosprintf(
	    // xgroup(setup)
	    _("Select a block size in bytes.  The cipher you have chosen\n"
	      "supports sizes from %i to %i bytes in increments of %i.\n"
	      "Or just hit enter for the default (%i bytes)\n"),
	      alg.blockSize.min(), alg.blockSize.max(), alg.blockSize.inc(),
	      DefaultBlockSize);

    // xgroup(setup)
    cout << "\n" << _("filesystem block size: ");
	
    int blockSize = DefaultBlockSize;
    char answer[10];
    char *res = fgets( answer, sizeof(answer), stdin );
    cout << "\n";

    if( res != 0 && atoi( answer )  >= alg.blockSize.min() )
	blockSize = atoi( answer );

    blockSize = alg.blockSize.closest( blockSize );

    // xgroup(setup)
    cout << autosprintf(_("Using filesystem block size of %i bytes"), 
	    blockSize) << "\n\n";

    return blockSize;
}

static
bool boolDefaultNo(const char *prompt)
{
    cout << prompt << "\n";
    cout << _("The default here is No.\n"
              "Any response that does not begin with 'y' will mean No: ");

    char answer[10];
    char *res = fgets( answer, sizeof(answer), stdin );
    cout << "\n";

    if(res != 0 && tolower(answer[0]) == 'y')
	return true;
    else
	return false;
}

static 
void selectBlockMAC(int *macBytes, int *macRandBytes)
{
    // xgroup(setup)
    bool addMAC = boolDefaultNo(
            _("Enable block authentication code headers\n"
	"on every block in a file?  This adds about 12 bytes per block\n"
	"to the storage requirements for a file, and significantly affects\n"
	"performance but it also means [almost] any modifications or errors\n"
	"within a block will be caught and will cause a read error."));

    if(addMAC)
	*macBytes = 8;
    else
	*macBytes = 0;

    // xgroup(setup)
    cout << _("Add random bytes to each block header?\n"
        "This adds a performance penalty, but ensures that blocks\n"
        "have different authentication codes.  Note that you can\n"
        "have the same benefits by enabling per-file initialization\n"
        "vectors, which does not come with as great of performance\n"
        "penalty. \n"
        "Select a number of bytes, from 0 (no random bytes) to 8: ");

    char answer[10];
    int randSize = 0;
    char *res = fgets( answer, sizeof(answer), stdin );
    cout << "\n";

    randSize = (res == 0 ? 0 : atoi( answer ));
    if(randSize < 0)
        randSize = 0;
    if(randSize > 8)
        randSize = 8;

    *macRandBytes = randSize;
}

static
bool boolDefaultYes(const char *prompt)
{
    cout << prompt << "\n";
    cout << _("The default here is Yes.\n"
              "Any response that does not begin with 'n' will mean Yes: ");

    char answer[10];
    char *res = fgets( answer, sizeof(answer), stdin );
    cout << "\n";

    if(res != 0 && tolower(answer[0]) == 'n')
	return false;
    else
	return true;
}

static 
bool selectUniqueIV()
{
    // xgroup(setup)
    return boolDefaultYes(
            _("Enable per-file initialization vectors?\n"
	"This adds about 8 bytes per file to the storage requirements.\n"
	"It should not affect performance except possibly with applications\n"
	"which rely on block-aligned file io for performance."));
}

static 
bool selectChainedIV()
{
    // xgroup(setup)
    return boolDefaultYes(
            _("Enable filename initialization vector chaining?\n"
	"This makes filename encoding dependent on the complete path, \n"
	"rather then encoding each path element individually."));
}

static 
bool selectExternalChainedIV()
{
    // xgroup(setup)
    return boolDefaultNo(
            _("Enable filename to IV header chaining?\n"
	"This makes file data encoding dependent on the complete file path.\n"
	"If a file is renamed, it will not decode sucessfully unless it\n"
	"was renamed by encfs with the proper key.\n"
	"If this option is enabled, then hard links will not be supported\n"
	"in the filesystem."));
}

static 
bool selectZeroBlockPassThrough()
{
    // xgroup(setup)
    return boolDefaultYes(
            _("Enable file-hole pass-through?\n"
	"This avoids writing encrypted blocks when file holes are created."));
}

RootPtr createV6Config( EncFS_Context *ctx,
        const shared_ptr<EncFS_Opts> &opts )
{
    const std::string rootDir = opts->rootDir;
    bool enableIdleTracking = opts->idleTracking;
    bool forceDecode = opts->forceDecode;
    const std::string passwordProgram = opts->passwordProgram;
    bool useStdin = opts->useStdin;
    bool reverseEncryption = opts->reverseEncryption;
    ConfigMode configMode = opts->configMode;

    RootPtr rootInfo;
    char numusers_s[10] = {0};
    int numusers=0;

    if (opts->no_interactive_configuration) { /* easyenc */
        rAssert(opts->num_users > 0 &&
                opts->passphrases.size() > 0);
        //configMode = Config_Paranoia; /* takes too long to mount */
        configMode = Config_Standard;
        numusers = opts->num_users;
    }

    // creating new volume key.. should check that is what the user is
    // expecting...
    // xgroup(setup)
    if (!opts->no_interactive_configuration) {
        cout << _("Creating new encrypted volume.") << endl;
    }

    char answer[10] = {0};
    if(configMode == Config_Prompt)
    {
        // xgroup(setup)
        cout << _("Please choose from one of the following options:\n"
                " enter \"x\" for expert configuration mode,\n"
                " enter \"p\" for pre-configured paranoia mode,\n"
                " anything else, or an empty line will select standard mode.\n"
                "?> ");

        char *res = fgets( answer, sizeof(answer), stdin );
        (void)res;
        cout << "\n";

        /* for easyenc */
        cout << _("Choose the number of users who will be using this\n"
                "folder, if it is going to be shared (default: 1)\n" 
                "?> ");

        res = fgets( numusers_s, sizeof(numusers_s), stdin );
        (void)res;
        stringstream sst;
        sst << numusers_s;
        if (!(sst >> numusers)) {
            cerr << _("Error parsing number of users; defaulting to 1\n");
            numusers = 1;
        }
        cout << "\n";
    }

    int keySize = 0;
    int blockSize = 0;
    Cipher::CipherAlgorithm alg;
    Interface nameIOIface;
    int blockMACBytes = 0;
    int blockMACRandBytes = 0;
    bool uniqueIV = false;
    bool chainedIV = false;
    bool externalIV = false;
    bool allowHoles = true;
    long desiredKDFDuration = NormalKDFDuration;

    if (reverseEncryption)
    {
        uniqueIV = false;
        chainedIV = false;
        externalIV = false;
        blockMACBytes = 0;
        blockMACRandBytes = 0;
    }

    if(configMode == Config_Paranoia || answer[0] == 'p')
    {
        if (reverseEncryption)
        {
            rError(_("Paranoia configuration not supported for --reverse"));
            return rootInfo;
        }

        // xgroup(setup)
        if (!opts->no_interactive_configuration) 
            cout << _("Paranoia configuration selected.") << "\n";
        // look for AES with 256 bit key..
        // Use block filename encryption mode.
        // Enable per-block HMAC headers at substantial performance penalty..
        // Enable per-file initialization vector headers.
        // Enable filename initialization vector chaning
        keySize = 256;
        blockSize = DefaultBlockSize;
        alg = findCipherAlgorithm("AES", keySize);
	if (opts->mangleFilename)
	  nameIOIface = BlockNameIO::CurrentInterface();
	else
	  nameIOIface = YCNameIO::CurrentInterface();
        blockMACBytes = 8;
        blockMACRandBytes = 0; // using uniqueIV, so this isn't necessary
        uniqueIV = true;
        chainedIV = true;
        externalIV = true;
        desiredKDFDuration = ParanoiaKDFDuration;
    } else if(configMode == Config_Standard || answer[0] != 'x')
    {
        // xgroup(setup)
        if (!opts->no_interactive_configuration) 
            cout << _("Standard configuration selected.") << "\n";
        // AES w/ 192 bit key, block name encoding, per-file initialization
        // vectors are all standard.
        keySize = 192;
        blockSize = DefaultBlockSize;
        alg = findCipherAlgorithm("AES", keySize);
        blockMACBytes = 0;
        externalIV = false;
	if (opts->mangleFilename)
	  nameIOIface = BlockNameIO::CurrentInterface();
	else
	  nameIOIface = YCNameIO::CurrentInterface();

        if (reverseEncryption)
        {
            cout << _("--reverse specified, not using unique/chained IV") 
                << "\n";
        } else
        {
            uniqueIV = true;
            chainedIV = true;
        }
    }

    if(answer[0] == 'x' || alg.name.empty())
    {
        if(answer[0] != 'x')
        {
            // xgroup(setup)
            cout << _("Sorry, unable to locate cipher for predefined "
                    "configuration...\n"
                    "Falling through to Manual configuration mode.");
        } else
        {
            // xgroup(setup)
            cout << _("Manual configuration mode selected.");
        }
        cout << endl;

        // query user for settings..
        alg = selectCipherAlgorithm();
        keySize = selectKeySize( alg );
        blockSize = selectBlockSize( alg );
        nameIOIface = selectNameCoding();
        if (reverseEncryption)
        {
            cout << _("--reverse specified, not using unique/chained IV") << "\n";
        } else
        {
            chainedIV = selectChainedIV();
            uniqueIV = selectUniqueIV();
            if(chainedIV && uniqueIV)
                externalIV = selectExternalChainedIV();
            else
            {
                // xgroup(setup)
                cout << _("External chained IV disabled, as both 'IV chaining'\n"
                        "and 'unique IV' features are required for this option.") 
                    << "\n";
                externalIV = false;
            }
            selectBlockMAC(&blockMACBytes, &blockMACRandBytes);
            allowHoles = selectZeroBlockPassThrough();
        }
    }

    shared_ptr<Cipher> cipher = Cipher::New( alg.name, keySize );
    if(!cipher)
    {
        rError(_("Unable to instanciate cipher %s, key size %i, block size %i"),
                alg.name.c_str(), keySize, blockSize);
        return rootInfo;
    } else
    {
        rDebug("Using cipher %s, key size %i, block size %i",
                alg.name.c_str(), keySize, blockSize);
    }

    shared_ptr<EncFSConfig> config( new EncFSConfig );

    config->cfgType = Config_YC;
    config->cipherIface = cipher->interface();
    config->keySize = keySize;
    config->blockSize = blockSize;
    config->nameIface = nameIOIface;
    config->creator = "EncFS " VERSION;
    config->subVersion = V6SubVersion;
    config->blockMACBytes = blockMACBytes;
    config->blockMACRandBytes = blockMACRandBytes;
    config->uniqueIV = uniqueIV;
    config->chainedNameIV = chainedIV;
    config->externalIVChaining = externalIV;
    config->allowHoles = allowHoles;

    config->salt.clear();
    config->kdfIterations = 0; // filled in by keying function
    config->desiredKDFDuration = desiredKDFDuration;

    // xgroup(setup)
    if (!opts->no_interactive_configuration) {
        cout << _("Configuration finished.  The filesystem to be created has\n"
                "the following properties:") << endl;
        showFSInfo( config );
    }

    if( config->externalIVChaining &&
            !opts->no_interactive_configuration)
    {
        cout << 
            _("-------------------------- WARNING --------------------------\n")
            <<
            _("The external initialization-vector chaining option has been\n"
                    "enabled.  This option disables the use of hard links on the\n"
                    "filesystem. Without hard links, some programs may not work.\n"
                    "The programs 'mutt' and 'procmail' are known to fail.  For\n"
                    "more information, please see the encfs mailing list.\n"
                    "If you would like to choose another configuration setting,\n"
                    "please press CTRL-C now to abort and start over.") << endl;
        cout << endl;
    }

    if (!opts->no_interactive_configuration) {
        // xgroup(setup)
        cout << _("Now you will need to enter a password for your filesystem.\n"
                "You will need to remember this password, as there is absolutely\n"
                "no recovery mechanism.  However, the password can be changed\n"
                "later using encfsctl.\n\n");
    }

    int encodedKeySize = cipher->encodedKeySize();
    unsigned char *encodedKey = new unsigned char[ encodedKeySize ];

    CipherKey volumeKey = cipher->newRandomKey();

    /* easyenc - get first user key (existing code) */
    config->easyencNumUsers = numusers;
    config->easyencKeys.resize(numusers);

    // get user key and use it to encode volume key
    CipherKey userKey;

    if (!opts->no_interactive_configuration) {
        cout << autosprintf("You chose %d users. Enter passphrase for user 1\n", numusers);

        rDebug( "useStdin: %i", useStdin );
        if(useStdin)
            userKey = config->getUserKey( useStdin );
        else if(!passwordProgram.empty())
            userKey = config->getUserKey( passwordProgram, rootDir );
        else
            userKey = config->getNewUserKey();
    } else {
        userKey =
            config->createUserKeyFromPassphrase(opts->passphrases[0]);
    }

    cipher->writeKey( volumeKey, encodedKey, userKey );
    config->assignKeyData(encodedKey, encodedKeySize);

    /* easyenc set and encodedKeys */ 
    config->easyencKeys[0].assign(encodedKey, encodedKey+encodedKeySize);

    userKey.reset();
    delete[] encodedKey;

    /* easyenc - get user keys for remaining users */
    /* get rest of user keys */
    for (int i = 1; i < numusers; ++i) {
        CipherKey userKey_other;
        unsigned char *encodedKey_other = new unsigned char[ encodedKeySize ];
        if (!opts->no_interactive_configuration) {
            cout << autosprintf("You chose %d users. Enter passphrase for user %d\n", numusers, i+1);
            rDebug( "useStdin: %i", useStdin );
            if(useStdin)
                userKey_other = config->getUserKey( useStdin );
            else if(!passwordProgram.empty())
                userKey_other = config->getUserKey( passwordProgram, rootDir );
            else
                userKey_other = config->getNewUserKey();
        } else { 
            userKey_other =
                config->createUserKeyFromPassphrase(opts->passphrases[i]);
        }

        cipher->writeKey(volumeKey, encodedKey_other, userKey_other);
        config->easyencKeys[i].assign(encodedKey_other,
                encodedKey_other + encodedKeySize);
        userKey_other.reset();
        delete [] encodedKey_other;
    }

    if(!volumeKey)
    {
        rWarning(_("Failure generating new volume key! "
                    "Please report this error."));
        return rootInfo;
    }

    if(!saveConfig( Config_YC, rootDir, config ))
        return rootInfo;

    // fill in config struct
    shared_ptr<NameIO> nameCoder = NameIO::New( config->nameIface,
            cipher, volumeKey );
    if(!nameCoder)
    {
        rWarning(_("Name coding interface not supported"));
        cout << _("The filename encoding interface requested is not available") 
            << endl;
        return rootInfo;
    }

    nameCoder->setChainedNameIV( config->chainedNameIV );
    nameCoder->setReverseEncryption( reverseEncryption );

    FSConfigPtr fsConfig (new FSConfig);
    fsConfig->cipher = cipher;
    fsConfig->key = volumeKey;
    fsConfig->nameCoding = nameCoder;
    fsConfig->config = config;
    fsConfig->forceDecode = forceDecode;
    fsConfig->reverseEncryption = reverseEncryption;
    fsConfig->idleTracking = enableIdleTracking;
    fsConfig->opts = opts;

    rootInfo = RootPtr( new EncFS_Root );
    rootInfo->cipher = cipher;
    rootInfo->volumeKey = volumeKey;
    rootInfo->root = shared_ptr<DirNode>( 
            new DirNode( ctx, rootDir, fsConfig ));

    return rootInfo;
}

void showFSInfo( const boost::shared_ptr<EncFSConfig> &config )
{
    shared_ptr<Cipher> cipher = Cipher::New( config->cipherIface, -1 );
    {
	cout << autosprintf(
		// xgroup(diag)
		_("Filesystem cipher: \"%s\", version %i:%i:%i"),
                config->cipherIface.name().c_str(), config->cipherIface.current(),
                config->cipherIface.revision(), config->cipherIface.age());
	// check if we support this interface..
	if(!cipher)
	    cout << _(" (NOT supported)\n");
	else
	{
	    // if we're using a newer interface, show the version number
            if( config->cipherIface != cipher->interface() )
	    {
		Interface iface = cipher->interface();
		// xgroup(diag)
		cout << autosprintf(_(" (using %i:%i:%i)\n"),
			iface.current(), iface.revision(), iface.age());
	    } else
		cout << "\n";
	}
    }
    {
	// xgroup(diag)
	cout << autosprintf(_("Filename encoding: \"%s\", version %i:%i:%i"),
                config->nameIface.name().c_str(), config->nameIface.current(),
                config->nameIface.revision(), config->nameIface.age());
	    
	// check if we support the filename encoding interface..
        shared_ptr<NameIO> nameCoder = NameIO::New( config->nameIface,
    		cipher, CipherKey() );
	if(!nameCoder)
	{
	    // xgroup(diag)
	    cout << _(" (NOT supported)\n");
	} else
	{
	    // if we're using a newer interface, show the version number
            if( config->nameIface != nameCoder->interface() )
	    {
		Interface iface = nameCoder->interface();
		cout << autosprintf(_(" (using %i:%i:%i)\n"),
			iface.current(), iface.revision(), iface.age());
	    } else
		cout << "\n";
	}
    }
    {
        cout << autosprintf(_("Key Size: %i bits"), config->keySize);
        cipher = config->getCipher();
	if(!cipher)
	{
	    // xgroup(diag)
	    cout << _(" (NOT supported)\n");
	} else
	    cout << "\n";
    }
    if(config->kdfIterations > 0 && config->salt.size() > 0)
    {
	cout << autosprintf(_("Using PBKDF2, with %i iterations"), 
                              config->kdfIterations) << "\n";
	cout << autosprintf(_("Salt Size: %i bits"), 
                8*(int)config->salt.size()) << "\n";
    }
    if(config->blockMACBytes || config->blockMACRandBytes)
    {
        if(config->subVersion < 20040813)
	{
	    cout << autosprintf(
		    // xgroup(diag)
		    _("Block Size: %i bytes + %i byte MAC header"),
                    config->blockSize,
                    config->blockMACBytes + config->blockMACRandBytes) << endl;
	} else
	{
	    // new version stores the header as part of that block size..
	    cout << autosprintf(
		    // xgroup(diag)
		    _("Block Size: %i bytes, including %i byte MAC header"),
                    config->blockSize,
                    config->blockMACBytes + config->blockMACRandBytes) << endl;
	}
    } else
    {
	// xgroup(diag)
        cout << autosprintf(_("Block Size: %i bytes"), config->blockSize);
	cout << "\n";
    }

    if(config->uniqueIV)
    {
	// xgroup(diag)
	cout << _("Each file contains 8 byte header with unique IV data.\n");
    }
    if(config->chainedNameIV)
    {
	// xgroup(diag)
	cout << _("Filenames encoded using IV chaining mode.\n");
    }
    if(config->externalIVChaining)
    {
	// xgroup(diag)
	cout << _("File data IV is chained to filename IV.\n");
    }
    if(config->allowHoles)
    {
	// xgroup(diag)
	cout << _("File holes passed through to ciphertext.\n");
    }
    cout << "\n";
}
   
shared_ptr<Cipher> EncFSConfig::getCipher() const
{
    return Cipher::New( cipherIface, keySize );
}

void EncFSConfig::assignKeyData(const std::string &in)
{
    keyData.assign(in.data(), in.data()+in.length());
}

void EncFSConfig::assignKeyData(unsigned char *data, int len)
{
    keyData.assign(data, data+len);
}

void EncFSConfig::assignSaltData(unsigned char *data, int len)
{
    salt.assign(data, data+len);
}

unsigned char *EncFSConfig::getKeyData() const
{
    return const_cast<unsigned char *>(&keyData.front());
}

unsigned char *EncFSConfig::getSaltData() const
{
    return const_cast<unsigned char *>(&salt.front());
}

CipherKey EncFSConfig::makeKey(const char *password, int passwdLen)
{
    CipherKey userKey;
    shared_ptr<Cipher> cipher = getCipher();

    // if no salt is set and we're creating a new password for a new
    // FS type, then initialize salt..
    if(salt.size() == 0 && kdfIterations == 0 && cfgType >= Config_V6)
    {
        // upgrade to using salt
        salt.resize(20);
    }

    if(salt.size() > 0)
    {
        // if iterations isn't known, then we're creating a new key, so
        // randomize the salt..
        if(kdfIterations == 0 && !cipher->randomize( 
                    getSaltData(), salt.size(), true))
        {
            cout << _("Error creating salt\n");
            return userKey;
        }

        userKey = cipher->newKey( password, passwdLen,
                kdfIterations, desiredKDFDuration, 
                getSaltData(), salt.size());
    } else
    {
        userKey = cipher->newKey( password, passwdLen );
    }

    return userKey;
}

CipherKey EncFSConfig::createUserKeyFromPassphrase(string passphrase)
{
    CipherKey userKey;
    if(passphrase.length() == 0)
        cerr << _("Zero length password not allowed\n");
    else
        userKey = makeKey(passphrase.c_str(), passphrase.length());

    return userKey;
}

CipherKey EncFSConfig::getUserKey(bool useStdin)
{
    char passBuf[MaxPassBuf];
    char *res;

    if( useStdin )
    {
	res = fgets( passBuf, sizeof(passBuf), stdin );
	// Kill the trailing newline.
	if(passBuf[ strlen(passBuf)-1 ] == '\n')
	    passBuf[ strlen(passBuf)-1 ] = '\0';
    } else
    {
	// xgroup(common)
	res = readpassphrase( _("EncFS Password: "),
		passBuf, sizeof(passBuf), RPP_ECHO_OFF );
    }

    CipherKey userKey;
    if(!res)
	cerr << _("Zero length password not allowed\n");
    else
        userKey = makeKey(passBuf, strlen(passBuf));

    memset( passBuf, 0, sizeof(passBuf) );

    return userKey;
}

std::string readPassword( int FD )
{
    char buffer[1024];
    string result;

    while(1)
    {
	ssize_t rdSize = recv(FD, buffer, sizeof(buffer), 0);

	if(rdSize > 0)
	{
	    result.append( buffer, rdSize );
	    memset(buffer, 0, sizeof(buffer));
	} else
	    break;
    }

    // chop off trailing "\n" if present..
    // This is done so that we can use standard programs like ssh-askpass
    // without modification, as it returns trailing newline..
    if(!result.empty() && result[ result.length()-1 ] == '\n' )
	result.resize( result.length() -1 );

    return result;
}

CipherKey EncFSConfig::getUserKey( const std::string &passProg,
        const std::string &rootDir )
{
    // have a child process run the command and get the result back to us.
    int fds[2], pid;
    int res;
    CipherKey result;

    res = socketpair(PF_UNIX, SOCK_STREAM, 0, fds);
    if(res == -1)
    {
	perror(_("Internal error: socketpair() failed"));
	return result;
    }
    rDebug("getUserKey: fds = %i, %i", fds[0], fds[1]);

    pid = fork();
    if(pid == -1)
    {
	perror(_("Internal error: fork() failed"));
	close(fds[0]);
	close(fds[1]);
	return result;
    }

    if(pid == 0)
    {
	const char *argv[4];
	argv[0] = "/bin/sh";
	argv[1] = "-c";
	argv[2] = passProg.c_str();
	argv[3] = 0;

	// child process.. run the command and send output to fds[0]
	close(fds[1]); // we don't use the other half..

	// make a copy of stdout and stderr descriptors, and set an environment
	// variable telling where to find them, in case a child wants it..
	int stdOutCopy = dup( STDOUT_FILENO );
	int stdErrCopy = dup( STDERR_FILENO );
	// replace STDOUT with our socket, which we'll used to receive the
	// password..
	dup2( fds[0], STDOUT_FILENO );

	// ensure that STDOUT_FILENO and stdout/stderr are not closed on exec..
	fcntl(STDOUT_FILENO, F_SETFD, 0); // don't close on exec..
	fcntl(stdOutCopy, F_SETFD, 0);
	fcntl(stdErrCopy, F_SETFD, 0);

	char tmpBuf[8];

	setenv(ENCFS_ENV_ROOTDIR, rootDir.c_str(), 1);

	snprintf(tmpBuf, sizeof(tmpBuf)-1, "%i", stdOutCopy);
	setenv(ENCFS_ENV_STDOUT, tmpBuf, 1);
	
	snprintf(tmpBuf, sizeof(tmpBuf)-1, "%i", stdErrCopy);
	setenv(ENCFS_ENV_STDERR, tmpBuf, 1);

	execvp( argv[0], (char * const *)argv ); // returns only on error..

	perror(_("Internal error: failed to exec program"));
	exit(1);
    }

    close(fds[0]);
    string password = readPassword(fds[1]);
    close(fds[1]);

    waitpid(pid, NULL, 0);

    // convert to key..
    result = makeKey(password.c_str(), password.length());

    // clear buffer..
    password.assign( password.length(), '\0' );

    return result;
}

CipherKey EncFSConfig::getNewUserKey()
{
    CipherKey userKey;
    char passBuf[MaxPassBuf];
    char passBuf2[MaxPassBuf];

    do
    {
	// xgroup(common)
	char *res1 = readpassphrase(_("New Encfs Password: "), passBuf,
		sizeof(passBuf)-1, RPP_ECHO_OFF);
	// xgroup(common)
	char *res2 = readpassphrase(_("Verify Encfs Password: "), passBuf2,
		sizeof(passBuf2)-1, RPP_ECHO_OFF);

	if(res1 && res2 && !strcmp(passBuf, passBuf2))
        {
            userKey = makeKey(passBuf, strlen(passBuf));
        } else
	{
	    // xgroup(common) -- probably not common, but group with the others
	    cerr << _("Passwords did not match, please try again\n");
	}

	memset( passBuf, 0, sizeof(passBuf) );
	memset( passBuf2, 0, sizeof(passBuf2) );
    } while( !userKey );

    return userKey;
}

RootPtr initFS( EncFS_Context *ctx, const shared_ptr<EncFS_Opts> &opts )
{
    RootPtr rootInfo;
    boost::shared_ptr<EncFSConfig> config(new EncFSConfig);

    if(readConfig( opts->rootDir, config ) != Config_None)
    {
        if(opts->reverseEncryption)
        {
            if (config->blockMACBytes != 0 || config->blockMACRandBytes != 0
                    || config->uniqueIV || config->externalIVChaining
                    || config->chainedNameIV )
            {  
                cout << _("The configuration loaded is not compatible with --reverse\n");
                return rootInfo;
            }
        }

        // first, instanciate the cipher.
        shared_ptr<Cipher> cipher = config->getCipher();
        if(!cipher)
        {
            rError(_("Unable to find cipher %s, version %i:%i:%i"),
                    config->cipherIface.name().c_str(),
                    config->cipherIface.current(),
                    config->cipherIface.revision(),
                    config->cipherIface.age());
            // xgroup(diag)
            cout << _("The requested cipher interface is not available\n");
            return rootInfo;
        }

        // get user key
        CipherKey userKey;

        if (!opts->no_interactive_configuration)  {

            if(opts->passwordProgram.empty()) {
                rDebug( "useStdin: %i", opts->useStdin );
                userKey = config->getUserKey( opts->useStdin );
            } else {
                userKey = config->getUserKey( opts->passwordProgram, opts->rootDir );
            } 
        } else {
            rAssert(opts->num_users == 0 && opts->passphrases.size() == 1);
            userKey = config->createUserKeyFromPassphrase(opts->passphrases[0]);
        }

        if(!userKey)
            return rootInfo;

        rDebug("cipher key size = %i", cipher->encodedKeySize());
        // decode volume key..
        CipherKey volumeKey = cipher->readKey(
                config->getKeyData(), userKey, opts->checkKey);
        if(!volumeKey)
        {
            /* easyenc mods; old code below */
            /* try other keys */
            int i;
            for (i = 1; i < config->easyencNumUsers; ++i)
            {
                volumeKey = cipher->readKey(
                        const_cast<unsigned char *>(&(config->easyencKeys[i].front())),
                        userKey, opts->checkKey);
                if (!volumeKey) {
                    continue;
                } else {
                    /* cout << "Match found in easyenc key %d" << i << endl; */
                    break;
                }
            }
            ;
            /* old code below */
            if (i == config->easyencNumUsers)  {
                // xgroup(diag)
                cout << autosprintf("Error decoding any of %d volume keys,"
                        " password incorrect\n", config->easyencNumUsers);
                return rootInfo;
            }
        }

        userKey.reset();


        shared_ptr<NameIO> nameCoder = NameIO::New( config->nameIface, 
                cipher, volumeKey );
        if(!nameCoder)
        {
            rError(_("Unable to find nameio interface %s, version %i:%i:%i"),
                    config->nameIface.name().c_str(),
                    config->nameIface.current(),
                    config->nameIface.revision(),
                    config->nameIface.age());
            // xgroup(diag)
            cout << _("The requested filename coding interface is "
                    "not available\n");
            return rootInfo;
        }

        nameCoder->setChainedNameIV( config->chainedNameIV );
        nameCoder->setReverseEncryption( opts->reverseEncryption );

        FSConfigPtr fsConfig( new FSConfig );
        fsConfig->cipher = cipher;
        fsConfig->key = volumeKey;
        fsConfig->nameCoding = nameCoder;
        fsConfig->config = config;
        fsConfig->forceDecode = opts->forceDecode;
        fsConfig->reverseEncryption = opts->reverseEncryption;
        fsConfig->opts = opts;

        rootInfo = RootPtr( new EncFS_Root );
        rootInfo->cipher = cipher;
        rootInfo->volumeKey = volumeKey;
        rootInfo->root = shared_ptr<DirNode>( 
                new DirNode( ctx, opts->rootDir, fsConfig ));
    } else
    {
        if(opts->createIfNotFound)
        {
            // creating a new encrypted filesystem
            rootInfo = createV6Config( ctx, opts );
        }
    }

    return rootInfo;
}

int remountFS(EncFS_Context *ctx)
{
    rDebug("Attempting to reinitialize filesystem");

    RootPtr rootInfo = initFS( ctx, ctx->opts );
    if(rootInfo)
    {
	ctx->setRoot(rootInfo->root);
	return 0;
    } else
    {
	rInfo(_("Remount failed"));
	return -EACCES;
    }
}

