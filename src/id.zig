// This file is part of mos.
//
// Copyright (C) 2024 <https://codeberg.org/mocompute>
//
// mos is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// mos is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/// A typed integer-backed id.
pub fn Id(comptime T: type) type {
    return enum(T) {
        _,

        /// Construct an Id(T) from an integer
        pub fn fromInt(x: T) @This() {
            return @enumFromInt(x);
        }
        /// Return the maximum integer of type T
        pub fn maxInt() T {
            return std.math.maxInt(T);
        }
        /// Return this Id(T) as a T
        pub fn int(self: @This()) T {
            return @intFromEnum(self);
        }
        /// Return this Id(T) plus x
        pub fn inc(self: @This(), x: T) @This() {
            return @enumFromInt(@intFromEnum(self) + x);
        }
        /// Return the next (inc(1)) Id.
        pub fn next(self: @This()) @This() {
            return @enumFromInt(@intFromEnum(self) + 1);
        }
        /// Return false if next() is an overflow.
        pub fn hasNext(self: @This()) bool {
            return @intFromEnum(self) != std.math.maxInt(T);
        }
    };
}

test {
    const FooId = Id(u16);
    try expectEqual(std.math.maxInt(u16), FooId.maxInt());
    {
        const x = FooId.fromInt(0);
        try expectEqual(1, x.next().int());
        try expect(x.hasNext());

        try expectEqual(2, x.inc(2).int());
    }
    {
        const x = FooId.fromInt(std.math.maxInt(u16));
        try expect(!x.hasNext());
    }
}

const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
