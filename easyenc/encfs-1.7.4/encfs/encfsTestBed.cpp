/*****************************************************************************
 * Author:   Rajsekar Manokaran (for Nouvou/Youcrypt)
 *****************************************************************************
 * Copyright (c) 2012: Rajsekar Manokaran
 *
 * This library is free software; you can distribute it and/or modify it under
 * the terms of the GNU General Public License (GPL), as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GPL in the file COPYING for more
 * details.
 *
 */

#include "encfs.h"
#include "config.h"
#include "autosprintf.h"

#include <iostream>
#include <string>
#include <sstream>

#include <cassert>
#include <cstdio>
#include <unistd.h>
#include <sys/time.h>
#include <cerrno>
#include <cstring>
#include <vector>
#include <sstream>

#include <getopt.h>

#include <boost/scoped_ptr.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>

#include <rlog/rlog.h>
#include <rlog/Error.h>
#include <rlog/RLogChannel.h>
#include <rlog/SyslogNode.h>
#include <rlog/StdioNode.h>

#include "ConfigReader.h"
#include "Interface.h"
#include "MemoryPool.h"
#include "FileUtils.h"
#include "DirNode.h"
#include "Context.h"

#include "openssl.h"

#include "YoucryptFolder.h"
#include "Credentials.h"
#include "PassphraseCredentials.h"

// Fuse version >= 26 requires another argument to fuse_unmount, which we
// don't have.  So use the backward compatible call instead..
extern "C" void fuse_unmount_compat22(const char *mountpoint);
#    define fuse_unmount fuse_unmount_compat22

#include <locale.h>

#include "i18n.h"

#ifndef MAX
inline static int MAX(int a, int b)
{
    return (a > b) ? a : b;
}
#endif

using namespace std;
using namespace rlog;
using namespace rel;
using namespace gnu;
using boost::shared_ptr;
using boost::scoped_ptr;

using namespace youcrypt;


// Maximum number of arguments that we're going to pass on to fuse.  Doesn't
// affect how many arguments we can handle, just how many we can pass on..
const int MaxFuseArgs = 32;
struct EncFS_Args
{
    string mountPoint; // where to make filesystem visible
    bool isDaemon; // true == spawn in background, log to syslog
    bool isThreaded; // true == threaded
    bool isVerbose; // false == only enable warning/error messages
    int idleTimeout; // 0 == idle time in minutes to trigger unmount
    const char *fuseArgv[MaxFuseArgs];
    int fuseArgc;

    shared_ptr<EncFS_Opts> opts;

    // for debugging
    // In case someone sends me a log dump, I want to know how what options are
    // in effect.  Not internationalized, since it is something that is mostly
    // useful for me!
    string toString()
    {
	ostringstream ss;
	ss << (isDaemon ? "(daemon) " : "(fg) ");
	ss << (isThreaded ? "(threaded) " : "(UP) ");
	if(idleTimeout > 0)
	    ss << "(timeout " << idleTimeout << ") ";
	if(opts->checkKey) ss << "(keyCheck) ";
	if(opts->forceDecode) ss << "(forceDecode) ";
	if(opts->ownerCreate) ss << "(ownerCreate) ";
	if(opts->useStdin) ss << "(useStdin) ";
	if(opts->reverseEncryption) ss << "(reverseEncryption) ";
	if(opts->mountOnDemand) ss << "(mountOnDemand) ";
	for(int i=0; i<fuseArgc; ++i)
	    ss << fuseArgv[i] << ' ';

	return ss.str();
    }

    EncFS_Args()
	: opts( new EncFS_Opts() )
    {
    }
};

