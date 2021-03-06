/************************************************************
 * Author: Anirudh Ramachandran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#include "YoucryptFolder.h"
#include "config.h"
#include "FSConfig.h"
#include "Cipher.h"
#include "NameIO.h"
#include "BlockNameIO.h"
#include "NullNameIO.h"
#include "YCNameIO.h"
#include "DirNode.h"
#include "Interface.h"
#include "youcryptMountHelpers.h"

#include "autosprintf.h"
#include "i18n.h"
#include "openssl.h"

#include <pthread.h>
#include <rlog/rlog.h>
#include <rlog/Error.h>
#include <rlog/SyslogNode.h>
#include <rlog/RLogChannel.h>

#include <sys/statvfs.h>
#include <sys/time.h>
#include <unistd.h>
#include <signal.h>
#include <fcntl.h>
#include <dirent.h>
#include <sys/types.h>
#ifdef linux
#include <sys/fsuid.h>
#endif

#ifdef HAVE_ATTR_XATTR_H
#include <attr/xattr.h>
#elif HAVE_SYS_XATTR_H
#include <sys/xattr.h>
#endif




#include <iostream>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/tuple/tuple.hpp>
#include <boost/scoped_ptr.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/scoped_array.hpp>

static FILE * consfd;

using boost::filesystem::path;
using boost::filesystem::directory_iterator;
using boost::filesystem::ifstream;
using boost::filesystem::ofstream;

using boost::tuple;
using boost::split;
using boost::is_any_of;
using boost::scoped_ptr;
using boost::shared_ptr;
using boost::scoped_array;
using boost::make_tuple;

using youcrypt::YoucryptFolder;

using rel::Interface;

using rlog::RLogChannel;
using rlog::Log_Info;
using rlog::SyslogNode;
using rlog::_RLWarningChannel;

#define GET_FN(ctx, finfo) ctx->getNode((void*)(uintptr_t)finfo->fh)

#define ESUCCESS 0




static RLogChannel * Info = DEF_CHANNEL( "info/youcrypt", Log_Info );

static EncFS_Context * context()
{
    return (EncFS_Context*)fuse_get_context()->private_data;
}

// helper function -- apply a functor to a cipher path, given the plain path
template<typename T>
static int withCipherPath( const char *opName, const char *path,
	int (*op)(EncFS_Context *, const string &name, T data ), T data,
        bool passReturnCode = false )
{
    EncFS_Context *ctx = context();

    int res = -EIO;
    shared_ptr<DirNode> FSRoot = ctx->getRoot(&res);
    if(!FSRoot)
	return res;

    try
    {
	string cyName = FSRoot->cipherPath( path );
	rLog(Info, "%s %s", opName, cyName.c_str());

	res = op( ctx, cyName, data );
	
	if(res == -1)
	{
	    int eno = errno;
	    rInfo("%s error: %s", opName, strerror(eno));
	    res = -eno;
	} else if(!passReturnCode)
	    res = ESUCCESS;
    } catch( rlog::Error &err )
    {
	rError("error caught in %s", opName);
	err.log( _RLWarningChannel );
    }
    return res;
}



template<typename T>
static int withFileNode( const char *opName,
                         const char *path, struct fuse_file_info *fi, 
                         int (*op)(FileNode *, T data ), T data )
{
    EncFS_Context *ctx = context();

    int res = -EIO;
    shared_ptr<DirNode> FSRoot = ctx->getRoot(&res);
    if(!FSRoot)
	return res;

    try
    {
	shared_ptr<FileNode> fnode;

	if(fi != NULL)
	    fnode = GET_FN(ctx, fi);
	else
	    fnode = FSRoot->lookupNode( path, opName );

	rAssert(fnode != NULL);
	rLog(Info, "%s %s", opName, fnode->cipherName());
	res = op( fnode.get(), data );

	if(res < 0)
	    rInfo("%s error: %s", opName, strerror(-res));
    } catch( rlog::Error &err )
    {
	rError("error caught in %s", opName);
	err.log( _RLWarningChannel );
    }
    return res;
}

static int _do_getattr(FileNode *fnode, struct stat *stbuf)
{
    int res = fnode->getAttr(stbuf);
    if(res == ESUCCESS && S_ISLNK(stbuf->st_mode))
    {
	EncFS_Context *ctx = context();
	shared_ptr<DirNode> FSRoot = ctx->getRoot(&res);
	if(FSRoot)
	{
	    // determine plaintext link size..  Easiest to read and decrypt..
	    scoped_array<char> buf(new char[stbuf->st_size+1]);

	    res = ::readlink( fnode->cipherName(), buf.get(), stbuf->st_size );
            if(res >= 0)
            {
                // other functions expect c-strings to be null-terminated, which
                // readlink doesn't provide
                buf[res] = '\0';

                stbuf->st_size = FSRoot->plainPath( buf.get() ).length();

                res = ESUCCESS;
            } else
                res = -errno;
	}
    }

    return res;
}


int youcrypt_mount_getattr(const char *path, struct stat *stbuf)
{
    return withFileNode( "getattr", path, NULL, _do_getattr, stbuf );
}

int youcrypt_mount_fgetattr(const char *path, struct stat *stbuf,
	struct fuse_file_info *fi)
{
    return withFileNode( "fgetattr", path, fi, _do_getattr, stbuf );
}

int youcrypt_mount_getdir(const char *path, fuse_dirh_t h, fuse_dirfil_t filler)
{
    EncFS_Context *ctx = context();

    int res = ESUCCESS;
    shared_ptr<DirNode> FSRoot = ctx->getRoot(&res);
    if(!FSRoot)
        return res;

    try
    {
        DirTraverse dt = FSRoot->openDir( path );

        rLog(Info, "getdir on %s", FSRoot->cipherPath(path).c_str());

        if(dt.valid())
        {
            int fileType = 0;
            ino_t inode = 0;

            std::string name = dt.nextPlaintextName( &fileType, &inode );
            while( !name.empty() )
            {
        	res = filler( h, name.c_str(), fileType, inode );

        	if(res != ESUCCESS)
        	    break;

        	name = dt.nextPlaintextName( &fileType, &inode );
            } 
        } else
        {
            rInfo("getdir request invalid, path: '%s'", path);
        }

        return res;
    } catch( rlog::Error &err )
    {
        rError("Error caught in getdir");
        err.log( _RLWarningChannel );
        return -EIO;
    }
}

int youcrypt_mount_mknod(const char *path, mode_t mode, dev_t rdev)
{
    EncFS_Context *ctx = context();

    int res = -EIO;
    shared_ptr<DirNode> FSRoot = ctx->getRoot(&res);
    if(!FSRoot)
        return res;

    try
    {
        shared_ptr<FileNode> fnode = FSRoot->lookupNode( path, "mknod" );

        rLog(Info, "mknod on %s, mode %i, dev %" PRIi64,
        	fnode->cipherName(), mode, (int64_t)rdev);

        uid_t uid = 0;
        gid_t gid = 0;
        if(ctx->publicFilesystem)
        {
            fuse_context *context = fuse_get_context();
            uid = context->uid;
            gid = context->gid;
        }
        res = fnode->mknod( mode, rdev, uid, gid );
        // Is this error due to access problems?
        if(ctx->publicFilesystem && -res == EACCES)
        {
            // try again using the parent dir's group
            string parent = fnode->plaintextParent();
            rInfo("trying public filesystem workaround for %s", parent.c_str());
            shared_ptr<FileNode> dnode = 
        	FSRoot->lookupNode( parent.c_str(), "mknod" );

            struct stat st;
            if(dnode->getAttr( &st ) == 0)
        	res = fnode->mknod( mode, rdev, uid, st.st_gid );
        }
    } catch( rlog::Error &err )
    {
        rError("error caught in mknod");
        err.log( _RLWarningChannel );
    }
    return res;
}

int youcrypt_mount_mkdir(const char *path, mode_t mode)
{
    fuse_context *fctx = fuse_get_context();
    EncFS_Context *ctx = context();

    int res = -EIO;
    shared_ptr<DirNode> FSRoot = ctx->getRoot(&res);
    if(!FSRoot)
        return res;

    try
    {
        uid_t uid = 0;
        gid_t gid = 0;
        if(ctx->publicFilesystem)
        {
            uid = fctx->uid;
            gid = fctx->gid;
        }
        res = FSRoot->mkdir( path, mode, uid, gid );
        // Is this error due to access problems?
        if(ctx->publicFilesystem && -res == EACCES)
        {
            // try again using the parent dir's group
            string parent = parentDirectory( path );
            shared_ptr<FileNode> dnode = 
        	FSRoot->lookupNode( parent.c_str(), "mkdir" );

            struct stat st;
            if(dnode->getAttr( &st ) == 0)
        	res = FSRoot->mkdir( path, mode, uid, st.st_gid );
        }
    } catch( rlog::Error &err )
    {
        rError("error caught in mkdir");
        err.log( _RLWarningChannel );
    }
    return res;
}

int youcrypt_mount_unlink(const char *path)
{
    EncFS_Context *ctx = context();

    int res = -EIO;
    shared_ptr<DirNode> FSRoot = ctx->getRoot(&res);
    if(!FSRoot)
        return res;

    try
    {
        // let DirNode handle it atomically so that it can handle race
        // conditions
        res = FSRoot->unlink( path );
    } catch( rlog::Error &err )
    {
        rError("error caught in unlink");
        err.log( _RLWarningChannel );
    }
    return res;
}


static int _do_rmdir(EncFS_Context *, const string &cipherPath, int )
{
    return rmdir( cipherPath.c_str() );
}

int youcrypt_mount_rmdir(const char *path)
{
    return withCipherPath( "rmdir", path, _do_rmdir, 0 );
}

static int _do_readlink(EncFS_Context *ctx, const string &cyName,
                 tuple<char *, size_t> data )
{
    char *buf = data.get<0>();
    size_t size = data.get<1>();

    int res = ESUCCESS;
    shared_ptr<DirNode> FSRoot = ctx->getRoot(&res);
    if(!FSRoot)
        return res;

    res = ::readlink( cyName.c_str(), buf, size-1 );

    if(res == -1)
        return -errno;

    buf[res] = '\0'; // ensure null termination
    string decodedName;
    try
    {
        decodedName = FSRoot->plainPath( buf );
    } catch(...) { }

    if(!decodedName.empty())
    {
        strncpy(buf, decodedName.c_str(), size-1);
        buf[size-1] = '\0';

        return ESUCCESS;
    } else
    {
        rWarning("Error decoding link");
        return -1;
    }
}

int youcrypt_mount_readlink(const char *path, char *buf, size_t size)
{
    return withCipherPath( "readlink", path, _do_readlink, 
                           make_tuple(buf, size) );
}

int youcrypt_mount_symlink(const char *from, const char *to)
{
    EncFS_Context *ctx = context();

    int res = -EIO;
    shared_ptr<DirNode> FSRoot = ctx->getRoot(&res);
    if(!FSRoot)
        return res;

    try
    {
        // allow fully qualified names in symbolic links.
        string fromCName = FSRoot->relativeCipherPath( from );
        string toCName = FSRoot->cipherPath( to );
	
        rLog(Info, "symlink %s -> %s", fromCName.c_str(), toCName.c_str());

        // use setfsuid / setfsgid so that the new link will be owned by the
        // uid/gid provided by the fuse_context.
        int olduid = -1;
        int oldgid = -1;
        if(ctx->publicFilesystem)
        {
            fuse_context *context = fuse_get_context();
            olduid = setfsuid( context->uid );
            oldgid = setfsgid( context->gid );
        }
        res = ::symlink( fromCName.c_str(), toCName.c_str() );
        if(olduid >= 0)
            setfsuid( olduid );
        if(oldgid >= 0)
            setfsgid( oldgid );

        if(res == -1)
            res = -errno;
        else
            res = ESUCCESS;
    } catch( rlog::Error &err )
    {
        rError("error caught in symlink");
        err.log( _RLWarningChannel );
    }
    return res;
}

int youcrypt_mount_link(const char *from, const char *to)
{
    EncFS_Context *ctx = context();

    int res = -EIO;
    shared_ptr<DirNode> FSRoot = ctx->getRoot(&res);
    if(!FSRoot)
        return res;

    try
    {
        res = FSRoot->link( from, to );
    } catch( rlog::Error &err )
    {
        rError("error caught in link");
        err.log( _RLWarningChannel );
    }
    return res;
}

int youcrypt_mount_rename(const char *from, const char *to)
{
    EncFS_Context *ctx = context();

    int res = -EIO;
    shared_ptr<DirNode> FSRoot = ctx->getRoot(&res);
    if(!FSRoot)
        return res;

    try
    {
        res = FSRoot->rename( from, to );
    } catch( rlog::Error &err )
    {
        rError("error caught in rename");
        err.log( _RLWarningChannel );
    }
    return res;
}

static int _do_chmod(EncFS_Context *, const string &cipherPath, mode_t mode)
{
    return chmod( cipherPath.c_str(), mode );
}

int youcrypt_mount_chmod(const char *path, mode_t mode)
{
    return withCipherPath( "chmod", path, _do_chmod, mode );
}

static int _do_chown(EncFS_Context *, const string &cyName, 
	tuple<uid_t, gid_t> data)
{
    int res = lchown( cyName.c_str(), data.get<0>(), data.get<1>() );
    return (res == -1) ? -errno : ESUCCESS;
}

int youcrypt_mount_chown(const char *path, uid_t uid, gid_t gid)
{
    return withCipherPath( "chown", path, _do_chown, make_tuple(uid, gid));
}

static int _do_truncate( FileNode *fnode, off_t size )
{
    return fnode->truncate( size );
}

int youcrypt_mount_truncate(const char *path, off_t size)
{
    return withFileNode( "truncate", path, NULL, _do_truncate, size );
}

int youcrypt_mount_ftruncate(const char *path, 
                             off_t size, struct fuse_file_info *fi)
{
    return withFileNode( "ftruncate", path, fi, _do_truncate, size );
}

static int _do_utime(EncFS_Context *, const string &cyName, struct utimbuf *buf)
{
    int res = utime( cyName.c_str(), buf);
    return (res == -1) ? -errno : ESUCCESS;
}

int youcrypt_mount_utime(const char *path, struct utimbuf *buf)
{
    return withCipherPath( "utime", path, _do_utime, buf );
}

static int _do_utimens(EncFS_Context *, const string &cyName, 
	const struct timespec ts[2])
{
    struct timeval tv[2];
    tv[0].tv_sec = ts[0].tv_sec;
    tv[0].tv_usec = ts[0].tv_nsec / 1000;
    tv[1].tv_sec = ts[1].tv_sec;
    tv[1].tv_usec = ts[1].tv_nsec / 1000;

    int res = lutimes( cyName.c_str(), tv);
    return (res == -1) ? -errno : ESUCCESS;
}

int youcrypt_mount_utimens(const char *path, const struct timespec ts[2] )
{
    return withCipherPath( "utimens", path, _do_utimens, ts );
}

int youcrypt_mount_open(const char *path, struct fuse_file_info *file)
{
    EncFS_Context *ctx = context();

    int res = -EIO;
    shared_ptr<DirNode> FSRoot = ctx->getRoot(&res);
    if(!FSRoot)
        return res;

    try
    {
        shared_ptr<FileNode> fnode = 
            FSRoot->openNode( path, "open", file->flags, &res );

        if(fnode)
        {
            rLog(Info, "youcrypt_mount_open for %s, flags %i", 
                 fnode->cipherName(), 
                 file->flags);

            if( res >= 0 )
            {
        	file->fh = (uintptr_t)ctx->putNode(path, fnode);
        	res = ESUCCESS;
            }
        }
    } catch( rlog::Error &err )
    {
        rError("error caught in open");
        err.log( _RLWarningChannel );
    }

    return res;
}

static int _do_flush(FileNode *fnode, int )
{
    /* Flush can be called multiple times for an open file, so it doesn't
       close the file.  However it is important to call close() for some
       underlying filesystems (like NFS).
    */
    int res = fnode->open( O_RDONLY );
    if(res >= 0)
    {
        int fh = res;
        res = close(dup(fh));
        if(res == -1)
            res = -errno;
    }

    return res;
}

