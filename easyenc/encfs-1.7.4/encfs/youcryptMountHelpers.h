#ifndef _youcrypt_mount_helpers_incl_
#define _youcrypt_mount_helpers_incl_


int youcrypt_mount_getattr(const char *path, struct stat *stbuf);
int youcrypt_mount_fgetattr(const char *path, struct stat *stbuf,
                            struct fuse_file_info *fi);
int youcrypt_mount_getdir(const char *path, fuse_dirh_t h, fuse_dirfil_t filler);
int youcrypt_mount_mknod(const char *path, mode_t mode, dev_t rdev);
int youcrypt_mount_mkdir(const char *path, mode_t mode);
int youcrypt_mount_unlink(const char *path);
int youcrypt_mount_rmdir(const char *path);
int youcrypt_mount_readlink(const char *path, char *buf, size_t size);
int youcrypt_mount_symlink(const char *from, const char *to);
int youcrypt_mount_link(const char *from, const char *to);
int youcrypt_mount_rename(const char *from, const char *to);
int youcrypt_mount_chmod(const char *path, mode_t mode);
int youcrypt_mount_chown(const char *path, uid_t uid, gid_t gid);
int youcrypt_mount_truncate(const char *path, off_t size);
int youcrypt_mount_ftruncate(const char *path, off_t size, 
                             struct fuse_file_info *fi);
int youcrypt_mount_utime(const char *path, struct utimbuf *buf);
int youcrypt_mount_utimens(const char *path, const struct timespec ts[2] );
int youcrypt_mount_open(const char *path, struct fuse_file_info *file);
int youcrypt_mount_flush(const char *path, struct fuse_file_info *fi);
int youcrypt_mount_release(const char *path, struct fuse_file_info *finfo);
int youcrypt_mount_read(const char *path, char *buf, size_t size, off_t offset,
                        struct fuse_file_info *file);
int youcrypt_mount_fsync(const char *path, int dataSync,
                         struct fuse_file_info *file);
int youcrypt_mount_write(const char *path, const char *buf, size_t size,
                         off_t offset, struct fuse_file_info *file);
int youcrypt_mount_statfs(const char *path, struct statvfs *st);

#ifdef HAVE_XATTR

#ifdef XATTR_ADD_OPT
int youcrypt_mount_setxattr( const char *path, const char *name,
                             const char *value, size_t size, 
                             int flags, uint32_t position );
#else
int youcrypt_mount_setxattr( const char *path, const char *name,
                             const char *value, size_t size, int flags );
#endif

#ifdef XATTR_ADD_OPT
int youcrypt_mount_getxattr( const char *path, const char *name,
                             char *value, size_t size, uint32_t position );
#else
int youcrypt_mount_getxattr( const char *path, const char *name,
                             char *value, size_t size );
#endif

int youcrypt_mount_listxattr( const char *path, char *list, size_t size );
int youcrypt_mount_removexattr( const char *path, const char *name );
#endif // HAVE_XATTR

void *youcrypt_mount_init(fuse_conn_info *conn);
void youcrypt_mount_destroy(void *_ctx);

#endif
