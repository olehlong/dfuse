/***********************************
 * D Programming Language binding for FUSE. (https://github.com/olehlong/dfuse)
 * This file defines the library interface of FUSE.
 * 
 * FUSE: Filesystem in Userspace
 * Copyright (C) 2001-2007  Miklos Szeredi <miklos@szeredi.hu>
 *
 * Version: 2.9.3
 * Authors: Oleh Havrys <oleh.long@gmail.com>
 * Date: Apr 15, 2014
 * License: MIT
 */
module dfuse.fuse;

version (Posix) {
    import  core.sys.posix.sys.types,
    		core.sys.posix.sys.stat,
    		core.sys.posix.sys.statvfs,
    		core.sys.posix.unistd,
    		core.sys.posix.utime,
    		core.stdc.time,
    		core.sys.posix.time;
    		
}
else
    static assert(false, "Module " ~ .stringof ~ " not implemented for this OS.");

public import dfuse.types;
public import dfuse.fuse_common;

extern (C):

//const int FUSE_USE_VERSION = 29;

/** Function to add an entry in a readdir() operation
 *
 * @param buf the buffer passed to the readdir() operation
 * @param name the file name of the directory entry
 * @param stat file attributes, can be NULL
 * @param off offset of the next entry or zero
 * @return 1 if buffer is full, zero otherwise
 */
alias int function (void*, const(char)*, const(stat_t)*, long) fuse_fill_dir_t;

/* Used by deprecated getdir() method */
alias fuse_dirhandle* fuse_dirh_t;
alias int function (fuse_dirhandle*, const(char)*, int, ulong) fuse_dirfil_t;

/**
 * The file system operations:
 *
 * Most of these should work very similarly to the well known UNIX
 * file system operations.  A major exception is that instead of
 * returning an error in 'errno', the operation should return the
 * negated error value (-errno) directly.
 *
 * All methods are optional, but some are essential for a useful
 * filesystem (e.g. getattr).  Open, flush, release, fsync, opendir,
 * releasedir, fsyncdir, access, create, ftruncate, fgetattr, lock,
 * init and destroy are special purpose methods, without which a full
 * featured filesystem can still be implemented.
 *
 * Almost all operations take a path which can be of any length.
 *
 * Changed in fuse 2.8.0 (regardless of API version)
 * Previously, paths were limited to a length of PATH_MAX.
 *
 * See http://fuse.sourceforge.net/wiki/ for more information.  There
 * is also a snapshot of the relevant wiki pages in the doc/ folder.
 */
struct fuse_operations {
	/** Get file attributes.
	 *
	 * Similar to stat().  The 'st_dev' and 'st_blksize' fields are
	 * ignored.	 The 'st_ino' field is ignored except if the 'use_ino'
	 * mount option is given.
	 */
	int function (const(char)*, stat_t*) getattr;
	
	/** Read the target of a symbolic link
	 *
	 * The buffer should be filled with a null terminated string.  The
	 * buffer size argument includes the space for the terminating
	 * null character.	If the linkname is too long to fit in the
	 * buffer, it should be truncated.	The return value should be 0
	 * for success.
	 */
	int function (const(char)*, char*, size_t) readlink;
	
	/* Deprecated, use readdir() instead */
	int function (const(char)*, fuse_dirh_t, fuse_dirfil_t) getdir;
	
	/** Create a file node
	 *
	 * This is called for creation of all non-directory, non-symlink
	 * nodes.  If the filesystem defines a create() method, then for
	 * regular files that will be called instead.
	 */
	int function (const(char)*, mode_t, dev_t) mknod;
	
	/** Create a directory 
	 *
	 * Note that the mode argument may not have the type specification
	 * bits set, i.e. S_ISDIR(mode) can be false.  To obtain the
	 * correct directory type bits use  mode|S_IFDIR
	 * */
	int function (const(char)*, mode_t) mkdir;
	
	/** Remove a file */
	int function (const(char)*) unlink;
	
	/** Remove a directory */
	int function (const(char)*) rmdir;
	
	/** Create a symbolic link */
	int function (const(char)*, const(char)*) symlink;
	
	/** Rename a file */
	int function (const(char)*, const(char)*) rename;
	
	/** Create a hard link to a file */
	int function (const(char)*, const(char)*) link;
	
