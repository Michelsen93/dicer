const std = @import("std");
const testing = @import("std").testing;
const resources = @import("resources.zig");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}", .{resources.introduction});
    while (true) {
        try stdout.print("{s}", .{resources.inputPrefix});
        const bare_line = try stdin.readUntilDelimiterAlloc(std.heap.page_allocator, '\n', 8192);
        defer std.heap.page_allocator.free(bare_line);
        const line = std.mem.trim(u8, bare_line, "\r");
        const rolls = try getDiceRolls(line, std.heap.page_allocator);
        const result = sumRolls(rolls);
        const rollsLog = try rollsString(rolls, std.heap.page_allocator);
        try stdout.print("{s}{s}\n", .{ resources.rollLogPrefix, rollsLog });
        try stdout.print("{s}{d}\n", .{ resources.resultPrefix, result });
    }
}

fn interpretLine(line: []u8) !void {
    _ = line;
}

fn sumRolls(rolls: []u8) u64 {
    var sum: u64 = 0;
    for (rolls) |value| {
        sum += value;
    }
    return sum;
}

fn rollsString(rolls: []u8, allocator: std.mem.Allocator) error{ Overflow, InvalidCharacter, OutOfMemory }![]u8 {
    var rollsLog = std.ArrayList(u8).init(allocator);
    try rollsLog.append('|');
    for (rolls) |value| {
        const string = try std.fmt.allocPrint(
            allocator,
            "{d}|",
            .{value},
        );
        for (string) |char| {
            try rollsLog.append(char);
        }
    }
    return rollsLog.items;
}

fn getDiceRolls(command: []const u8, allocator: std.mem.Allocator) error{ Overflow, InvalidCharacter, OutOfMemory }![]u8 {
    var diceCmd = std.mem.split(u8, command, "d");
    var rolls = std.ArrayList(u8).init(allocator);
    if (diceCmd.next()) |numDiceCmd| {
        const numDices = try std.fmt.parseInt(u8, numDiceCmd, 10);
        if (diceCmd.next()) |diceSizeCmd| {
            const diceSize = try std.fmt.parseInt(u8, diceSizeCmd[0..], 10);
            var i: u8 = 0;
            while (i < numDices) : (i += 1) {
                try rolls.append(getRandomNumber(diceSize));
            }
        }
    }
    return rolls.items;
}
fn getRandomNumber(diceSize: u8) u8 {
    const rand = std.crypto.random;
    return rand.intRangeAtMost(u8, 1, diceSize);
}

test "single diceroll" {
    const x = try getDiceRolls("1d2");
    try std.testing.expect(x >= 1);
    try std.testing.expect(x <= 2);
    const u = try getDiceRolls("1d6");
    try testing.expect(u <= 6);
    try testing.expect(u >= 1);
    const y = try getDiceRolls("1d1");
    try std.testing.expect(y == 1);
}
test "multiple diceroll" {
    const x = try getDiceRolls("2d2");
    try std.testing.expect(x >= 2);
    try std.testing.expect(x <= 4);
    const u = try getDiceRolls("2d6");
    try testing.expect(u <= 12);
    try testing.expect(u >= 2);
    const y = try getDiceRolls("100d1");
    try std.testing.expect(y == 100);
}
