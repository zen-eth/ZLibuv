//! ZLibuv
//! Author : Farey0
//!
//! Error handling is not done yet.
//! It will return an OOM error when out of memory,
//! but will return an UnexpectedError for about every
//! other cases.
//!
//! You have GetLastUnexpected() which returns the last
//! Threadlocal libuv error that has happened.
//! You can see in c.zig all libuv errors are mapped to it.

const c = @import("c.zig");
const builtin = @import("builtin");
const std = @import("std");

const logUnexpectedError = builtin.mode == .Debug;

pub const VanillaError = c.Error;
threadlocal var lastUnexpected: VanillaError = .UV_ERRNO_MAX;

/// As error handling is not yet done
/// You can retreive the last threadlocal unexpected error
///
/// At the start of the program, it's initialized to .UV_ERRNO_MAX
pub fn GetLastUnexpected() VanillaError {
    return lastUnexpected;
}

fn FireUnexpectedError(errCode: c_int) UnexpectedError {
    if (logUnexpectedError) {
        std.debug.print("error.Unexpected {d}\n", .{errCode});
        std.debug.dumpCurrentStackTrace(@returnAddress());
    }

    lastUnexpected = @enumFromInt(errCode);
    return error.Unexpected;
}

pub const UnexpectedError = error{
    Unexpected,
};

pub const OOMError = error{
    OutOfMemory,
};

pub const BaseError = error{} || OOMError || UnexpectedError;

pub fn HandleBaseErr(err: c_int) BaseError {
    return switch (@as(c.Error, @enumFromInt(err))) {
        .OutOfMemory, .NotEnoughMem => error.OutOfMemory,

        else => FireUnexpectedError(err),
    };
}