static
void usage(const char *name)
{
    // xgroup(usage)
    cerr << autosprintf( _("Build: encfs version %s"), VERSION ) 
	<< "\n\n"
	// xgroup(usage)
	<< autosprintf(_("Usage: %s [options] rootDir mountPoint [-- [FUSE Mount Options]]"), name) << "\n\n"
	// xgroup(usage)
	<< _("Common Options:\n"
	"  -H\t\t\t"       "show optional FUSE Mount Options\n"
	"  -s\t\t\t"       "disable multithreaded operation\n"
	"  -f\t\t\t"       "run in foreground (don't spawn daemon).\n"
	             "\t\t\tError messages will be sent to stderr\n"
		     "\t\t\tinstead of syslog.\n")

	// xgroup(usage)
	<< _("  -v, --verbose\t\t"   "verbose: output encfs debug messages\n"
	"  -i, --idle=MINUTES\t""Auto unmount after period of inactivity\n"
	"  --anykey\t\t"        "Do not verify correct key is being used\n"
	"  --forcedecode\t\t"   "decode data even if an error is detected\n"
	                  "\t\t\t(for filesystems using MAC block headers)\n")
	<< _("  --public\t\t"   "act as a typical multi-user filesystem\n"
	                  "\t\t\t(encfs must be run as root)\n")
	<< _("  --reverse\t\t"  "reverse encryption\n")
    << _("  --extpass=program\tUse external program for password prompt\n"
	"\n"
	"Example, to mount at ~/crypt with raw storage in ~/.crypt :\n"
	"    encfs ~/.crypt ~/crypt\n"
	"\n")
    << _("\n\t\t****EasyEnc Options****\n")
    << _("   --nu \t\t Number of users to share this folder with\n")
    << _("   --pw \t\t List of passwords for users separated by ','\n")
    << _("\t\t         (first pw is used for the main user)\n")

      // RM:  Option to disable filename encryption
	 << _("   --enable-filename-encryption\n")
	 << _("   --disable-filename-encryption\n")
	// xgroup(usage)

	
	// xgroup(usage)
	<< _("For more information, see the man page encfs(1)") << "\n"
	<< endl;
}

static
void FuseUsage()
{
    // xgroup(usage)
    cerr << _("encfs [options] rootDir mountPoint -- [FUSE Mount Options]\n"
	    "valid FUSE Mount Options follow:\n") << endl;

    int argc = 2;
    const char *argv[] = {"...", "-h"};
    fuse_main( argc, const_cast<char**>(argv), (fuse_operations*)NULL, NULL);
}

#define PUSHARG(ARG) \
rAssert(out->fuseArgc < MaxFuseArgs); \
out->fuseArgv[out->fuseArgc++] = ARG

static string slashTerminate( const string &src )
{
    string result = src;
    if( result[ result.length()-1 ] != '/' )
	result.append( "/" );
    return result;
}

/* added by avr for easyenc */
static std::vector<std::string> &split(const std::string &s, char delim,
        std::vector<std::string> &elems) {
    std::stringstream ss(s);
    std::string item;
    while(std::getline(ss, item, delim)) {
        elems.push_back(item);
    }
    return elems;
}


static std::vector<std::string> split(const std::string &s, char delim) {
    std::vector<std::string> elems;
    return split(s, delim, elems);
}

