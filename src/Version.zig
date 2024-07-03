//! ZLibuv
//! Author : Farey0
//!
//! Constants from the header

//  ----------------   Declarations   ----------------
const c = @import("c.zig");

//  ----------------      Public      ----------------

pub const Major = c.VersionMajor;
pub const Minor = c.VersionMinor;
pub const Patch = c.VersionPatch;

pub const IsRelease = c.IsRelease;

pub const Suffix = c.VersionSuffix;

pub fn ToString() []const u8 {
    return @import("std").mem.span(c.uv_version_string());
}