	/** Change the permission bits of a file */
	int function (const(char)*, mode_t) chmod;
	
	/** Change the owner and group of a file */
	int function (const(char)*, uid_t, gid_t) chown;
	
	/** Change the size of a file */
	int function (const(char)*, off_t) truncate;
	
	/** Change the access and/or modification times of a file
	 *
	 * Deprecated, use utimens() instead.
	 */
	int function (const(char)*, utimbuf*) utime;
	
	/** File open operation
	 *
	 * No creation (O_CREAT, O_EXCL) and by default also no
	 * truncation (O_TRUNC) flags will be passed to open(). If an
	 * application specifies O_TRUNC, fuse first calls truncate()
	 * and then open(). Only if 'atomic_o_trunc' has been
	 * specified and kernel version is 2.6.24 or later, O_TRUNC is
	 * passed on to open.
	 *
	 * Unless the 'default_permissions' mount option is given,
	 * open should check if the operation is permitted for the
	 * given flags. Optionally open may also return an arbitrary
	 * filehandle in the fuse_file_info structure, which will be
	 * passed to all file operations.
	 *
	 * Changed in version 2.2
	 */
	int function (const(char)*, fuse_file_info*) open;
	
	/** Read data from an open file
	 *
	 * Read should return exactly the number of bytes requested except
	 * on EOF or error, otherwise the rest of the data will be
	 * substituted with zeroes.	 An exception to this is when the
	 * 'direct_io' mount option is specified, in which case the return
	 * value of the read system call will reflect the return value of
	 * this operation.
	 *
	 * Changed in version 2.2
	 */
	int function (const(char)*, char*, size_t, off_t, fuse_file_info*) read;
	
	/** Write data to an open file
	 *
	 * Write should return exactly the number of bytes requested
	 * except on error.	 An exception to this is when the 'direct_io'
	 * mount option is specified (see read operation).
	 *
	 * Changed in version 2.2
	 */
	int function (const(char)*, const(char)*, size_t, off_t, fuse_file_info*) write;
	
	/** Get file system statistics
	 *
	 * The 'f_frsize', 'f_favail', 'f_fsid' and 'f_flag' fields are ignored
	 *
	 * Replaced 'struct statfs' parameter with 'struct statvfs' in
	 * version 2.5
	 */
	int function (const(char)*, statvfs_t*) statfs;
	
	/** Possibly flush cached data
	 *
	 * BIG NOTE: This is not equivalent to fsync().  It's not a
	 * request to sync dirty data.
	 *
	 * Flush is called on each close() of a file descriptor.  So if a
	 * filesystem wants to return write errors in close() and the file
	 * has cached dirty data, this is a good place to write back data
	 * and return any errors.  Since many applications ignore close()
	 * errors this is not always useful.
	 *
	 * NOTE: The flush() method may be called more than once for each
	 * open().	This happens if more than one file descriptor refers
	 * to an opened file due to dup(), dup2() or fork() calls.	It is
	 * not possible to determine if a flush is final, so each flush
	 * should be treated equally.  Multiple write-flush sequences are
	 * relatively rare, so this shouldn't be a problem.
	 *
	 * Filesystems shouldn't assume that flush will always be called
	 * after some writes, or that if will be called at all.
	 *
	 * Changed in version 2.2
	 */
	int function (const(char)*, fuse_file_info*) flush;
	
	/** Release an open file
	 *
	 * Release is called when there are no more references to an open
	 * file: all file descriptors are closed and all memory mappings
	 * are unmapped.
	 *
	 * For every open() call there will be exactly one release() call
	 * with the same flags and file descriptor.	 It is possible to
	 * have a file opened more than once, in which case only the last
	 * release will mean, that no more reads/writes will happen on the
	 * file.  The return value of release is ignored.
	 *
	 * Changed in version 2.2
	 */
	int function (const(char)*, fuse_file_info*) release;
	
	/** Synchronize file contents
	 *
	 * If the datasync parameter is non-zero, then only the user data
	 * should be flushed, not the meta data.
	 *
	 * Changed in version 2.2
	 */
	int function (const(char)*, int, fuse_file_info*) fsync;
	
	/** Set extended attributes */
	int function (const(char)*, const(char)*, const(char)*, size_t, int) setxattr;
	
	/** Get extended attributes */
	int function (const(char)*, const(char)*, char*, size_t) getxattr;
	