static bool processArgs(int argc, char *argv[], const shared_ptr<EncFS_Args> &out)
{
    // set defaults
    out->isDaemon = true;
    out->isThreaded = true;
    out->isVerbose = false;
    out->idleTimeout = 0;
    out->fuseArgc = 0;
    out->opts->idleTracking = false;
    out->opts->checkKey = true;
    out->opts->forceDecode = false;
    out->opts->ownerCreate = false;
    out->opts->useStdin = false;
    out->opts->reverseEncryption = false;
 
    bool useDefaultFlags = true;

    // pass executable name through
    out->fuseArgv[0] = lastPathElement(argv[0]);
    ++out->fuseArgc;

    // leave a space for mount point, as FUSE expects the mount point before
    // any flags
    out->fuseArgv[1] = NULL;
    ++out->fuseArgc;
   
    // TODO: can flags be internationalized?
    static struct option long_options[] = {
	{"fuse-debug", 0, 0, 'd'}, // Fuse debug mode
	{"forcedecode", 0, 0, 'D'}, // force decode
	// {"foreground", 0, 0, 'f'}, // foreground mode (no daemon)
	{"fuse-help", 0, 0, 'H'}, // fuse_mount usage
	{"idle", 1, 0, 'i'}, // idle timeout
	{"anykey", 0, 0, 'k'}, // skip key checks
	{"no-default-flags", 0, 0, 'N'}, // don't use default fuse flags
	{"ondemand", 0, 0, 'm'}, // mount on-demand
	{"public", 0, 0, 'P'}, // public mode
	{"extpass", 1, 0, 'p'}, // external password program
	// {"single-thread", 0, 0, 's'}, // single-threaded mode
	{"stdinpass", 0, 0, 'S'}, // read password from stdin
	{"verbose", 0, 0, 'v'}, // verbose mode
	{"version", 0, 0, 'V'}, //version
	{"reverse", 0, 0, 'r'}, // reverse encryption
        {"standard", 0, 0, '1'},  // standard configuration
        {"paranoia", 0, 0, '2'},  // standard configuration
        // easyenc
	{"pw", 1, 0, 'w'}, // list of passphrases
	{"nu", 1, 0, 'x'}, // number of users
	{"enable-filename-encryption", 0, 0, 'F'},
	{"disable-filename-encryption", 0, 0, 'G'},
	{0,0,0,0}
    };

    string pps;

    while (1)
    {
	int option_index = 0;

	// 's' : single-threaded mode
	// 'f' : foreground mode
	// 'v' : verbose mode (same as --verbose)
	// 'd' : fuse debug mode (same as --fusedebug)
	// 'i' : idle-timeout, takes argument
	// 'm' : mount-on-demand
	// 'S' : password from stdin
	// 'o' : arguments meant for fuse
    // easyenc
    // 'nu': number of users
    // 'pw': list of passphrases


	int res = getopt_long( argc, argv, "HsSfvdmi:o:",
		long_options, &option_index);

	if(res == -1)
	    break;


	switch( res )
	{
        case '1':
            out->opts->configMode = Config_Standard;
            break;
        case '2':
            out->opts->configMode = Config_Paranoia;
            break;
	case 's':
	    out->isThreaded = false;
	    break;
	case 'S':
	    out->opts->useStdin = true;
	    break;
	case 'f':
	    out->isDaemon = false;
	    // this option was added in fuse 2.x
	    PUSHARG("-f");
	    break;
	case 'v':
	    out->isVerbose = true;
	    break;
	case 'd':
	    PUSHARG("-d");
	    break;
	case 'i':
	    out->idleTimeout = strtol( optarg, (char**)NULL, 10);
	    out->opts->idleTracking = true;
	    break;
	case 'k':
	    out->opts->checkKey = false;
	    break;
	case 'D':
	    out->opts->forceDecode = true;
	    break;
	case 'r':
	    out->opts->reverseEncryption = true;	    
	    break;
	case 'm':
	    out->opts->mountOnDemand = true;
	    break;
	case 'N':
	    useDefaultFlags = false;
	    break;
	case 'o':
	    PUSHARG("-o");
	    PUSHARG( optarg );
	    break;
	case 'p':
	    out->opts->passwordProgram.assign( optarg );
	    break;
	case 'P':
	    if(geteuid() != 0)
		rWarning(_("option '--public' ignored for non-root user"));
	    else
	    {
		out->opts->ownerCreate = true;
		// add 'allow_other' option
		// add 'default_permissions' option (default)
		PUSHARG("-o");
		PUSHARG("allow_other");
	    }
	    break;
	case 'V':
	    // xgroup(usage)
	    cerr << autosprintf(_("encfs version %s"), VERSION) << endl;
	    exit(EXIT_SUCCESS);
	    break;
	case 'H':
	    FuseUsage();
	    exit(EXIT_SUCCESS);
	    break;

    case 'w':
        pps = optarg;
        split(pps, ',', out->opts->passphrases);
        out->opts->no_interactive_configuration = true;
        break;

    case 'x': 
        out->opts->num_users = strtol( optarg, (char**)NULL, 10);
        out->opts->no_interactive_configuration = true;
        break;

	case 'F':
	  out->opts->mangleFilename = 1;
	  break;

	case 'G':
	  out->opts->mangleFilename = 0;
	  break;

	case '?':
	    // invalid options..
	    break;
	case ':':
	    // missing parameter for option..
	    break;
	default:
	    rWarning(_("getopt error: %i"), res);
	    break;
	}
    }

    if(!out->isThreaded)
	PUSHARG("-s");

    if(useDefaultFlags)
    {
	PUSHARG("-o");
	PUSHARG("use_ino");
	PUSHARG("-o");
	PUSHARG("default_permissions");
    }
	    
    // we should have at least 2 arguments left over - the source directory and
    // the mount point.
    if(optind+2 <= argc)
    {
	out->opts->rootDir = slashTerminate( argv[optind++] );
	out->mountPoint = argv[optind++];
    } else
    {
	// no mount point specified
	rWarning(_("Missing one or more arguments, aborting."));
	return false;
    }

    // If there are still extra unparsed arguments, pass them onto FUSE..
    if(optind < argc)
    {
	rAssert(out->fuseArgc < MaxFuseArgs);

	while(optind < argc)
	{
	    rAssert(out->fuseArgc < MaxFuseArgs);
	    out->fuseArgv[out->fuseArgc++] = argv[optind];
	    ++optind;
	}
    }

    // sanity check
    if(out->isDaemon && 
	    (!isAbsolutePath( out->mountPoint.c_str() ) ||
	    !isAbsolutePath( out->opts->rootDir.c_str() ) ) 
      )
    {
	cerr << 
	    // xgroup(usage)
	    _("When specifying daemon mode, you must use absolute paths "
		    "(beginning with '/')")
	    << endl;
	return false;
    }

    // the raw directory may not be a subdirectory of the mount point.
    {
	string testMountPoint = slashTerminate( out->mountPoint );
	string testRootDir = 
	    out->opts->rootDir.substr(0, testMountPoint.length());

	if( testMountPoint == testRootDir )
	{
	    cerr << 
		// xgroup(usage)
		_("The raw directory may not be a subdirectory of the "
		  "mount point.") << endl;
	    return false;
	}
    }

    if(out->opts->mountOnDemand && out->opts->passwordProgram.empty())
    {
	cerr << 
	    // xgroup(usage)
	    _("Must set password program when using mount-on-demand")
	    << endl;
	return false;
    }

    // check that the directories exist, or that we can create them..
    if(!isDirectory( out->opts->rootDir.c_str() ) && 
	    !userAllowMkdir( out->opts->rootDir.c_str() ,0700))
    {
	rWarning(_("Unable to locate root directory, aborting."));
	return false;
    }
    if(!isDirectory( out->mountPoint.c_str() ) && 
	    !userAllowMkdir( out->mountPoint.c_str(),0700))
    {
	rWarning(_("Unable to locate mount point, aborting."));
	return false;
    }

    // fill in mount path for fuse
    out->fuseArgv[1] = out->mountPoint.c_str();

    return true;
}


