/***********************************
 * D Programming Language binding for FUSE. (https://github.com/olehlong/dfuse)
 * This file defines the kernel interface of FUSE
 * 
 * FUSE: Filesystem in Userspace
 * Copyright (C) 2001-2008  Miklos Szeredi <miklos@szeredi.hu>
 *
 * Version: 2.9.3
 * Authors: Oleh Havrys <oleh.long@gmail.com>
 * Date: Apr 15, 2014
 * License: MIT
 */
module dfuse.fuse_kernel;

extern (C):

enum fuse_opcode {
	FUSE_LOOKUP = 1,
	FUSE_FORGET = 2, /* no reply */
	FUSE_GETATTR = 3,
	FUSE_SETATTR = 4,
	FUSE_READLINK = 5,
	FUSE_SYMLINK = 6,
	FUSE_MKNOD = 8,
	FUSE_MKDIR = 9,
	FUSE_UNLINK = 10,
	FUSE_RMDIR = 11,
	FUSE_RENAME = 12,
	FUSE_LINK = 13,
	FUSE_OPEN = 14,
	FUSE_READ = 15,
	FUSE_WRITE = 16,
	FUSE_STATFS = 17,
	FUSE_RELEASE = 18,
	FUSE_FSYNC = 20,
	FUSE_SETXATTR = 21,
	FUSE_GETXATTR = 22,
	FUSE_LISTXATTR = 23,
	FUSE_REMOVEXATTR = 24,
	FUSE_FLUSH = 25,
	FUSE_INIT = 26,
	FUSE_OPENDIR = 27,
	FUSE_READDIR = 28,
	FUSE_RELEASEDIR = 29,
	FUSE_FSYNCDIR = 30,
	FUSE_GETLK = 31,
	FUSE_SETLK = 32,
	FUSE_SETLKW = 33,
	FUSE_ACCESS = 34,
	FUSE_CREATE = 35,
	FUSE_INTERRUPT = 36,
	FUSE_BMAP = 37,
	FUSE_DESTROY = 38,
	FUSE_IOCTL = 39,
	FUSE_POLL = 40,
	FUSE_NOTIFY_REPLY = 41,
	FUSE_BATCH_FORGET = 42,
	FUSE_FALLOCATE = 43,
	
	/* CUSE specific operations */
	CUSE_INIT = 4096
}

enum fuse_notify_code {
	FUSE_NOTIFY_POLL = 1,
	FUSE_NOTIFY_INVAL_INODE = 2,
	FUSE_NOTIFY_INVAL_ENTRY = 3,
	FUSE_NOTIFY_STORE = 4,
	FUSE_NOTIFY_RETRIEVE = 5,
	FUSE_NOTIFY_DELETE = 6,
	FUSE_NOTIFY_CODE_MAX = 7
}

/* The read buffer is required to be at least 8k, but may be much larger */
const uint FUSE_MIN_READ_BUFFER = 8192;
const uint FUSE_COMPAT_ENTRY_OUT_SIZE = 120;

/* Make sure all structures are padded to 64bit boundary, so 32bit
   userspace works under 64bit kernels */
struct fuse_attr {
	ulong ino;
	ulong size;
	ulong blocks;
	ulong atime;
	ulong mtime;
	ulong ctime;
	uint atimensec;
	uint mtimensec;
	uint ctimensec;
	uint mode;
	uint nlink;
	uint uid;
	uint gid;
	uint rdev;
	uint blksize;
	uint padding;
}

struct fuse_kstatfs {
	ulong blocks;
	ulong bfree;
	ulong bavail;
	ulong files;
	ulong ffree;
	uint bsize;
	uint namelen;
	uint frsize;
	uint padding;
	uint[6] spare;
}

struct fuse_file_lock {
	ulong start;
	ulong end;
	uint type;
	uint pid;
}

/**
 * Bitmasks for fuse_setattr_in.valid
 */
enum {
 	FATTR_MODE		= (1 << 0),
 	FATTR_UID		= (1 << 1),
 	FATTR_GID		= (1 << 2),
 	FATTR_SIZE		= (1 << 3),
 	FATTR_ATIME		= (1 << 4),
 	FATTR_MTIME		= (1 << 5),
 	FATTR_FH		= (1 << 6),
 	FATTR_ATIME_NOW	= (1 << 7),
 	FATTR_MTIME_NOW	= (1 << 8),
 	FATTR_LOCKOWNER	= (1 << 9)
}

/**
 * Flags returned by the OPEN request
 *
 * FOPEN_DIRECT_IO: bypass page cache for this open file
 * FOPEN_KEEP_CACHE: don't invalidate the data cache on open
 * FOPEN_NONSEEKABLE: the file is not seekable
 */
enum {
 	FOPEN_DIRECT_IO		= (1 << 0),
 	FOPEN_KEEP_CACHE	= (1 << 1),
 	FOPEN_NONSEEKABLE	= (1 << 2)
}

