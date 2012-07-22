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
namespace fs = boost::filesystem;


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

static int oldStderr = STDERR_FILENO;

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

static void * idleMonitor(void *);

void *encfs_init(fuse_conn_info *conn)
{
    EncFS_Context *ctx = (EncFS_Context*)fuse_get_context()->private_data;

    // set fuse connection options
    conn->async_read = true;

    // if an idle timeout is specified, then setup a thread to monitor the
    // filesystem.
    if(ctx->args->idleTimeout > 0)
    {
	rDebug("starting idle monitoring thread");
	ctx->running = true;

	int res = pthread_create( &ctx->monitorThread, 0, idleMonitor, 
		(void*)ctx );
	if(res != 0)
	{
	    rError("error starting idle monitor thread, "
		    "res = %i, errno = %i", res, errno);
	}
    }

    if(ctx->args->isDaemon && oldStderr >= 0)
    {
	rInfo("Closing stderr");
	close(oldStderr);
	oldStderr = -1;
    }

    return (void*)ctx;
}
 
void encfs_destroy( void *_ctx )
{
    EncFS_Context *ctx = (EncFS_Context*)_ctx;
    if(ctx->args->idleTimeout > 0)
    {
	ctx->running = false;

	// wake up the thread if it is waiting..
	rDebug("waking up monitoring thread");
	pthread_mutex_lock( &ctx->wakeupMutex );
	pthread_cond_signal( &ctx->wakeupCond );
	pthread_mutex_unlock( &ctx->wakeupMutex );
	rDebug("joining with idle monitoring thread");
	pthread_join( ctx->monitorThread , 0 );
	rDebug("join done");
    }
}

void read_fully(int fd, char *ptr, size_t size) 
{
  size_t rsize;
  while (size) {
    rsize = read(fd, ptr, size);    
    size -= rsize;
  }
}


int parse_sock_args(int client_socket_fd, char ***pargv)
{
    FILE *sockfile = fdopen(client_socket_fd, "r");
    char line[1000], **argv;
    int argc;    

    fgets(line, 998, sockfile);
    sscanf(line, "%d", &argc);
    (*pargv) = argv = (char **)malloc(sizeof(char *) * argc);
    for (int i=0; i<argc; i++) {
        int len;
        fgets(line, 998, sockfile);
        len = strlen(line);
	if (line[len-1] == '\n') {
	    line[--len] = 0;
	}
        argv[i] = (char *)malloc(sizeof(char)*(len+1));
        strcpy(argv[i], line);
    }
    return argc;
}


int encryptFolder( EncFS_Context * ctx,
                   const string &destSuffix,
                    const string &sourcePath) {
    int res;
    fs::path p(sourcePath);   
    shared_ptr<DirNode> root = ctx->getRoot(&res);

    try {
        if (exists(p))    // does p actually exist?
        {
            if (is_regular_file(p)) 
            {
                //  p is a regular file?                 
                // cout << "touch " << p.filename() << '\n';
                // cout << "openNode: " << (destSuffix + p.filename().string()) << '\n';
                shared_ptr<FileNode> fnode = root->lookupNode (
                    (destSuffix + p.filename().string()).c_str(),
                    "create");

                // FIXME:  take care of permissions.                
                fnode->mknod (S_IFREG | S_IRUSR | S_IWUSR | S_IWOTH | S_IROTH, 0, 0, 0);
                fnode->open (O_WRONLY );

                // FIXME:  do file IO to copy file contents.
                fs::ifstream file(p);
                char buffer[1024];
                off_t offset = 0;
                while (!file.eof()) {
                    file.read (buffer, 1024);
                    fnode->write(offset, (unsigned char *)buffer, file.gcount());
                    offset += file.gcount();
                }                                
                fnode.reset();
            }
            else if (is_directory(p))      // is p a directory?
            {
                // FIXME:  take care of permissions.
                root->mkdir( 
                    (destSuffix + p.filename().string()).c_str(),
                    0777, 0, 0);
                
                // cout << "mkdir " << p.filename() << '\n';
                // cout << "cd " << p.filename() << '\n';
                
                for (fs::directory_iterator curr = fs::directory_iterator(p); 
                     curr != fs::directory_iterator(); ++curr) {
                    encryptFolder (ctx, 
                                   destSuffix + p.filename().string() + string("/"),
                                   curr->path().string());
                }

                cout << "cd ..\n";
            }
            else if (is_symlink(p)) {
                ;
                // FIXME:  take care of symlinks that point within the tree being copied.
                // FIXME:  create a symlink.
            }
            else {   
                ;
                // cout << p << " exists, but is neither a regular file nor a directory\n";
            }
        }
        else {
        }
            // cout << p << " does not exist\n";
    }
    catch (const fs::filesystem_error& ex)
    {
        cout << ex.what() << '\n';
    }

    return 0;
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
    scoped_ptr<StdioNode> slog (new StdioNode (STDERR_FILENO) );
    slog->subscribeTo (GetGlobalChannel ("error") );
    slog->subscribeTo (GetGlobalChannel ("warning") );
    slog->subscribeTo (GetGlobalChannel ("info") );
    slog->subscribeTo (GetGlobalChannel ("debug") );

    openssl_init( encfsArgs->isThreaded );

    // context is not a smart pointer because it will live for the life of
    // the filesystem.
    EncFS_Context *ctx = new EncFS_Context;
    ctx->publicFilesystem = encfsArgs->opts->ownerCreate;
    RootPtr rootInfo = initFS( ctx, encfsArgs->opts );
    
    int returnCode = EXIT_FAILURE;

    if( rootInfo )
    {
	// set the globally visible root directory node
	ctx->setRoot( rootInfo->root );
	ctx->args = encfsArgs;
	ctx->opts = encfsArgs->opts;
	    
	if(encfsArgs->isThreaded == false && encfsArgs->idleTimeout > 0)
	{
	    // xgroup(usage)
	    cerr << _("Note: requested single-threaded mode, but an idle\n"
		    "timeout was specified.  The filesystem will operate\n"
		    "single-threaded, but threads will still be used to\n"
		    "implement idle checking.") << endl;
	}

	// reset umask now, since we don't want it to interfere with the
	// pass-thru calls..
	umask( 0 );
    }


    // Write encrypt folder code here.
    string srcFolder = encfsArgs->mountPoint;
    string encRoot = encfsArgs->opts->rootDir;
    cout << "Encrypting contents of " << srcFolder << " into " << encRoot << endl;
    returnCode = encryptFolder( ctx,  "/", srcFolder);

    // cleanup so that we can check for leaked resources..
    rootInfo.reset();
    ctx->setRoot( shared_ptr<DirNode>() );

    MemoryPool::destroyAll();
    openssl_shutdown( encfsArgs->isThreaded );

    return returnCode;
}