int main(int argc, char **argv)
{
    shared_ptr<EncFS_Args> encfsArgs( new EncFS_Args );
    for(int i=0; i<MaxFuseArgs; ++i)
	encfsArgs->fuseArgv[i] = NULL; // libfuse expects null args..

    if(argc == 1 || !processArgs(argc, argv, encfsArgs))
    {
	usage(argv[0]);
	return EXIT_FAILURE;
    }

    RLogInit (argc, argv);
    // Subscribe to every channel.
    scoped_ptr<StdioNode> slog (new StdioNode (STDERR_FILENO) );
    slog->subscribeTo (GetGlobalChannel ("error") );
    slog->subscribeTo (GetGlobalChannel ("warning") );
    slog->subscribeTo (GetGlobalChannel ("info") );
    slog->subscribeTo (GetGlobalChannel ("debug") );

    openssl_init( encfsArgs->isThreaded );

    // Write encrypt folder code here.
    string encRoot = encfsArgs->opts->rootDir; 
    string srcFolder = encfsArgs->mountPoint;
    
    YoucryptFolderOpts opts;
    Credentials creds(new PassphraseCredentials("asdf"));
    cout << "Source Folder is " << encRoot << endl;
    YoucryptFolder folder(path(encRoot),
                          opts,
                          creds);

    string destSuffix = (path() / path(srcFolder).filename()).string();
    destSuffix.append (1, '/');
    cout << "Encrypting contents of " << srcFolder << " into " << encRoot << endl
         << "at " << "/" << destSuffix << endl;    
    folder.importContent (path(srcFolder), destSuffix);

    MemoryPool::destroyAll();
    openssl_shutdown( encfsArgs->isThreaded );
    return 0;
}

