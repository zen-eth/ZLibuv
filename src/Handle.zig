//! ZLibuv
//! Author : Farey0
//!
//! Mirrors :https://docs.libuv.org/en/v1.x/handle.html

//  ----------------   Declarations   ----------------

const c = @import("c.zig");
const Loop = @import("Loop.zig");

const Self = @This();

pub const Type = c.HandleType;
pub const CloseCallback = fn (Self) void;

//  ----------------      Members     ----------------

cHandle: *c.Handle = undefined,

//  ----------------      Public      ----------------

pub fn IsActive(self: Self) bool {
    return c.IsActive(&self.cHandle) != 0;
}

/// This function should only be used between the initialization of the handle and the arrival of the close callback.
/// see : https://docs.libuv.org/en/v1.x/handle.html
pub fn IsClosing(self: Self) bool {
    return c.IsClosing(&self.cHandle) != 0;
}

pub fn Close(self: Self, comptime callback: ?CloseCallback) void {
    const cCallback: c.CloseCb = if (callback) |ziggifiedCb| CloseCbMaker(ziggifiedCb).cCallback else null;

    c.Close(self.cHandle, cCallback);
}

pub fn Reference(self: Self) void {
    c.Ref(&self.cHandle);
}

pub fn Unreference(self: Self) void {
    c.Unref(&self.cHandle);
}

pub fn HasReference(self: Self) void {
    c.HasRef(&self.cHandle);
}

pub fn GetSize(t: Type) usize {
    return c.HandleSize(@intFromEnum(t));
}

pub fn GetLoop(self: Self) *Loop {
    return @as(?*Loop, @fieldParentPtr("cLoop", self.cHandle.loop)).?;
}

pub fn GetType(self: Self) Type {
    return @enumFromInt(self.cHandle.type);
}

pub fn GetData(self: Self, comptime T: type) *T {
    return @ptrCast(@alignCast(self.cHandle.data));
}

pub fn SetData(self: Self, value: anytype) void {
    if (@typeInfo(@TypeOf(value)) != .pointer)
        @compileError("value must a pointer");

    self.cHandle.data = @ptrCast(value);
}

pub fn TypeName(t: Type) error{UnknowType}![]const u8 {
    const ret = c.TypeName(@intFromEnum(t));

    if (ret == null) return error.UnknowType;

    return @import("std").mem.span(ret);
}

//  ----------------      Private     ----------------

pub fn CloseCbMaker(comptime func: CloseCallback) type {
    return struct {
        pub fn cCallback(handle: *c.Handle) callconv(.C) void {
            func(.{ .cHandle = handle });
        }
    };
}
