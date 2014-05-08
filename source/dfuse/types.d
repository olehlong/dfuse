/***********************************
 * D Programming Language binding for FUSE. (https://github.com/olehlong/dfuse)
 * This file defines FUSE types.
 * 
 * FUSE: Filesystem in Userspace
 * Copyright (C) 2001-2007  Miklos Szeredi <miklos@szeredi.hu>
 *
 * Version: 2.9.3
 * Authors: Oleh Havrys <oleh.long@gmail.com>
 * Date: Apr 15, 2014
 * License: MIT
 */
module dfuse.types;

version (Posix) {
    import  core.sys.posix.dirent, 
    		core.sys.posix.fcntl, 
    		core.sys.posix.sys.stat,
    		core.sys.posix.sys.time, 
    		core.sys.posix.unistd, 
    		core.sys.posix.utime, 
    		core.sys.posix.sys.types,
    		core.stdc.config,
    		core.stdc.time;
}
else
    static assert(false, "Module " ~ .stringof ~ " not implemented for this OS.");
/** fix names conflict */
alias core.sys.posix.fcntl.flock flock_t;

extern (C):

/** Handle for a FUSE filesystem */
struct fuse {
}

/** Structure containing a raw command */
struct fuse_cmd {
}

/** Extra context that may be needed by some filesystems
 *
 * The uid, gid and pid fields are not filled in case of a writepage
 * operation.
 */
struct fuse_context {
	/** Pointer to the fuse object */
	fuse* _fuse;
	
	/** User ID of the calling process */
	uid_t uid;
	
	/** Group ID of the calling process */
	gid_t gid;
	
	/** Thread ID of the calling process */
	pid_t pid;
	
	/** Private filesystem data */
	void* private_data;
	
	/** Umask of the calling process (introduced in version 2.8) */
	mode_t umask;
}

/**
 * Fuse filesystem object
 *
 * This is opaque object represents a filesystem layer
 */
struct fuse_fs {
}

struct fusemod_so {
}

// from file: fuse_lowlevel

/** Inode number type */
alias ulong fuse_ino_t;

struct fuse_req {
}

/** Request pointer type */
alias fuse_req* fuse_req_t;

/**
 * Session
 *
 * This provides hooks for processing requests, and exiting
 */
struct fuse_session {
}

/**
 * Channel
 *
 * A communication channel, providing hooks for sending and receiving
 * messages
 */
struct fuse_chan {
}

/** Directory entry parameters supplied to fuse_reply_entry() */
struct fuse_entry_param {
	/** Unique inode number
	 *
	 * In lookup, zero means negative entry (from version 2.5)
	 * Returning ENOENT also means negative entry, but by setting zero
	 * ino the kernel may cache negative entries for entry_timeout
	 * seconds.
	 */
	fuse_ino_t ino;
	
	/** Generation number for this entry.
	 *
	 * If the file system will be exported over NFS, the
	 * ino/generation pairs need to be unique over the file
	 * system's lifetime (rather than just the mount time). So if
	 * the file system reuses an inode after it has been deleted,
	 * it must assign a new, previously unused generation number
	 * to the inode at the same time.
	 *
	 * The generation must be non-zero, otherwise FUSE will treat
	 * it as an error.
	 *
	 */
	ulong generation;
	
	/** Inode attributes.
	 *
	 * Even if attr_timeout == 0, attr must be correct. For example,
	 * for open(), FUSE uses attr.st_size from lookup() to determine
	 * how many bytes to request. If this value is not correct,
	 * incorrect data will be returned.
	 */
	stat_t attr;
	
	/** Validity timeout (in seconds) for the attributes */
	double attr_timeout;
	
	/** Validity timeout (in seconds) for the name */
	double entry_timeout;
}

/** Additional context associated with requests */
struct fuse_ctx {
	/** User ID of the calling process */
	uid_t uid;
	
	/** Group ID of the calling process */
	gid_t gid;
	
	/** Thread ID of the calling process */
	pid_t pid;
	
	/** Umask of the calling process (introduced in version 2.8) */
	mode_t umask;
}

