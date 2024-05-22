const std = @import("std");
const testing = @import("std").testing;

pub fn main() !void {
    while (true) {
        const stdin = std.io.getStdIn().reader();
        const stdout = std.io.getStdOut().writer();
        const bare_line = try stdin.readUntilDelimiterAlloc(std.heap.page_allocator, '\n', 8192);
        defer std.heap.page_allocator.free(bare_line);
        //This is because windows uses \r\n as new line
        const line = std.mem.trim(u8, bare_line, "\r");
        const result = try getDiceRoll(line);

        try stdout.print("{d}", .{result});
    }
}

fn interpretLine(line: []u8) !void {
    _ = line;
}

fn getDiceRoll(command: []const u8) error{ Overflow, InvalidCharacter }!u32 {
    var diceCmd = std.mem.split(u8, command, "d");
    var result: u32 = 0;
    if (diceCmd.next()) |numDiceCmd| {
        var numDices = try std.fmt.parseInt(u8, numDiceCmd, 10);
        if (diceCmd.next()) |diceSizeCmd| {
            var diceSize = try std.fmt.parseInt(u8, diceSizeCmd[0..], 10);
            var i: u8 = 0;
            while (i < numDices) : (i += 1) {
                result += getRandomNumber(diceSize);
            }
        }
    }
    return result;
}
fn getRandomNumber(diceSize: u8) u8 {
    const rand = std.crypto.random;
    return rand.intRangeAtMost(u8, 1, diceSize);
}

test "single diceroll" {
    const x = try getDiceRoll("1d2");
    try std.testing.expect(x >= 1);
    try std.testing.expect(x <= 2);
    const u = try getDiceRoll("1d6");
    try testing.expect(u <= 6);
    try testing.expect(u >= 1);
}
test "multiple diceroll" {
    const x = try getDiceRoll("2d2");
    try std.testing.expect(x >= 2);
    try std.testing.expect(x <= 4);
    const u = try getDiceRoll("2d6");
    try testing.expect(u <= 12);
    try testing.expect(u >= 2);
}