	/** List extended attributes */
	int function (const(char)*, char*, size_t) listxattr;
	
	/** Remove extended attributes */
	int function (const(char)*, const(char)*) removexattr;
	
	/** Open directory
	 *
	 * Unless the 'default_permissions' mount option is given,
	 * this method should check if opendir is permitted for this
	 * directory. Optionally opendir may also return an arbitrary
	 * filehandle in the fuse_file_info structure, which will be
	 * passed to readdir, closedir and fsyncdir.
	 *
	 * Introduced in version 2.3
	 */
	int function (const(char)*, fuse_file_info*) opendir;
	
	/** Read directory
	 *
	 * This supersedes the old getdir() interface.  New applications
	 * should use this.
	 *
	 * The filesystem may choose between two modes of operation:
	 *
	 * 1) The readdir implementation ignores the offset parameter, and
	 * passes zero to the filler function's offset.  The filler
	 * function will not return '1' (unless an error happens), so the
	 * whole directory is read in a single readdir operation.  This
	 * works just like the old getdir() method.
	 *
	 * 2) The readdir implementation keeps track of the offsets of the
	 * directory entries.  It uses the offset parameter and always
	 * passes non-zero offset to the filler function.  When the buffer
	 * is full (or an error happens) the filler function will return
	 * '1'.
	 *
	 * Introduced in version 2.3
	 */
	int function (const(char)*, void*, fuse_fill_dir_t, off_t, fuse_file_info*) readdir;
	
	/** Release directory
	 *
	 * Introduced in version 2.3
	 */
	int function (const(char)*, fuse_file_info*) releasedir;
	
	/** Synchronize directory contents
	 *
	 * If the datasync parameter is non-zero, then only the user data
	 * should be flushed, not the meta data
	 *
	 * Introduced in version 2.3
	 */
	int function (const(char)*, int, fuse_file_info*) fsyncdir;
	
	/**
	 * Initialize filesystem
	 *
	 * The return value will passed in the private_data field of
	 * fuse_context to all file operations and as a parameter to the
	 * destroy() method.
	 *
	 * Introduced in version 2.3
	 * Changed in version 2.6
	 */
	void* function (fuse_conn_info*) init;
	
	/**
	 * Clean up filesystem
	 *
	 * Called on filesystem exit.
	 *
	 * Introduced in version 2.3
	 */
	void function (void*) destroy;
	
	/**
	 * Check file access permissions
	 *
	 * This will be called for the access() system call.  If the
	 * 'default_permissions' mount option is given, this method is not
	 * called.
	 *
	 * This method is not called under Linux kernel versions 2.4.x
	 *
	 * Introduced in version 2.5
	 */
	int function (const(char)*, int) access;
	
	/**
	 * Create and open a file
	 *
	 * If the file does not exist, first create it with the specified
	 * mode, and then open it.
	 *
	 * If this method is not implemented or under Linux kernel
	 * versions earlier than 2.6.15, the mknod() and open() methods
	 * will be called instead.
	 *
	 * Introduced in version 2.5
	 */
	int function (const(char)*, mode_t, fuse_file_info*) create;
	
	/**
	 * Change the size of an open file
	 *
	 * This method is called instead of the truncate() method if the
	 * truncation was invoked from an ftruncate() system call.
	 *
	 * If this method is not implemented or under Linux kernel
	 * versions earlier than 2.6.15, the truncate() method will be
	 * called instead.
	 *
	 * Introduced in version 2.5
	 */
	int function (const(char)*, off_t, fuse_file_info*) ftruncate;
	
	/**
	 * Get attributes from an open file
	 *
	 * This method is called instead of the getattr() method if the
	 * file information is available.
	 *
	 * Currently this is only called after the create() method if that
	 * is implemented (see above).  Later it may be called for
	 * invocations of fstat() too.
	 *
	 * Introduced in version 2.5
	 */
	int function (const(char)*, stat_t*, fuse_file_info*) fgetattr;
	
