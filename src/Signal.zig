//! ZLibuv
//! Author : Farey0
//!
//! Mirrors : https://docs.libuv.org/en/v1.x/signal.html

//  ----------------   Declarations   ----------------

const c = @import("c.zig");
const Loop = @import("Loop.zig");
const Handle = @import("Handle.zig");

pub const Error = @import("Error.zig").BaseError;
const HandleError = @import("Error.zig").HandleBaseErr;

const Self = @This();

pub const Callback = fn (*Self, Type) void;

pub const Type = c.SignalType;

//  ----------------      Members     ----------------

cSignal: c.Signal = .{},

//  ----------------      Public      ----------------

pub fn Init(self: *Self, uvLoop: *Loop) Error!void {
    const ret = c.SignalInit(&uvLoop.cLoop, &self.cSignal);

    if (ret < 0)
        return HandleError(ret);
}

pub fn Start(self: *Self, callback: Callback, signal: Type) Error!void {
    const ret = c.SignalStart(&self.cSignal, callbackHandler(callback).native, @intFromEnum(signal));

    if (ret < 0)
        return HandleError(ret);
}

pub fn StartOneShot(self: *Self, callback: Callback, signal: Type) Error!void {
    const ret = c.SignalStartOneShot(&self.cSignal, callbackHandler(callback).native, @intFromEnum(signal));

    if (ret < 0)
        return HandleError(ret);
}

pub fn Stop(self: *Self) Error!void {
    const ret = c.SignalStop(&self.cSignal);

    if (ret < 0)
        return HandleError(ret);
}

pub fn GetHandle(self: *Self) Handle {
    return .{
        .cHandle = @ptrCast(&self.cSignal),
    };
}

pub fn FromHandle(handle: Handle) error{WrongHandleType}!*Self {
    return if (handle.GetType() != .Signal)
        error.WrongHandleType
    else
        @fieldParentPtr("cSignal", @as(*c.Signal, @ptrCast(handle.cHandle)));
}

//  ----------------      Private     ----------------

fn callbackHandler(comptime callback: Callback) type {
    return struct {
        pub fn native(cSignal: *c.Signal, sigNum: c_int) callconv(.C) void {
            const signal: *Self = @fieldParentPtr("cSignal", cSignal);

            callback(signal, @enumFromInt(sigNum));
        }
    };
}
