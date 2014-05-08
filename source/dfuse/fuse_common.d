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
module dfuse.fuse_common;

version (Posix) {
    import  core.sys.posix.sys.types,
    		core.stdc.config;
}
else
    static assert(false, "Module " ~ .stringof ~ " not implemented for this OS.");

import dfuse.types;

extern (C):

/**
 * Create a FUSE mountpoint
 *
 * Returns a control file descriptor suitable for passing to
 * fuse_new()
 *
 * @param mountpoint the mount point path
 * @param args argument vector
 * @return the communication channel on success, NULL on failure
 */
fuse_chan* fuse_mount (const(char)* mountpoint, fuse_args* args);

/**
 * Umount a FUSE mountpoint
 *
 * @param mountpoint the mount point path
 * @param ch the communication channel
 */
void fuse_unmount (const(char)* mountpoint, fuse_chan* ch);

/**
 * Parse common options
 *
 * The following options are parsed:
 *
 *   '-f'	     foreground
 *   '-d' '-odebug'  foreground, but keep the debug option
 *   '-s'	     single threaded
 *   '-h' '--help'   help
 *   '-ho'	     help without header
 *   '-ofsname=..'   file system name, if not present, then set to the program
 *		     name
 *
 * All parameters may be NULL
 *
 * @param args argument vector
 * @param mountpoint the returned mountpoint, should be freed after use
 * @param multithreaded set to 1 unless the '-s' option is present
 * @param foreground set to 1 if one of the relevant options is present
 * @return 0 on success, -1 on failure
 */
int fuse_parse_cmdline (fuse_args* args, char** mountpoint, int* multithreaded, int* foreground);

/**
 * Go into the background
 *
 * @param foreground if true, stay in the foreground
 * @return 0 on success, -1 on failure
 */
int fuse_daemonize (int foreground);

/**
 * Get the version of the library
 *
 * @return the version
 */
int fuse_version ();

/**
 * Destroy poll handle
 *
 * @param ph the poll handle
 */
void fuse_pollhandle_destroy (fuse_pollhandle* ph);

/**
 * Get total size of data in a fuse buffer vector
 *
 * @param bufv buffer vector
 * @return size of data
 */
size_t fuse_buf_size (const(fuse_bufvec)* bufv);

/**
 * Copy data from one buffer vector to another
 *
 * @param dst destination buffer vector
 * @param src source buffer vector
 * @param flags flags controlling the copy
 * @return actual number of bytes copied or -errno on error
 */
ssize_t fuse_buf_copy (fuse_bufvec* dst, fuse_bufvec* src, fuse_buf_copy_flags flags);

/* ----------------------------------------------------------- *
 * Signal handling					       					   *
 * ----------------------------------------------------------- */

/**
 * Exit session on HUP, TERM and INT signals and ignore PIPE signal
 *
 * Stores session in a global variable.	 May only be called once per
 * process until fuse_remove_signal_handlers() is called.
 *
 * @param se the session to exit
 * @return 0 on success, -1 on failure
 */
int fuse_set_signal_handlers (fuse_session* se);

/**
 * Restore default signal handlers
 *
 * Resets global session.  After this fuse_set_signal_handlers() may
 * be called again.
 *
 * @param se the same session as given in fuse_set_signal_handlers()
 */
void fuse_remove_signal_handlers (fuse_session* se);