/*
    Idle monitoring thread.  This is only used when idle monitoring is enabled.
    It will cause the filesystem to be automatically unmounted (causing us to
    commit suicide) if the filesystem stays idle too long.  Idle time is only
    checked if there are no open files, as I don't want to risk problems by
    having the filesystem unmounted from underneath open files!
*/
const int ActivityCheckInterval = 10;
static bool unmountFS(EncFS_Context *ctx);

static void * idleMonitor(void *_arg)
{
    EncFS_Context *ctx = (EncFS_Context*)_arg;
    shared_ptr<EncFS_Args> arg = ctx->args;

    const int timeoutCycles = 60 * arg->idleTimeout / ActivityCheckInterval;
    int idleCycles = 0;

    pthread_mutex_lock( &ctx->wakeupMutex );
    
    while(ctx->running)
    {
	int usage = ctx->getAndResetUsageCounter();

	if(usage == 0 && ctx->isMounted())
	    ++idleCycles;
	else
	    idleCycles = 0;
	
	if(idleCycles >= timeoutCycles)
	{
	    int openCount = ctx->openFileCount();
	    if( openCount == 0 && unmountFS( ctx ) )
	    {
		// wait for main thread to wake us up
		pthread_cond_wait( &ctx->wakeupCond, &ctx->wakeupMutex );
		break;
	    }
		
	    rDebug("num open files: %i", openCount );
	}
	    
	rDebug("idle cycle count: %i, timeout after %i", idleCycles,
		timeoutCycles);

	struct timeval currentTime;
	gettimeofday( &currentTime, 0 );
	struct timespec wakeupTime;
	wakeupTime.tv_sec = currentTime.tv_sec + ActivityCheckInterval;
	wakeupTime.tv_nsec = currentTime.tv_usec * 1000;
	pthread_cond_timedwait( &ctx->wakeupCond, 
		&ctx->wakeupMutex, &wakeupTime );
    }
    
    pthread_mutex_unlock( &ctx->wakeupMutex );

    rDebug("Idle monitoring thread exiting");

    return 0;
}

static bool unmountFS(EncFS_Context *ctx)
{
    shared_ptr<EncFS_Args> arg = ctx->args;
    if( arg->opts->mountOnDemand )
    {
	rDebug("Detaching filesystem %s due to inactivity",
		arg->mountPoint.c_str());

	ctx->setRoot( shared_ptr<DirNode>() );
	return false;
    } else
    {
	// Time to unmount!
	// xgroup(diag)
	rWarning(_("Unmounting filesystem %s due to inactivity"),
		arg->mountPoint.c_str());
	fuse_unmount( arg->mountPoint.c_str() );
	return true;
    }
}

