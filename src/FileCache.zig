path: []const u8,

pub fn init(abs_path: []const u8) !Self {
    if (!std.fs.path.isAbsolute(abs_path)) return error.BadPathName;
    try std.fs.cwd().makePath(abs_path);
    return .{ .path = abs_path };
}

/// Return error.FileNotFound if key is not in the cache. Caller owns
/// returned memory.
pub fn get(self: Self, alloc: Allocator, key: []const u8) ![]const u8 {
    const file_path = try self.getFilePath(alloc, key);
    errdefer alloc.free(file_path);
    try std.fs.accessAbsolute(file_path, .{});
    return file_path;
}

pub fn getFilePath(self: Self, alloc: Allocator, key: []const u8) ![]const u8 {
    const hash_key = hash(key);
    const hex = std.fmt.bytesToHex(hash_key, .lower);
    return try std.fs.path.join(alloc, &.{ self.path, &hex });
}

fn hash(in: []const u8) [Hash.digest_length]u8 {
    var hasher = Hash.init(.{});
    hasher.update(in);
    return hasher.finalResult();
}

test "absolute path required" {
    try std.testing.expectError(error.BadPathName, Self.init("./foo"));
}

test "init creates the path" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const realpath = try tmp.dir.realpathAlloc(alloc, ".");
    defer alloc.free(realpath);
    const cache_dir = try std.fs.path.join(alloc, &.{ realpath, "foo" });
    defer alloc.free(cache_dir);

    _ = try Self.init(cache_dir);
    try std.fs.accessAbsolute(cache_dir, .{});
}

test "get and getFilePath" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const realpath = try tmp.dir.realpathAlloc(alloc, ".");
    defer alloc.free(realpath);
    const cache_dir = try std.fs.path.join(alloc, &.{ realpath, "foo" });
    defer alloc.free(cache_dir);

    const cache = try Self.init(cache_dir);

    // expect not found
    const bar_path = try cache.getFilePath(alloc, "bar");
    defer alloc.free(bar_path);

    try std.testing.expectError(error.FileNotFound, std.fs.accessAbsolute(bar_path, .{}));
    try std.testing.expectError(error.FileNotFound, cache.get(alloc, bar_path));

    // create a file there

    {
        const file = try std.fs.createFileAbsolute(bar_path, .{});
        defer file.close();
    }

    // expect get returns the path

    const res = try cache.get(alloc, "bar");
    defer alloc.free(res);
}

const Self = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;

const Hash = std.crypto.hash.sha2.Sha256;