	/**
	 * Perform POSIX file locking operation
	 *
	 * The cmd argument will be either F_GETLK, F_SETLK or F_SETLKW.
	 *
	 * For the meaning of fields in 'struct flock' see the man page
	 * for fcntl(2).  The l_whence field will always be set to
	 * SEEK_SET.
	 *
	 * For checking lock ownership, the 'fuse_file_info->owner'
	 * argument must be used.
	 *
	 * For F_GETLK operation, the library will first check currently
	 * held locks, and if a conflicting lock is found it will return
	 * information without calling this method.	 This ensures, that
	 * for local locks the l_pid field is correctly filled in.	The
	 * results may not be accurate in case of race conditions and in
	 * the presence of hard links, but it's unlikely that an
	 * application would rely on accurate GETLK results in these
	 * cases.  If a conflicting lock is not found, this method will be
	 * called, and the filesystem may fill out l_pid by a meaningful
	 * value, or it may leave this field zero.
	 *
	 * For F_SETLK and F_SETLKW the l_pid field will be set to the pid
	 * of the process performing the locking operation.
	 *
	 * Note: if this method is not implemented, the kernel will still
	 * allow file locking to work locally.  Hence it is only
	 * interesting for network filesystems and similar.
	 *
	 * Introduced in version 2.6
	 */
	int function (const(char)*, fuse_file_info*, int, flock_t*) lock;
	
	/**
	 * Change the access and modification times of a file with
	 * nanosecond resolution
	 *
	 * This supersedes the old utime() interface.  New applications
	 * should use this.
	 *
	 * See the utimensat(2) man page for details.
	 *
	 * Introduced in version 2.6
	 */
	int function (const(char)*, const(timespec)[2]) utimens;
	
	/**
	 * Map block index within file to block index within device
	 *
	 * Note: This makes sense only for block device backed filesystems
	 * mounted with the 'blkdev' option
	 *
	 * Introduced in version 2.6
	 */
	int function (const(char)*, size_t, ulong*) bmap;
	
	/**
	 * Flag indicating that the filesystem can accept a NULL path
	 * as the first argument for the following operations:
	 *
	 * read, write, flush, release, fsync, readdir, releasedir,
	 * fsyncdir, ftruncate, fgetattr, lock, ioctl and poll
	 *
	 * If this flag is set these operations continue to work on
	 * unlinked files even if "-ohard_remove" option was specified.
	 */
	bool flag_nullpath_ok;
	
	/**
	 * Flag indicating that the path need not be calculated for
	 * the following operations:
	 *
	 * read, write, flush, release, fsync, readdir, releasedir,
	 * fsyncdir, ftruncate, fgetattr, lock, ioctl and poll
	 *
	 * Closely related to flag_nullpath_ok, but if this flag is
	 * set then the path will not be calculaged even if the file
	 * wasn't unlinked.  However the path can still be non-NULL if
	 * it needs to be calculated for some other reason.
	 */
	bool flag_nopath;
	
	/**
	 * Flag indicating that the filesystem accepts special
	 * UTIME_NOW and UTIME_OMIT values in its utimens operation.
	 */
	bool flag_utime_omit_ok;
	
	/**
	 * Reserved flags, don't set
	 */
	uint flag_reserved;
	
	/**
	 * Ioctl
	 *
	 * flags will have FUSE_IOCTL_COMPAT set for 32bit ioctls in
	 * 64bit environment.  The size and direction of data is
	 * determined by _IOC_*() decoding of cmd.  For _IOC_NONE,
	 * data will be NULL, for _IOC_WRITE data is out area, for
	 * _IOC_READ in area and if both are set in/out area.  In all
	 * non-NULL cases, the area is of _IOC_SIZE(cmd) bytes.
	 *
	 * Introduced in version 2.8
	 */
	int function (const(char)*, int, void*, fuse_file_info*, uint, void*) ioctl;
	
	/**
	 * Poll for IO readiness events
	 *
	 * Note: If ph is non-NULL, the client should notify
	 * when IO readiness events occur by calling
	 * fuse_notify_poll() with the specified ph.
	 *
	 * Regardless of the number of times poll with a non-NULL ph
	 * is received, single notification is enough to clear all.
	 * Notifying more times incurs overhead but doesn't harm
	 * correctness.
	 *
	 * The callee is responsible for destroying ph with
	 * fuse_pollhandle_destroy() when no longer in use.
	 *
	 * Introduced in version 2.8
	 */
	int function (const(char)*, fuse_file_info*, fuse_pollhandle*, uint*) poll;
	
