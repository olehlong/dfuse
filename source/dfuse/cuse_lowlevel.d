/***********************************
 * D Programming Language binding for FUSE. (https://github.com/olehlong/dfuse)
 * CUSE
 * 
 * CUSE: Character device in Userspace
 * Copyright (C) 2008-2009  SUSE Linux Products GmbH
 * Copyright (C) 2008-2009  Tejun Heo <tj@kernel.org>
 *
 * Version: 2.9.3
 * Authors: Oleh Havrys <oleh.long@gmail.com>
 * Date: Apr 15, 2014
 * License: MIT
 */
module dfuse.cuse_lowlevel;

version (Posix) {
    import core.sys.posix.sys.types;
}
else
    static assert(false, "Module " ~ .stringof ~ " not implemented for this OS.");

public import dfuse.fuse_lowlevel;

extern (C):

static uint CUSE_UNRESTRICTED_IOCTL = (1 << 0); /* use unrestricted ioctl */

/*
 * Most ops behave almost identically to the matching fuse_lowlevel
 * ops except that they don't take @ino.
 *
 * init_done	: called after initialization is complete
 * read/write	: always direct IO, simultaneous operations allowed
 * ioctl	: might be in unrestricted mode depending on ci->flags
 */
struct cuse_lowlevel_ops {
	void function (void*, fuse_conn_info*) init;
	void function (void*) init_done;
	void function (void*) destroy;
	void function (fuse_req_t, fuse_file_info*) open;
	void function (fuse_req_t, size_t, off_t, fuse_file_info*) read;
	void function (fuse_req_t, const(char)*, size_t, off_t, fuse_file_info*) write;
	void function (fuse_req_t, fuse_file_info*) flush;
	void function (fuse_req_t, fuse_file_info*) release;
	void function (fuse_req_t, int, fuse_file_info*) fsync;
	void function (fuse_req_t, int, void*, fuse_file_info*, uint, const(void)*, size_t, size_t) ioctl;
	void function (fuse_req_t, fuse_file_info*, fuse_pollhandle*) poll;
}

fuse_session* cuse_lowlevel_new (fuse_args* args, const(cuse_info)* ci, const(cuse_lowlevel_ops)* clop, void* userdata);
fuse_session* cuse_lowlevel_setup (int argc, char** argv, const(cuse_info)* ci, const(cuse_lowlevel_ops)* clop, int* multithreaded, void* userdata);
void cuse_lowlevel_teardown (fuse_session* se);
int cuse_lowlevel_main (int argc, char** argv, const(cuse_info)* ci, const(cuse_lowlevel_ops)* clop, void* userdata);
