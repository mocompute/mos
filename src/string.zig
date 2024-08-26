const std = @import("std");
const testing = std.testing;

pub fn streql(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

test streql {
    try testing.expect(streql("hello", "hello"));
    try testing.expect(!streql("hello", "world"));
}