	/** Write contents of buffer to an open file
	 *
	 * Similar to the write() method, but data is supplied in a
	 * generic buffer.  Use fuse_buf_copy() to transfer data to
	 * the destination.
	 *
	 * Introduced in version 2.9
	 */
	int function (const(char)*, fuse_bufvec*, off_t, fuse_file_info*) write_buf;
	
	/** Store data from an open file in a buffer
	 *
	 * Similar to the read() method, but data is stored and
	 * returned in a generic buffer.
	 *
	 * No actual copying of data has to take place, the source
	 * file descriptor may simply be stored in the buffer for
	 * later data transfer.
	 *
	 * The buffer must be allocated dynamically and stored at the
	 * location pointed to by bufp.  If the buffer contains memory
	 * regions, they too must be allocated using malloc().  The
	 * allocated memory will be freed by the caller.
	 *
	 * Introduced in version 2.9
	 */
	int function (const(char)*, fuse_bufvec**, size_t, off_t, fuse_file_info*) read_buf;
	
	/**
	 * Perform BSD file locking operation
	 *
	 * The op argument will be either LOCK_SH, LOCK_EX or LOCK_UN
	 *
	 * Nonblocking requests will be indicated by ORing LOCK_NB to
	 * the above operations
	 *
	 * For more information see the flock(2) manual page.
	 *
	 * Additionally fi->owner will be set to a value unique to
	 * this open file.  This same value will be supplied to
	 * ->release() when the file is released.
	 *
	 * Note: if this method is not implemented, the kernel will still
	 * allow file locking to work locally.  Hence it is only
	 * interesting for network filesystems and similar.
	 *
	 * Introduced in version 2.9
	 */
	int function (const(char)*, fuse_file_info*, int) flock;
	
	/**
	 * Allocates space for an open file
	 *
	 * This function ensures that required space is allocated for specified
	 * file.  If this function returns success then any subsequent write
	 * request to specified range is guaranteed not to fail because of lack
	 * of space on the file system media.
	 *
	 * Introduced in version 2.9.1
	 */
	int function (const(char)*, int, off_t, off_t, fuse_file_info*) fallocate;
}	

/**
 * Create a new FUSE filesystem.
 *
 * @param ch the communication channel
 * @param args argument vector
 * @param op the filesystem operations
 * @param op_size the size of the fuse_operations structure
 * @param user_data user data supplied in the context during the init() method
 * @return the created FUSE handle
 */
fuse* fuse_new (fuse_chan* ch, fuse_args* args, const(fuse_operations)* op, size_t op_size, void* user_data);

/**
 * Destroy the FUSE handle.
 *
 * The communication channel attached to the handle is also destroyed.
 *
 * NOTE: This function does not unmount the filesystem.	 If this is
 * needed, call fuse_unmount() before calling this function.
 *
 * @param f the FUSE handle
 */
void fuse_destroy (fuse* f);

/**
 * FUSE event loop.
 *
 * Requests from the kernel are processed, and the appropriate
 * operations are called.
 *
 * @param f the FUSE handle
 * @return 0 if no error occurred, -1 otherwise
 */
int fuse_loop (fuse* f);

/**
 * Exit from event loop
 *
 * @param f the FUSE handle
 */
void fuse_exit (fuse* f);

/**
 * FUSE event loop with multiple threads
 *
 * Requests from the kernel are processed, and the appropriate
 * operations are called.  Request are processed in parallel by
 * distributing them between multiple threads.
 *
 * Calling this function requires the pthreads library to be linked to
 * the application.
 *
 * @param f the FUSE handle
 * @return 0 if no error occurred, -1 otherwise
 */
int fuse_loop_mt (fuse* f);

/**
 * Get the current context
 *
 * The context is only valid for the duration of a filesystem
 * operation, and thus must not be stored and used later.
 *
 * @return the context
 */
fuse_context* fuse_get_context ();

/**
 * Get the current supplementary group IDs for the current request
 *
 * Similar to the getgroups(2) system call, except the return value is
 * always the total number of group IDs, even if it is larger than the
 * specified size.
 *
 * The current fuse kernel module in linux (as of 2.6.30) doesn't pass
 * the group list to userspace, hence this function needs to parse
 * "/proc/$TID/task/$TID/status" to get the group IDs.
 *
 * This feature may not be supported on all operating systems.  In
 * such a case this function will return -ENOSYS.
 *
 * @param size size of given array
 * @param list array of group IDs to be filled in
 * @return the total number of supplementary group IDs or -errno on failure
 */
