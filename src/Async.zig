//! ZLibuv
//! Author : Farey0
//!
//! Mirrors : https://docs.libuv.org/en/v1.x/async.html

//  ----------------   Declarations   ----------------

const c = @import("c.zig");
const Loop = @import("Loop.zig");
const Handle = @import("Handle.zig");

pub const Error = @import("Error.zig").BaseError;
const HandleError = @import("Error.zig").HandleBaseErr;

const Self = @This();

pub const Callback = fn (*Self) void;

//  ----------------      Members     ----------------

cAsync: c.Async = .{},

//  ----------------      Public      ----------------

pub fn Init(self: *Self, loop: *Loop, comptime callback: Callback) Error!void {
    const ret = c.AsyncInit(&loop.cLoop, &self.cAsync, callbackHandler(callback).native);

    if (ret < 0)
        return HandleError(ret);
}

pub fn Send(self: *Self) Error!void {
    const ret = c.AsyncSend(&self.cAsync);

    if (ret < 0)
        return HandleError(ret);
}

pub fn GetHandle(self: *Self) Handle {
    return .{
        .cHandle = @ptrCast(&self.cAsync),
    };
}

pub fn FromHandle(handle: Handle) error{WrongHandleType}!*Self {
    return if (handle.GetType() != .Async)
        error.WrongHandleType
    else
        @as(?*Self, @fieldParentPtr("cAsync", @as(*c.Async, @ptrCast(handle.cHandle)))).?;
}

//  ----------------      Private     ----------------

fn callbackHandler(comptime callback: Callback) type {
    return struct {
        pub fn native(cAsync: *c.Async) callconv(.C) void {
            const Async: ?*Self = @fieldParentPtr("cAsync", cAsync);

            callback(Async.?);
        }
    };
}