/**
 * INIT request/reply flags
 *
 * FUSE_POSIX_LOCKS: remote locking for POSIX file locks
 * FUSE_EXPORT_SUPPORT: filesystem handles lookups of "." and ".."
 * FUSE_DONT_MASK: don't apply umask to file mode on create operations
 * FUSE_FLOCK_LOCKS: remote locking for BSD style file locks
 */
enum {
 	FUSE_ASYNC_READ		= (1 << 0),
 	FUSE_POSIX_LOCKS	= (1 << 1),
 	FUSE_FILE_OPS		= (1 << 2),
 	FUSE_ATOMIC_O_TRUNC	= (1 << 3),
 	FUSE_EXPORT_SUPPORT	= (1 << 4),
 	FUSE_BIG_WRITES		= (1 << 5),
 	FUSE_DONT_MASK		= (1 << 6),
 	FUSE_FLOCK_LOCKS	= (1 << 10)
}

/**
 * CUSE INIT request/reply flags
 *
 * CUSE_UNRESTRICTED_IOCTL:  use unrestricted ioctl
 */
enum {
	CUSE_UNRESTRICTED_IOCTL = (1 << 0)
}

/**
 * Release flags
 */
enum {
 	FUSE_RELEASE_FLUSH			= (1 << 0),
 	FUSE_RELEASE_FLOCK_UNLOCK	= (1 << 1)
}

/**
 * Getattr flags
 */
enum {
	FUSE_GETATTR_FH	= (1 << 0)
}

/**
 * Lock flags
 */
enum {
	FUSE_LK_FLOCK	= (1 << 0)
}

/**
 * WRITE flags
 *
 * FUSE_WRITE_CACHE: delayed write from page cache, file handle is guessed
 * FUSE_WRITE_LOCKOWNER: lock_owner field is valid
 */
enum {
	FUSE_WRITE_CACHE		= (1 << 0),
	FUSE_WRITE_LOCKOWNER	= (1 << 1)
}

/**
 * Read flags
 */
enum {
	FUSE_READ_LOCKOWNER	= (1 << 1)
}

/**
 * Ioctl flags
 *
 * FUSE_IOCTL_COMPAT: 32bit compat ioctl on 64bit machine
 * FUSE_IOCTL_UNRESTRICTED: not restricted to well-formed ioctls, retry allowed
 * FUSE_IOCTL_RETRY: retry with new iovecs
 * FUSE_IOCTL_32BIT: 32bit ioctl
 * FUSE_IOCTL_DIR: is a directory
 *
 * FUSE_IOCTL_MAX_IOV: maximum of in_iovecs + out_iovecs
 */
enum {
 	FUSE_IOCTL_COMPAT		= (1 << 0),
 	FUSE_IOCTL_UNRESTRICTED	= (1 << 1),
 	FUSE_IOCTL_RETRY		= (1 << 2),
 	FUSE_IOCTL_32BIT		= (1 << 3),
 	FUSE_IOCTL_DIR			= (1 << 4),
 	FUSE_IOCTL_MAX_IOV		= 256
}

/**
 * Poll flags
 *
 * FUSE_POLL_SCHEDULE_NOTIFY: request poll notify
 */
enum {
	FUSE_POLL_SCHEDULE_NOTIFY = (1 << 0)
}

struct fuse_entry_out {
	ulong nodeid; /* Inode ID */
	ulong generation; /* Inode generation: nodeid:gen must
				   be unique for the fs's lifetime */
	ulong entry_valid; /* Cache timeout for the name */
	ulong attr_valid; /* Cache timeout for the attributes */
	uint entry_valid_nsec;
	uint attr_valid_nsec;
	fuse_attr attr;
}

struct fuse_forget_in {
	ulong nlookup;
}

struct fuse_forget_one {
	ulong nodeid;
	ulong nlookup;
}

struct fuse_batch_forget_in {
	uint count;
	uint dummy;
}

struct fuse_getattr_in {
	uint getattr_flags;
	uint dummy;
	ulong fh;
}

const uint FUSE_COMPAT_ATTR_OUT_SIZE = 96;

struct fuse_attr_out {
	ulong attr_valid; /* Cache timeout for the attributes */
	uint attr_valid_nsec;
	uint dummy;
	fuse_attr attr;
}

const uint FUSE_COMPAT_MKNOD_IN_SIZE = 8;

struct fuse_mknod_in {
	uint mode;
	uint rdev;
	uint umask;
	uint padding;
}

struct fuse_mkdir_in {
	uint mode;
	uint umask;
}

struct fuse_rename_in {
	ulong newdir;
}

struct fuse_link_in {
	ulong oldnodeid;
}

struct fuse_setattr_in {
	uint valid;
	uint padding;
	ulong fh;
	ulong size;
	ulong lock_owner;
	ulong atime;
	ulong mtime;
	ulong unused2;
	uint atimensec;
	uint mtimensec;
	uint unused3;
	uint mode;
	uint unused4;
	uint uid;
	uint gid;
	uint unused5;
}

struct fuse_open_in {
	uint flags;
	uint unused;
}

