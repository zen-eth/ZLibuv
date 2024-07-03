//! ZLibuv
//! Author : Farey0
//!
//! Wraps the base request, which is the same a base handle to a tcp, timer, etc...
//! You can cast your requests to this base type with ToBase(); from any request type

//  ----------------   Declarations   ----------------

const c = @import("../c.zig");

pub const Error = @import("../Error.zig").BaseError;
const HandleError = @import("../Error.zig").HandleBaseErr;

const Self = @This();

pub const cType = c.RequestType;

//  ----------------      Members     ----------------

cReq: *c.Request = undefined,

//  ----------------      Public      ----------------

pub fn Cancel(self: Self) Error!void {
    const ret = c.Cancel(&self.cReq);

    if (ret < 0) HandleError(ret);
}

pub fn Size(t: cType) c_uint {
    return c.ReqSize(@intFromEnum(t));
}

pub fn GetType(self: Self) cType {
    return @enumFromInt(self.cReq.type);
}

pub fn TypeName(t: cType) error{UnknowType}![]const u8 {
    const ret = c.ReqTypeName(@intFromEnum(t));

    if (ret == null) return error.UnknowType;

    return @import("std").mem.span(ret);
}

pub fn GetData(self: Self, comptime T: type) *T {
    return @ptrCast(@alignCast(self.cReq.data.?));
}

pub fn SetData(self: Self, value: anytype) void {
    if (@typeInfo(@TypeOf(value)) != .Pointer)
        @compileError("value must a pointer");

    self.cReq.data = @ptrCast(value);
}