int fuse_getgroups (int size, gid_t* list);

/**
 * Check if the current request has already been interrupted
 *
 * @return 1 if the request has been interrupted, 0 otherwise
 */
int fuse_interrupted ();

/**
 * Obsolete, doesn't do anything
 *
 * @return -EINVAL
 */
int fuse_invalidate (fuse* f, const(char)* path);

/* Deprecated, don't use */
int fuse_is_lib_option (const(char)* opt);

/**
 * The real main function
 *
 * Do not call this directly, use fuse_main()
 */
int fuse_main_real (int argc, char** argv, const(fuse_operations)* op, size_t op_size, void* user_data);

/**
 * Start the cleanup thread when using option "remember".
 *
 * This is done automatically by fuse_loop_mt()
 * @param fuse struct fuse pointer for fuse instance
 * @return 0 on success and -1 on error
 */
int fuse_start_cleanup_thread (fuse* fuse);

/**
 * Stop the cleanup thread when using option "remember".
 *
 * This is done automatically by fuse_loop_mt()
 * @param fuse struct fuse pointer for fuse instance
 */
void fuse_stop_cleanup_thread (fuse* fuse);

/**
 * Iterate over cache removing stale entries
 * use in conjunction with "-oremember"
 *
 * NOTE: This is already done for the standard sessions
 *
 * @param fuse struct fuse pointer for fuse instance
 * @return the number of seconds until the next cleanup
 */
int fuse_clean_cache (fuse* fuse);

/*
 * These functions call the relevant filesystem operation, and return
 * the result.
 *
 * If the operation is not defined, they return -ENOSYS, with the
 * exception of fuse_fs_open, fuse_fs_release, fuse_fs_opendir,
 * fuse_fs_releasedir and fuse_fs_statfs, which return 0.
 */