int youcrypt_mount_flush(const char *path, struct fuse_file_info *fi)
{
    return withFileNode( "flush", path, fi, _do_flush, 0 );
}

/*
Note: This is advisory -- it might benefit us to keep file nodes around for a
bit after they are released just in case they are reopened soon.  But that
requires a cache layer.
 */
int youcrypt_mount_release(const char *path, struct fuse_file_info *finfo)
{
    EncFS_Context *ctx = context();

    try
    {
        ctx->eraseNode( path, (void*)(uintptr_t)finfo->fh );
        return ESUCCESS;
    } catch( rlog::Error &err )
    {
        rError("error caught in release");
        err.log( _RLWarningChannel );
        return -EIO;
    }
}

static int _do_read(FileNode *fnode, tuple<unsigned char *, size_t, off_t> data)
{
    return fnode->read( data.get<2>(), data.get<0>(), data.get<1>());
}

int youcrypt_mount_read(const char *path, char *buf, size_t size, off_t offset,
	struct fuse_file_info *file)
{
    return withFileNode( "read", path, file, _do_read,
            make_tuple((unsigned char *)buf, size, offset));
}

static int _do_fsync(FileNode *fnode, int dataSync)
{
    return fnode->sync( dataSync != 0 );
}

int youcrypt_mount_fsync(const char *path, int dataSync,
	struct fuse_file_info *file)
{
    return withFileNode( "fsync", path, file, _do_fsync, dataSync );
}