struct fuse_create_in {
	uint flags;
	uint mode;
	uint umask;
	uint padding;
}

struct fuse_open_out {
	ulong fh;
	uint open_flags;
	uint padding;
}

struct fuse_release_in {
	ulong fh;
	uint flags;
	uint release_flags;
	ulong lock_owner;
}

struct fuse_flush_in {
	ulong fh;
	uint unused;
	uint padding;
	ulong lock_owner;
}

struct fuse_read_in {
	ulong fh;
	ulong offset;
	uint size;
	uint read_flags;
	ulong lock_owner;
	uint flags;
	uint padding;
}

static uint FUSE_COMPAT_WRITE_IN_SIZE = 24;

struct fuse_write_in {
	ulong fh;
	ulong offset;
	uint size;
	uint write_flags;
	ulong lock_owner;
	uint flags;
	uint padding;
}

struct fuse_write_out {
	uint size;
	uint padding;
}

const uint FUSE_COMPAT_STATFS_SIZE = 48;

struct fuse_statfs_out {
	fuse_kstatfs st;
}

struct fuse_fsync_in {
	ulong fh;
	uint fsync_flags;
	uint padding;
}

struct fuse_setxattr_in {
	uint size;
	uint flags;
}

struct fuse_getxattr_in {
	uint size;
	uint padding;
}

struct fuse_getxattr_out {
	uint size;
	uint padding;
}

struct fuse_lk_in {
	ulong fh;
	ulong owner;
	fuse_file_lock lk;
	uint lk_flags;
	uint padding;
}

struct fuse_lk_out {
	fuse_file_lock lk;
}

struct fuse_access_in {
	uint mask;
	uint padding;
}

struct fuse_init_in {
	uint major;
	uint minor;
	uint max_readahead;
	uint flags;
}

struct fuse_init_out {
	uint major;
	uint minor;
	uint max_readahead;
	uint flags;
	ushort max_background;
	ushort congestion_threshold;
	uint max_write;
}

const uint CUSE_INIT_INFO_MAX = 4096;

struct cuse_init_in {
	uint major;
	uint minor;
	uint unused;
	uint flags;
}

struct cuse_init_out {
	uint major;
	uint minor;
	uint unused;
	uint flags;
	uint max_read;
	uint max_write;
	uint dev_major; /* chardev major */
	uint dev_minor; /* chardev minor */
	uint[10] spare;
}

struct fuse_interrupt_in {
	ulong unique;
}

struct fuse_bmap_in {
	ulong block;
	uint blocksize;
	uint padding;
}

struct fuse_bmap_out {
	ulong block;
}

struct fuse_ioctl_in {
	ulong fh;
	uint flags;
	uint cmd;
	ulong arg;
	uint in_size;
	uint out_size;
}

struct fuse_ioctl_iovec {
	ulong base;
	ulong len;
}

struct fuse_ioctl_out {
	int result;
	uint flags;
	uint in_iovs;
	uint out_iovs;
}

struct fuse_poll_in {
	ulong fh;
	ulong kh;
	uint flags;
	uint padding;
}

struct fuse_poll_out {
	uint revents;
	uint padding;
}

struct fuse_notify_poll_wakeup_out {
	ulong kh;
}

struct fuse_fallocate_in {
	ulong fh;
	ulong offset;
	ulong length;
	uint mode;
	uint padding;
}

struct fuse_in_header {
	uint len;
	uint opcode;
	ulong unique;
	ulong nodeid;
	uint uid;
	uint gid;
	uint pid;
	uint padding;
}

struct fuse_out_header {
	uint len;
	int error;
	ulong unique;
}

struct fuse_dirent {
	ulong ino;
	ulong off;
	uint namelen;
	uint type;
	string name;
}

/* // not converted
#define FUSE_NAME_OFFSET offsetof(struct fuse_dirent, name)
#define FUSE_DIRENT_ALIGN(x) (((x) + sizeof(__u64) - 1) & ~(sizeof(__u64) - 1))
#define FUSE_DIRENT_SIZE(d) \
	FUSE_DIRENT_ALIGN(FUSE_NAME_OFFSET + (d)->namelen)
*/

struct fuse_notify_inval_inode_out {
	ulong ino;
	long off;
	long len;
}

struct fuse_notify_inval_entry_out {
	ulong parent;
	uint namelen;
	uint padding;
}

struct fuse_notify_delete_out {
	ulong parent;
	ulong child;
	uint namelen;
	uint padding;
}

struct fuse_notify_store_out {
	ulong nodeid;
	ulong offset;
	uint size;
	uint padding;
}

struct fuse_notify_retrieve_out {
	ulong notify_unique;
	ulong nodeid;
	ulong offset;
	uint size;
	uint padding;
}

/* Matches the size of fuse_write_in */
struct fuse_notify_retrieve_in {
	ulong dummy1;
	ulong offset;
	uint size;
	uint dummy2;
	ulong dummy3;
	ulong dummy4;
}