int fuse_fs_getattr (fuse_fs* fs, const(char)* path, stat_t* buf);
int fuse_fs_fgetattr (fuse_fs* fs, const(char)* path, stat_t* buf, fuse_file_info* fi);
int fuse_fs_rename (fuse_fs* fs, const(char)* oldpath, const(char)* newpath);
int fuse_fs_unlink (fuse_fs* fs, const(char)* path);
int fuse_fs_rmdir (fuse_fs* fs, const(char)* path);
int fuse_fs_symlink (fuse_fs* fs, const(char)* linkname, const(char)* path);
int fuse_fs_link (fuse_fs* fs, const(char)* oldpath, const(char)* newpath);
int fuse_fs_release (fuse_fs* fs, const(char)* path, fuse_file_info* fi);
int fuse_fs_open (fuse_fs* fs, const(char)* path, fuse_file_info* fi);
int fuse_fs_read (fuse_fs* fs, const(char)* path, char* buf, size_t size, off_t off, fuse_file_info* fi);
int fuse_fs_read_buf (fuse_fs* fs, const(char)* path, fuse_bufvec** bufp, size_t size, off_t off, fuse_file_info* fi);
int fuse_fs_write (fuse_fs* fs, const(char)* path, const(char)* buf, size_t size, off_t off, fuse_file_info* fi);
int fuse_fs_write_buf (fuse_fs* fs, const(char)* path, fuse_bufvec* buf, off_t off, fuse_file_info* fi);
int fuse_fs_fsync (fuse_fs* fs, const(char)* path, int datasync, fuse_file_info* fi);
int fuse_fs_flush (fuse_fs* fs, const(char)* path, fuse_file_info* fi);
int fuse_fs_statfs (fuse_fs* fs, const(char)* path, statvfs_t* buf);
int fuse_fs_opendir (fuse_fs* fs, const(char)* path, fuse_file_info* fi);
int fuse_fs_readdir (fuse_fs* fs, const(char)* path, void* buf, fuse_fill_dir_t filler, off_t off, fuse_file_info* fi);
int fuse_fs_fsyncdir (fuse_fs* fs, const(char)* path, int datasync, fuse_file_info* fi);
int fuse_fs_releasedir (fuse_fs* fs, const(char)* path, fuse_file_info* fi);
int fuse_fs_create (fuse_fs* fs, const(char)* path, mode_t mode, fuse_file_info* fi);
int fuse_fs_lock (fuse_fs* fs, const(char)* path, fuse_file_info* fi, int cmd, flock_t* lock);
int fuse_fs_flock (fuse_fs* fs, const(char)* path, fuse_file_info* fi, int op);
int fuse_fs_chmod (fuse_fs* fs, const(char)* path, mode_t mode);
int fuse_fs_chown (fuse_fs* fs, const(char)* path, uid_t uid, gid_t gid);
int fuse_fs_truncate (fuse_fs* fs, const(char)* path, off_t size);
int fuse_fs_ftruncate (fuse_fs* fs, const(char)* path, off_t size, fuse_file_info* fi);
int fuse_fs_utimens (fuse_fs* fs, const(char)* path, const(timespec)* tv);
int fuse_fs_access (fuse_fs* fs, const(char)* path, int mask);
int fuse_fs_readlink (fuse_fs* fs, const(char)* path, char* buf, size_t len);
int fuse_fs_mknod (fuse_fs* fs, const(char)* path, mode_t mode, dev_t rdev);
int fuse_fs_mkdir (fuse_fs* fs, const(char)* path, mode_t mode);
int fuse_fs_setxattr (fuse_fs* fs, const(char)* path, const(char)* name, const(char)* value, size_t size, int flags);
int fuse_fs_getxattr (fuse_fs* fs, const(char)* path, const(char)* name, char* value, size_t size);
int fuse_fs_listxattr (fuse_fs* fs, const(char)* path, char* list, size_t size);
int fuse_fs_removexattr (fuse_fs* fs, const(char)* path, const(char)* name);
int fuse_fs_bmap (fuse_fs* fs, const(char)* path, size_t blocksize, ulong* idx);
int fuse_fs_ioctl (fuse_fs* fs, const(char)* path, int cmd, void* arg, fuse_file_info* fi, uint flags, void* data);
int fuse_fs_poll (fuse_fs* fs, const(char)* path, fuse_file_info* fi, fuse_pollhandle* ph, uint* reventsp);
int fuse_fs_fallocate (fuse_fs* fs, const(char)* path, int mode, off_t offset, off_t length, fuse_file_info* fi);
void fuse_fs_init (fuse_fs* fs, fuse_conn_info* conn);
void fuse_fs_destroy (fuse_fs* fs);
int fuse_notify_poll (fuse_pollhandle* ph);

/**
 * Create a new fuse filesystem object
 *
 * This is usually called from the factory of a fuse module to create
 * a new instance of a filesystem.
 *
 * @param op the filesystem operations
 * @param op_size the size of the fuse_operations structure
 * @param user_data user data supplied in the context during the init() method
 * @return a new filesystem object
 */
fuse_fs* fuse_fs_new (const(fuse_operations)* op, size_t op_size, void* user_data);

/**
 * Filesystem module
 *
 * Filesystem modules are registered with the FUSE_REGISTER_MODULE()
 * macro.
 *
 * If the "-omodules=modname:..." option is present, filesystem
 * objects are created and pushed onto the stack with the 'factory'
 * function.
 */
struct fuse_module {
	/**
	 * Name of filesystem
	 */
	const(char)* name;
	
	/**
	 * Factory for creating filesystem objects
	 *
	 * The function may use and remove options from 'args' that belong
	 * to this module.
	 *
	 * For now the 'fs' vector always contains exactly one filesystem.
	 * This is the filesystem which will be below the newly created
	 * filesystem in the stack.
	 *
	 * @param args the command line arguments
	 * @param fs NULL terminated filesystem object vector
	 * @return the new filesystem object
	 */
	fuse_fs* function (fuse_args*, fuse_fs**) factory;
	fuse_module* next;
	fusemod_so* so;
	int ctr;
}

/**
 * Register a filesystem module
 *
 * This function is used by FUSE_REGISTER_MODULE and there's usually
 * no need to call it directly
 */
void fuse_register_module (fuse_module* mod);



int fuse_main(const(char[])[] args, const(fuse_operations)* op) {
	char*[] argv=new char*[](args.length);
	foreach(i, arg; args)
		argv[i] = cast(char*)(arg).ptr;
	return fuse_main_real(cast(int)argv.length, argv.ptr, op, (*(op)).sizeof, null);
}