static int _do_write(FileNode *fnode, tuple<const char *, size_t, off_t> data)
{
    size_t size = data.get<1>();
    if(fnode->write( data.get<2>(), (unsigned char *)data.get<0>(), size ))
        return size;
    else
        return -EIO;
}

int youcrypt_mount_write(const char *path, const char *buf, size_t size,
                     off_t offset, struct fuse_file_info *file)
{
    return withFileNode("write", path, file, _do_write,
            make_tuple(buf, size, offset));
}

// statfs works even if encfs is detached..
int youcrypt_mount_statfs(const char *path, struct statvfs *st)
{
    EncFS_Context *ctx = context();

    int res = -EIO;
    try
    {
        (void)path; // path should always be '/' for now..
        rAssert( st != NULL );
        string cyName = ctx->rootCipherDir;

        rLog(Info, "doing statfs of %s", cyName.c_str());
        res = statvfs( cyName.c_str(), st );
        if(!res) 
        {
            // adjust maximum name length..
            st->f_namemax     = 6 * (st->f_namemax - 2) / 8; // approx..
        }
        if(res == -1)
            res = -errno;
    } catch( rlog::Error &err )
    {
        rError("error caught in statfs");
        err.log( _RLWarningChannel );
    }
    return res;
}

#ifdef HAVE_XATTR