struct fuse_forget_data {
	ulong ino;
	ulong nlookup;
}

/* 'to_set' flags in setattr */
enum {
	FUSE_SET_ATTR_MODE		= (1 << 0),
	FUSE_SET_ATTR_UID		= (1 << 1),
	FUSE_SET_ATTR_GID		= (1 << 2),
	FUSE_SET_ATTR_SIZE		= (1 << 3),
	FUSE_SET_ATTR_ATIME		= (1 << 4),
	FUSE_SET_ATTR_MTIME		= (1 << 5),
	FUSE_SET_ATTR_ATIME_NOW	= (1 << 7),
	FUSE_SET_ATTR_MTIME_NOW	= (1 << 8)
}

// from file: cuse_lowlevel

// fuse_session dup

struct cuse_info {
	uint dev_major;
	uint dev_minor;
	uint dev_info_argc;
	const(char*)* dev_info_argv;
	uint flags;
}

// from file: fuse_common
/**
 * Buffer flags
 */
enum fuse_buf_flags {
	/**
	 * Buffer contains a file descriptor
	 *
	 * If this flag is set, the .fd field is valid, otherwise the
	 * .mem fields is valid.
	 */
	FUSE_BUF_IS_FD = (1 << 1),
	
	/**
	 * Seek on the file descriptor
	 *
	 * If this flag is set then the .pos field is valid and is
	 * used to seek to the given offset before performing
	 * operation on file descriptor.
	 */
	FUSE_BUF_FD_SEEK = (1 << 2),
	
	/**
	 * Retry operation on file descriptor
	 *
	 * If this flag is set then retry operation on file descriptor
	 * until .size bytes have been copied or an error or EOF is
	 * detected.
	 */
	FUSE_BUF_FD_RETRY = (1 << 3)
}

/**
 * Buffer copy flags
 */
enum fuse_buf_copy_flags {
	/**
	 * Don't use splice(2)
	 *
	 * Always fall back to using read and write instead of
	 * splice(2) to copy data from one file descriptor to another.
	 *
	 * If this flag is not set, then only fall back if splice is
	 * unavailable.
	 */
	FUSE_BUF_NO_SPLICE = (1 << 1),
	
	/**
	 * Force splice
	 *
	 * Always use splice(2) to copy data from one file descriptor
	 * to another.  If splice is not available, return -EINVAL.
	 */
	FUSE_BUF_FORCE_SPLICE = (1 << 2),
	
	/**
	 * Try to move data with splice.
	 *
	 * If splice is used, try to move pages from the source to the
	 * destination instead of copying.  See documentation of
	 * SPLICE_F_MOVE in splice(2) man page.
	 */
	FUSE_BUF_SPLICE_MOVE = (1 << 3),
	
	/**
	 * Don't block on the pipe when copying data with splice
	 *
	 * Makes the operations on the pipe non-blocking (if the pipe
	 * is full or empty).  See SPLICE_F_NONBLOCK in the splice(2)
	 * man page.
	 */
	FUSE_BUF_SPLICE_NONBLOCK = (1 << 4)
}

/**
 * Information about open files
 *
 * Changed in version 2.5
 */
struct fuse_file_info {
	/** Open flags.	 Available in open() and release() */
	int flags;
	
	/** Old file handle, don't use */
	ulong fh_old;
	
	/** In case of a write operation indicates if this was caused by a
	    writepage */
	int writepage;
	
	/** Can be filled in by open, to use direct I/O on this file.
	    Introduced in version 2.4 */
	uint direct_io = 1;
	
	/** Can be filled in by open, to indicate, that cached file data
	    need not be invalidated.  Introduced in version 2.4 */
	uint keep_cache = 1;
	
	/** Indicates a flush operation.  Set in flush operation, also
	    maybe set in highlevel lock operation and lowlevel release
	    operation.	Introduced in version 2.6 */
	uint flush = 1;
	
	/** Can be filled in by open, to indicate that the file is not
	    seekable.  Introduced in version 2.8 */
	uint nonseekable = 1;
	
