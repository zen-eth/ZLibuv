//! ZLibuv
//! Author : Farey0
//!
//! Mirrors : https://docs.libuv.org/en/v1.x/prepare.html

//  ----------------   Declarations   ----------------

const c = @import("c.zig");
const Loop = @import("Loop.zig");
const Handle = @import("Handle.zig");

const Self = @This();

pub const Callback = fn (*Self) void;

//  ----------------      Members     ----------------

cPrepare: c.Prepare = .{},

//  ----------------      Public      ----------------

pub fn Init(self: *Self, loop: *Loop) void {
    // always succeed : http://docs.libuv.org/en/v1.x/prepare.html#c.uv_prepare_init
    _ = c.PrepareInit(&loop.cLoop, &self.cPrepare);
}

pub fn Start(self: *Self, comptime callback: Callback) void {
    // always succeed as callback is comptime : http://docs.libuv.org/en/v1.x/prepare.html#c.uv_prepare_start
    _ = c.PrepareStart(&self.cPrepare, callbackHandler(callback).native);
}

pub fn Stop(self: *Self) void {
    // always succeed : http://docs.libuv.org/en/v1.x/prepare.html#c.uv_prepare_stop
    _ = c.PrepareStop(&self.cPrepare);
}

pub fn GetHandle(self: *Self) Handle {
    return .{
        .cHandle = @ptrCast(&self.cPrepare),
    };
}

pub fn FromHandle(handle: Handle) error{WrongHandleType}!*Self {
    return if (handle.GetType() != .Prepare)
        error.WrongHandleType
    else
        @fieldParentPtr("cPrepare", @as(*c.Prepare, @ptrCast(handle.cHandle)));
}

//  ----------------      Private     ----------------

fn callbackHandler(comptime callback: Callback) type {
    return struct {
        pub fn native(cPrepare: *c.Prepare) callconv(.C) void {
            const prepare: *Self = @fieldParentPtr("cPrepare", cPrepare);

            callback(prepare);
        }
    };
}
