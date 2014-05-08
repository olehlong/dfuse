/***********************************
 * D Programming Language binding for FUSE. (https://github.com/olehlong/dfuse)
 * This file defines core.sys.posix.sys.statfs.
 *
 * Version: 2.9.3
 * Authors: Oleh Havrys <oleh.long@gmail.com>
 * Date: Apr 15, 2014
 * License: MIT
 */
module dfuse.statfs;

import core.stdc.config;
import core.sys.posix.config;
import core.sys.posix.sys.types;

version (Posix):
extern (C) :

struct fsid_t {
	int __val[2];
}

struct statfs_t {
	c_ulong f_type;
    c_ulong f_bsize;
    fsblkcnt_t f_blocks;
    fsblkcnt_t f_bfree;
    fsblkcnt_t f_bavail;
    fsblkcnt_t f_files;
    fsblkcnt_t f_ffree;

    fsid_t f_fsid;
    c_ulong f_namelen;
    c_ulong f_spare[6];
};