	/** Indicates that flock locks for this file should be
	   released.  If set, lock_owner shall contain a valid value.
	   May only be set in ->release().  Introduced in version
	   2.9 */
	uint flock_release = 1;
	
	/** Padding.  Do not use*/
	uint padding = 27;
	
	/** File handle.  May be filled in by filesystem in open().
	    Available in all other file operations */
	ulong fh;
	
	/** Lock owner id.  Available in locking operations and flush */
	ulong lock_owner;
}

/**
 * Capability bits for 'fuse_conn_info.capable' and 'fuse_conn_info.want'
 *
 * FUSE_CAP_ASYNC_READ: filesystem supports asynchronous read requests
 * FUSE_CAP_POSIX_LOCKS: filesystem supports "remote" locking
 * FUSE_CAP_ATOMIC_O_TRUNC: filesystem handles the O_TRUNC open flag
 * FUSE_CAP_EXPORT_SUPPORT: filesystem handles lookups of "." and ".."
 * FUSE_CAP_BIG_WRITES: filesystem can handle write size larger than 4kB
 * FUSE_CAP_DONT_MASK: don't apply umask to file mode on create operations
 * FUSE_CAP_SPLICE_WRITE: ability to use splice() to write to the fuse device
 * FUSE_CAP_SPLICE_MOVE: ability to move data to the fuse device with splice()
 * FUSE_CAP_SPLICE_READ: ability to use splice() to read from the fuse device
 * FUSE_CAP_IOCTL_DIR: ioctl support on directories
 */
enum {
 	FUSE_CAP_ASYNC_READ		= (1 << 0),
 	FUSE_CAP_POSIX_LOCKS	= (1 << 1),
 	FUSE_CAP_ATOMIC_O_TRUNC = (1 << 3),
 	FUSE_CAP_EXPORT_SUPPORT = (1 << 4),
 	FUSE_CAP_BIG_WRITES		= (1 << 5),
 	FUSE_CAP_DONT_MASK		= (1 << 6),
 	FUSE_CAP_SPLICE_WRITE	= (1 << 7),
 	FUSE_CAP_SPLICE_MOVE	= (1 << 8),
 	FUSE_CAP_SPLICE_READ	= (1 << 9),
 	FUSE_CAP_FLOCK_LOCKS	= (1 << 10),
 	FUSE_CAP_IOCTL_DIR		= (1 << 11)
}

/**
 * Ioctl flags
 *
 * FUSE_IOCTL_COMPAT: 32bit compat ioctl on 64bit machine
 * FUSE_IOCTL_UNRESTRICTED: not restricted to well-formed ioctls, retry allowed
 * FUSE_IOCTL_RETRY: retry with new iovecs
 * FUSE_IOCTL_DIR: is a directory
 *
 * FUSE_IOCTL_MAX_IOV: maximum of in_iovecs + out_iovecs
 */

enum {
 	FUSE_IOCTL_COMPAT		= (1 << 0),
 	FUSE_IOCTL_UNRESTRICTED = (1 << 1),
 	FUSE_IOCTL_RETRY		= (1 << 2),
 	FUSE_IOCTL_DIR			= (1 << 4),
 	FUSE_IOCTL_MAX_IOV		= 256
}

/**
 * Connection information, passed to the ->init() method
 *
 * Some of the elements are read-write, these can be changed to
 * indicate the value requested by the filesystem.  The requested
 * value must usually be smaller than the indicated value.
 */
struct fuse_conn_info {
	/**
	 * Major version of the protocol (read-only)
	 */
	uint proto_major;
	
	/**
	 * Minor version of the protocol (read-only)
	 */
	uint proto_minor;
	
	/**
	 * Is asynchronous read supported (read-write)
	 */
	uint async_read;
	
	/**
	 * Maximum size of the write buffer
	 */
	uint max_write;
	
	/**
	 * Maximum readahead
	 */
	uint max_readahead;
	
	/**
	 * Capability flags, that the kernel supports
	 */
	uint capable;
	
	/**
	 * Capability flags, that the filesystem wants to enable
	 */
	uint want;
	
