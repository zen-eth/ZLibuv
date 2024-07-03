//! ZLibuv
//! Author : Farey0
//!
//! Mirrors : https://docs.libuv.org/en/v1.x/check.html

//  ----------------   Declarations   ----------------

const c = @import("c.zig");
const Loop = @import("Loop.zig");
const Handle = @import("Handle.zig");

const Self = @This();

pub const Callback = fn (*Self) void;

//  ----------------      Members     ----------------

cCheck: c.Check = .{},

//  ----------------      Public      ----------------

pub fn Init(self: *Self, loop: *Loop) void {
    // always succeed : http://docs.libuv.org/en/v1.x/check.html#c.uv_check_init
    _ = c.CheckInit(&loop.cLoop, &self.cCheck);
}

pub fn Start(self: *Self, comptime callback: Callback) void {
    // always succeed as callback is comptime : http://docs.libuv.org/en/v1.x/check.html#c.uv_check_start
    _ = c.CheckStart(&self.cCheck, callbackHandler(callback).native);
}

pub fn Stop(self: *Self) void {
    // always succeed : http://docs.libuv.org/en/v1.x/check.html#c.uv_check_stop
    _ = c.CheckStop(&self.cCheck);
}

pub fn GetHandle(self: *Self) Handle {
    return .{
        .cHandle = @ptrCast(&self.cCheck),
    };
}

pub fn FromHandle(handle: Handle) error{WrongHandleType}!*Self {
    return if (handle.GetType() != .Check)
        error.WrongHandleType
    else
        @fieldParentPtr(Self, "cCheck", @as(*c.Check, @ptrCast(handle.cHandle)));
}

//  ----------------      Private     ----------------

fn callbackHandler(comptime callback: Callback) type {
    return struct {
        pub fn native(cCheck: *c.Check) callconv(.C) void {
            const Check: *Self = @fieldParentPtr(Self, "cCheck", cCheck);

            callback(Check);
        }
    };
}
