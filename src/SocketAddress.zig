//! ZLibuv
//! Author : farey0
//!
//! Simple struct that allows to manipulate ipv4 string to SockAddrIn
//! from : https://docs.libuv.org/en/v1.x/misc.html

//                          ----------------   Declarations   ----------------

const Self = @This();
const c = @import("c.zig");

pub const Error = @import("Error.zig").BaseError;
const HandleError = @import("Error.zig").HandleBaseErr;

//                          ----------------      Members     ----------------

cSocketAddress: c.SocketAddressIn = .{},

//                          ----------------      Public      ----------------

pub fn FromString(str: [:0]const u8, port: u16) Error!Self {
    var out: Self = .{};

    const ret = c.StrToAddress(str.ptr, @intCast(port), &out.cSocketAddress);

    if (ret < 0)
        return HandleError(ret);

    return out;
}

pub fn ToString(self: Self, buffer: []u8) Error![]const u8 {
    if (buffer.len < 16) // 15 char for IPV4 + null terminator
        @panic("buffer len must superior or equal to 16");

    const ret = c.AddressToStr4(&self.cSocketAddress, buffer.ptr, buffer.len);

    if (ret < 0)
        return HandleError(ret);

    return @import("std").mem.span(@as([*c]u8, @ptrCast(buffer)));
}

//                          ---------------- Getters/Setters  ----------------

//                          ----------------      Private     ----------------