	/**
	 * Maximum number of backgrounded requests
	 */
	uint max_background;
	
	/**
	 * Kernel congestion threshold parameter
	 */
	uint congestion_threshold;
	
	/**
	 * For future use.
	 */
	uint[23] reserved;
}

// from file: fuse_session

struct fuse_pollhandle {
}

/**
 * Single data buffer
 *
 * Generic data buffer for I/O, extended attributes, etc...  Data may
 * be supplied as a memory pointer or as a file descriptor
 */
struct fuse_buf {
	/**
	 * Size of data in bytes
	 */
	size_t size;
	
	/**
	 * Buffer flags
	 */
	fuse_buf_flags flags;
	
	/**
	 * Memory pointer
	 *
	 * Used unless FUSE_BUF_IS_FD flag is set.
	 */
	void* mem;
	
	/**
	 * File descriptor
	 *
	 * Used if FUSE_BUF_IS_FD flag is set.
	 */
	int fd;
	
	/**
	 * File position
	 *
	 * Used if FUSE_BUF_FD_SEEK flag is set.
	 */
	off_t pos;
}

/**
 * Data buffer vector
 *
 * An array of data buffers, each containing a memory pointer or a
 * file descriptor.
 *
 * Allocate dynamically to add more than one buffer.
 */
struct fuse_bufvec {
	/**
	 * Number of buffers in the array
	 */
	size_t count;
	
	/**
	 * Index of current buffer within the array
	 */
	size_t idx;
	
	/**
	 * Current offset within the current buffer
	 */
	size_t off;
	
	/**
	 * Array of buffers
	 */
	fuse_buf[1] buf;
}

/**
 * Argument list
 */
struct fuse_args {
	/** Argument count */
	int argc;

	/** Argument vector.  NULL terminated */
	char** argv;

	/** Is 'argv' allocated? */
	int allocated;
}

struct fuse_dirhandle {
}

// from file: fuse_opt

/**
 * Option description
 *
 * This structure describes a single option, and action associated
 * with it, in case it matches.
 *
 * More than one such match may occur, in which case the action for
 * each match is executed.
 *
 * There are three possible actions in case of a match:
 *
 * i) An integer (int or unsigned) variable determined by 'offset' is
 *    set to 'value'
 *
 * ii) The processing function is called, with 'value' as the key
 *
 * iii) An integer (any) or string (char *) variable determined by
 *    'offset' is set to the value of an option parameter
 *
 * 'offset' should normally be either set to
 *
 *  - 'offsetof(struct foo, member)'  actions i) and iii)
 *
 *  - -1			      action ii)
 *
 * The 'offsetof()' macro is defined in the <stddef.h> header.
 *
 * The template determines which options match, and also have an
 * effect on the action.  Normally the action is either i) or ii), but
 * if a format is present in the template, then action iii) is
 * performed.
 *
 * The types of templates are:
 *
 * 1) "-x", "-foo", "--foo", "--foo-bar", etc.	These match only
 *   themselves.  Invalid values are "--" and anything beginning
 *   with "-o"
 *
 * 2) "foo", "foo-bar", etc.  These match "-ofoo", "-ofoo-bar" or
 *    the relevant option in a comma separated option list
 *
 * 3) "bar=", "--foo=", etc.  These are variations of 1) and 2)
 *    which have a parameter
 *
 * 4) "bar=%s", "--foo=%lu", etc.  Same matching as above but perform
 *    action iii).
 *
 * 5) "-x ", etc.  Matches either "-xparam" or "-x param" as
 *    two separate arguments
 *
 * 6) "-x %s", etc.  Combination of 4) and 5)
 *
 * If the format is "%s", memory is allocated for the string unlike
 * with scanf().
 */
struct fuse_opt {
	/** Matching template and optional parameter formatting */
	const(char)* templ;
	
	/**
	 * Offset of variable within 'data' parameter of fuse_opt_parse()
	 * or -1
	 */
	ulong offset;
	
	/**
	 * Value to set the variable to, or to be passed as 'key' to the
	 * processing function.	 Ignored if template has a format
	 */
	int value;
}