#ifdef XATTR_ADD_OPT
static int _do_setxattr(EncFS_Context *, const string &cyName, 
	tuple<const char *, const char *, size_t, uint32_t> data)
{
    int options = 0;
    return ::setxattr( cyName.c_str(), data.get<0>(), data.get<1>(), 
                       data.get<2>(), data.get<3>(), options );
}
int youcrypt_mount_setxattr( const char *path, const char *name,
	const char *value, size_t size, int flags, uint32_t position )
{
    (void)flags;
    return withCipherPath( "setxattr", path, _do_setxattr, 
                           make_tuple(name, value, size, position) );
}
#else
static int _do_setxattr(EncFS_Context *, const string &cyName, 
	tuple<const char *, const char *, size_t, int> data)
{
    return ::setxattr( cyName.c_str(), data.get<0>(), data.get<1>(), 
                       data.get<2>(), data.get<3>() );
}

int youcrypt_mount_setxattr( const char *path, const char *name,
	const char *value, size_t size, int flags )
{
    return withCipherPath( "setxattr", path, _do_setxattr, 
                           make_tuple(name, value, size, flags) );
}
#endif


#ifdef XATTR_ADD_OPT
static int _do_getxattr(EncFS_Context *, const string &cyName,
	tuple<const char *, void *, size_t, uint32_t> data)
{
    int options = 0;
    return ::getxattr( cyName.c_str(), data.get<0>(), 
                       data.get<1>(), data.get<2>(), 
                       data.get<3>(), options );
}
int youcrypt_mount_getxattr( const char *path, const char *name,
	char *value, size_t size, uint32_t position )
{
    return withCipherPath( "getxattr", path, _do_getxattr, 
                           make_tuple(name, (void *)value, 
                                      size, position), true );
}
#else
static int _do_getxattr(EncFS_Context *, const string &cyName,
	tuple<const char *, void *, size_t> data)
{
    return ::getxattr( cyName.c_str(), data.get<0>(), 
                       data.get<1>(), data.get<2>());
}
int youcrypt_mount_getxattr( const char *path, const char *name,
	char *value, size_t size )
{
    return withCipherPath( "getxattr", path, _do_getxattr, 
                           make_tuple(name, (void *)value, size), true );
}
#endif


