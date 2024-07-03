//! ZLibuv
//! Author : Farey0
//!
//! Mirrors : https://docs.libuv.org/en/v1.x/prepare.html

//  ----------------   Declarations   ----------------
const c = @import("c.zig");

const Self = @This();

pub const Error = @import("Error.zig").BaseError;
const HandleError = @import("Error.zig").HandleBaseErr;

pub const RunMode = c.RunMode;

//  ----------------      Members     ----------------

cLoop: c.Loop = .{},

//  ----------------      Public      ----------------

pub fn Init(self: *Self) Error!void {
    const ret = c.LoopInit(&self.cLoop);

    if (ret < 0) return HandleError(ret);
}

pub fn Close(self: *Self) Error!void {
    const ret = c.LoopClose(&self.cLoop);

    if (ret < 0) return HandleError(ret);
}

pub fn Run(self: *Self, runMode: RunMode) Error!void {
    const ret = c.Run(&self.cLoop, @intFromEnum(runMode));

    if (ret < 0) return HandleError(ret);
}

pub fn IsAlive(self: *Self) bool {
    return c.LoopAlive(&self.cLoop) != 0;
}

pub fn Stop(self: *Self) Error!void {
    const ret = c.Stop(&self.cLoop);

    if (ret < 0) return HandleError(ret);
}
