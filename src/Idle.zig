//! ZLibuv
//! Author : Farey0
//!
//! Mirrors : https://docs.libuv.org/en/v1.x/idle.html

//  ----------------   Declarations   ----------------

const c = @import("c.zig");
const Loop = @import("Loop.zig");
const Handle = @import("Handle.zig");

const Self = @This();

pub const Callback = fn (*Self) void;

//  ----------------      Members     ----------------

cIdle: c.Idle = .{},

//  ----------------      Public      ----------------

pub fn Init(self: *Self, loop: *Loop) void {
    // always succeed : http://docs.libuv.org/en/v1.x/idle.html#c.uv_idle_init
    _ = c.IdleInit(&loop.cLoop, &self.cIdle);
}

pub fn Start(self: *Self, comptime callback: Callback) void {
    // always succeed as callback is comptime : http://docs.libuv.org/en/v1.x/idle.html#c.uv_idle_start
    _ = c.IdleStart(&self.cIdle, callbackHandler(callback).native);
}

pub fn Stop(self: *Self) void {
    // always succeed : http://docs.libuv.org/en/v1.x/idle.html#c.uv_idle_stop
    _ = c.IdleStop(&self.cIdle);
}

pub fn GetHandle(self: *Self) Handle {
    return .{
        .cHandle = @ptrCast(&self.cIdle),
    };
}

pub fn FromHandle(handle: Handle) error{WrongHandleType}!*Self {
    return if (handle.GetType() != .Idle)
        error.WrongHandleType
    else
        @fieldParentPtr("cIdle", @as(*c.Idle, @ptrCast(handle.cHandle)));
}

//  ----------------      Private     ----------------

fn callbackHandler(comptime callback: Callback) type {
    return struct {
        pub fn native(cIdle: *c.Idle) callconv(.C) void {
            const Idle: *Self = @fieldParentPtr("cIdle", cIdle);

            callback(Idle);
        }
    };
}