static int _do_listxattr(EncFS_Context *, const string &cyName,
	tuple<char *, size_t> data)
{
#ifdef XATTR_ADD_OPT
    int options = 0;
    int res = ::listxattr( cyName.c_str(), data.get<0>(), data.get<1>(),
            options );
#else
    int res = ::listxattr( cyName.c_str(), data.get<0>(), data.get<1>() );
#endif
    return (res == -1) ? -errno : res;
}

int youcrypt_mount_listxattr( const char *path, char *list, size_t size )
{
    return withCipherPath( "listxattr", path, _do_listxattr, 
            make_tuple(list, size), true );
}

static int _do_removexattr(EncFS_Context *, const string &cyName, const char *name)
{
#ifdef XATTR_ADD_OPT
    int options = 0;
    int res = ::removexattr( cyName.c_str(), name, options );
#else
    int res = ::removexattr( cyName.c_str(), name );
#endif
    return (res == -1) ? -errno : res;
}

int youcrypt_mount_removexattr( const char *path, const char *name )
{
   return withCipherPath( "removexattr", path, _do_removexattr, name );
}

#endif // HAVE_XATTR

// Fuse version >= 26 requires another argument to fuse_unmount, which we
// don't have.  So use the backward compatible call instead..
extern "C" void fuse_unmount_compat22(const char *mountpoint);
#    define fuse_unmount fuse_unmount_compat22


