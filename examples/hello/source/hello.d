import std.stdio;

import dfuse.fuse; 

import core.sys.posix.sys.types;
import core.stdc.errno;
import core.sys.posix.sys.stat;
import core.sys.posix.fcntl;
import std.c.string: memcpy;

import std.conv;

static string hello_str = "Hello World!\n";
static string hello_path = "/hello";  

void main(string[] args) {    
	fuse_operations hello_oper; 
	
	hello_oper.readdir = function int(const(char)* path, void* buf, fuse_fill_dir_t filler, off_t offset, fuse_file_info* fi) {
		if (to!string(path) != "/") 
			return -ENOENT;
		
		filler(buf, ".", null, 0);
	    filler(buf, "..", null, 0);
	    filler(buf, hello_path.ptr+1, null, 0);
		
		return 0;  
	};
	
	hello_oper.getattr = function int(const(char)* path, stat_t* stbuf) {
		int res = 0;
		
		if (to!string(path) == "/") {
			stbuf.st_mode = S_IFDIR | std.conv.octal!755;
			stbuf.st_nlink = 2;
		} else if (to!string(path) == hello_path) {
			stbuf.st_mode = S_IFREG | std.conv.octal!444;
			stbuf.st_nlink = 1;
			stbuf.st_size = hello_str.length;
		} else
			res = -ENOENT;
		
		return res;
	};
	
	hello_oper.open = function int(const(char)* path, fuse_file_info* fi) {
		if (to!string(path) != hello_path)
			return -ENOENT;

		if ((fi.flags & 3) != O_RDONLY)
			return -EACCES;

		return 0;
	};
	
	hello_oper.read = function int(const(char)* path, char* buf, size_t size, off_t offset, fuse_file_info* fi) {
		if(to!string(path) != hello_path)
			return -ENOENT;
	
		size_t len = hello_str.length;
		if (offset < len) {
			if (offset + size > len)
				size = len - offset;
			memcpy(buf, hello_str.ptr + offset, size);
		} else
			size = 0;
	
		return cast(int)size;
	};
	
	fuse_main(args, &hello_oper);
}