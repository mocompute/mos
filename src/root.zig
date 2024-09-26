const std = @import("std");

pub const streql = string.streql;

pub const string = @import("string.zig");
pub const file = @import("file.zig");

test {
    std.testing.refAllDecls(@This());
}
