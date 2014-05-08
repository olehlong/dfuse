/***********************************
 * D Programming Language binding for FUSE. (https://github.com/olehlong/dfuse)
 * libulockmgr
 * 
 * libulockmgr: Userspace Lock Manager Library
 * Copyright (C) 2006  Miklos Szeredi <miklos@szeredi.hu>
 *
 * Version: 2.9.3
 * Authors: Oleh Havrys <oleh.long@gmail.com>
 * Date: Apr 15, 2014
 * License: MIT
 */
module dfuse.ulockmgr;

import core.sys.posix.fcntl;

extern (C):

/**
 * Perform POSIX locking operation
 *
 * @param fd the file descriptor
 * @param cmd the locking command (F_GETFL, F_SETLK or F_SETLKW)
 * @param lock the lock parameters
 * @param owner the lock owner ID cookie
 * @param owner_len length of the lock owner ID cookie
 * @return 0 on success -errno on error
 */
int ulockmgr_op (int fd, int cmd, flock* lock, const(void)* owner, size_t owner_len);