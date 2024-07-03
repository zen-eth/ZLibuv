//! ZLibuv
//! Author : Farey0
//!
//! Mirrors : https://docs.libuv.org/en/v1.x/timer.html

//  ----------------   Declarations   ----------------
const c = @import("c.zig");
const Loop = @import("Loop.zig");
const Handle = @import("Handle.zig");

pub const Error = @import("Error.zig").BaseError;
const HandleError = @import("Error.zig").HandleBaseErr;

const Self = @This();

pub const TimerCallback = fn (*Self) void;

//  ----------------      Members     ----------------

cTimer: c.Timer = .{},

//  ----------------      Public      ----------------

pub fn Init(self: *Self, uvLoop: *Loop) void {

    // never fails see https://github.com/libuv/libuv/blob/eb5af8e3c0ea19a6b0196d5db3212dae1785739b/src/timer.c#L64
    _ = c.TimerInit(&uvLoop.cLoop, &self.cTimer);
}

pub fn GetHandle(self: *Self) Handle {
    return .{
        .cHandle = @ptrCast(&self.cTimer),
    };
}

pub fn FromHandle(handle: Handle) error{WrongHandleType}!*Self {
    return if (handle.GetType() != .Timer)
        error.WrongHandleType
    else
        @fieldParentPtr("cTimer", @as(*c.Timer, @ptrCast(handle.cHandle)));
}

pub fn Start(self: *Self, comptime callback: TimerCallback, timeout: u64, repeat: u64) Error!void {
    const ret = c.TimerStart(&self.cTimer, &callbackHandler(callback).native, timeout, repeat);

    if (ret < 0) return HandleError(ret);
}

pub fn Stop(self: *Self) Error!void {
    const ret = c.TimerStop(&self.cTimer);

    if (ret < 0) return HandleError(ret);
}

pub fn Again(self: *Self) (error{NeverStarted} || Error)!void {
    const ret = c.TimerAgain(&self.cTimer);

    if (ret < 0) {
        return if (@as(@import("Error.zig").VanillaError, @enumFromInt(ret)) == .InvalidArgument)
            error.NeverStarted
        else
            HandleError(ret);
    }
}

pub fn SetRepeat(self: *Self, repeat: u64) void {
    c.TimerSetRepeat(&self.cTimer, repeat);
}

pub fn GetRepeat(self: *Self) u64 {
    return c.TimerGetRepeat(&self.cTimer);
}

pub fn GetDueIn(self: *Self) u64 {
    return c.TimerGetDueIn(&self.cTimer);
}

//  ----------------      Private     ----------------

fn callbackHandler(comptime callback: TimerCallback) type {
    return struct {
        pub fn native(cTimer: [*c]c.Timer) callconv(.C) void {
            const timer: ?*Self = @fieldParentPtr("cTimer", cTimer);

            callback(timer.?);
        }
    };
}
