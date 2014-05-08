/***********************************
 * D Programming Language binding for FUSE. (https://github.com/olehlong/dfuse)
 * This file defines the option parsing interface of FUSE
 * 
 * FUSE: Filesystem in Userspace
 * Copyright (C) 2001-2007  Miklos Szeredi <miklos@szeredi.hu>
 *
 * Version: 2.9.3
 * Authors: Oleh Havrys <oleh.long@gmail.com>
 * Date: Apr 15, 2014
 * License: MIT
 */
module dfuse.fuse_opt;

import dfuse.types;

extern (C):

/**
 * Processing function
 *
 * This function is called if
 *    - option did not match any 'struct fuse_opt'
 *    - argument is a non-option
 *    - option did match and offset was set to -1
 *
 * The 'arg' parameter will always contain the whole argument or
 * option including the parameter if exists.  A two-argument option
 * ("-x foo") is always converted to single argument option of the
 * form "-xfoo" before this function is called.
 *
 * Options of the form '-ofoo' are passed to this function without the
 * '-o' prefix.
 *
 * The return value of this function determines whether this argument
 * is to be inserted into the output argument vector, or discarded.
 *
 * @param data is the user data passed to the fuse_opt_parse() function
 * @param arg is the whole argument or option
 * @param key determines why the processing function was called
 * @param outargs the current output argument list
 * @return -1 on error, 0 if arg is to be discarded, 1 if arg should be kept
 */
alias int function (void*, const(char)*, int, fuse_args*) fuse_opt_proc_t;

/**
 * Option parsing function
 *
 * If 'args' was returned from a previous call to fuse_opt_parse() or
 * it was constructed from
 *
 * A NULL 'args' is equivalent to an empty argument vector
 *
 * A NULL 'opts' is equivalent to an 'opts' array containing a single
 * end marker
 *
 * A NULL 'proc' is equivalent to a processing function always
 * returning '1'
 *
 * @param args is the input and output argument list
 * @param data is the user data
 * @param opts is the option description array
 * @param proc is the processing function
 * @return -1 on error, 0 on success
 */
int fuse_opt_parse (fuse_args* args, void* data, const(fuse_opt)* opts, fuse_opt_proc_t proc);

/**
 * Add an option to a comma separated option list
 *
 * @param opts is a pointer to an option list, may point to a NULL value
 * @param opt is the option to add
 * @return -1 on allocation error, 0 on success
 */
int fuse_opt_add_opt (char** opts, const(char)* opt);

/**
 * Add an option, escaping commas, to a comma separated option list
 *
 * @param opts is a pointer to an option list, may point to a NULL value
 * @param opt is the option to add
 * @return -1 on allocation error, 0 on success
 */
int fuse_opt_add_opt_escaped (char** opts, const(char)* opt);

/**
 * Add an argument to a NULL terminated argument vector
 *
 * @param args is the structure containing the current argument list
 * @param arg is the new argument to add
 * @return -1 on allocation error, 0 on success
 */
int fuse_opt_add_arg (fuse_args* args, const(char)* arg);

/**
 * Add an argument at the specified position in a NULL terminated
 * argument vector
 *
 * Adds the argument to the N-th position.  This is useful for adding
 * options at the beginning of the array which must not come after the
 * special '--' option.
 *
 * @param args is the structure containing the current argument list
 * @param pos is the position at which to add the argument
 * @param arg is the new argument to add
 * @return -1 on allocation error, 0 on success
 */
int fuse_opt_insert_arg (fuse_args* args, int pos, const(char)* arg);

/**
 * Free the contents of argument list
 *
 * The structure itself is not freed
 *
 * @param args is the structure containing the argument list
 */
void fuse_opt_free_args (fuse_args* args);

/**
 * Check if an option matches
 *
 * @param opts is the option description array
 * @param opt is the option to match
 * @return 1 if a match is found, 0 if not
 */
int fuse_opt_match (const(fuse_opt)* opts, const(char)* opt);