static bool _unmountFS(EncFS_Context *ctx)
{    
    fuse_unmount( ctx->mountPoint.c_str() );
    return true;
}

static const int ActivityCheckInterval = 10;
static
void *_idleMonitor(void *_arg)
{
    EncFS_Context *ctx = (EncFS_Context*)_arg;
    sigset_t setSigs;
    sigemptyset(&setSigs);
    sigaddset(&setSigs, SIGHUP);
    pthread_sigmask(SIG_BLOCK, &setSigs, 0);


    const int timeoutCycles = 60 * ctx->idleTimeout / ActivityCheckInterval;
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
	    if( openCount == 0 && _unmountFS( ctx ) )
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




#include <boost/iostreams/device/file_descriptor.hpp>
#include <boost/iostreams/stream.hpp>
#include <boost/archive/xml_oarchive.hpp>
#include <boost/serialization/nvp.hpp>
#include <boost/filesystem/fstream.hpp>

using boost::iostreams::file_descriptor_sink;
using boost::iostreams::stream;
using boost::archive::xml_oarchive;
using std::string;
using boost::serialization::make_nvp;

void youcrypt_mount_destroy(void *_ctx) {
    EncFS_Context *ectx = (EncFS_Context *)_ctx;
    if (ectx->folder) {
        // The following line is unfortunately wrong
        // since this is a really different process.
        ectx->folder->status = youcrypt::YoucryptFolder::initialized;

        // Instead we attempt to write to _fuseOut;
        file_descriptor_sink fdout(ectx->folder->_fuseOut, boost::iostreams::never_close_handle);
        stream<file_descriptor_sink> out(fdout);
        xml_oarchive xo(out);
        string msg = "unmount";
        xo & make_nvp("Message", msg); 
    }
}

void *youcrypt_mount_init(fuse_conn_info *conn) {
    conn->async_read = true;
    EncFS_Context *ctx = (EncFS_Context *)fuse_get_context()->private_data;
    
    sigset_t setSigs;
    sigemptyset(&setSigs);
    sigaddset(&setSigs, SIGHUP);
    pthread_sigmask(SIG_UNBLOCK, &setSigs, 0);
    
    
    conn->async_read = true;
    
    if (ctx->idleTimeout > 0) {
        ctx->running = true;
        int res = pthread_create (&ctx->monitorThread, 0, _idleMonitor,
                                  ((void *)ctx));
    }
    
    if (ctx->folder) {
        // Instead we attempt to write to _fuseOut;
        file_descriptor_sink fdout(ctx->folder->_fuseOut, boost::iostreams::never_close_handle);
        stream<file_descriptor_sink> out(fdout);
        xml_oarchive xo(out);
        string msg = "initialized";
        xo & make_nvp("Message", msg);
    }
    
    
    return ((void *)ctx);
}


