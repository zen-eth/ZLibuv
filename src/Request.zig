//! ZLibuv
//! Author : Farey0
//!
//! Wraps request structs

pub const Base = @import("Request/Base.zig");

const c = @import("c.zig");

pub const Connect = struct {
    const Self = @This();

    cReq: c.ConnectT = .{},

    pub fn ToBase(self: *Self) Base {
        return .{
            .cReq = @ptrCast(&self.cReq),
        };
    }

    pub fn FromBase(base: Base) *Self {
        return @fieldParentPtr(Self, "cReq", @as(*c.ConnectT, @ptrCast(base.cReq)));
    }
};

pub const Shutdown = struct {
    const Self = @This();

    cReq: c.ShutdownT = .{},

    pub fn ToBase(self: *Self) Base {
        return .{
            .cReq = @ptrCast(&self.cReq),
        };
    }

    pub fn FromBase(base: Base) *Self {
        return @fieldParentPtr(Self, "cReq", @as(*c.ShutdownT, @ptrCast(base.cReq)));
    }
};

pub const Write = struct {
    const Self = @This();

    cReq: c.WriteT = .{},

    pub fn ToBase(self: *Self) Base {
        return .{
            .cReq = @ptrCast(&self.cReq),
        };
    }

    pub fn FromBase(base: Base) *Self {
        return @fieldParentPtr(Self, "cReq", @as(*c.WriteT, @ptrCast(base.cReq)));
    }
};
