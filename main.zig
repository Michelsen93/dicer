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

fn getDiceRoll(command: []const u8) error{ Overflow, InvalidCharacter }!u8 {
    var dices = std.mem.split(u8, command, "d");
    if (dices.next()) |val| {
        var result = try std.fmt.parseInt(u8, val, 10);
        while (dices.next()) |value| {
            var multiplyer = try std.fmt.parseInt(u8, value[0..], 10);
            result = result * multiplyer;
        }
        return result;
    }
    return 0;
}

test "single diceroll" {
    const x = try getDiceRoll("1d2");
    try std.testing.expect(x == 2);
    const u = try getDiceRoll("1d6");
    try testing.expect(u == 6);
}
test "multiple diceroll" {
    const x = try getDiceRoll("2d2");
    try std.testing.expect(x == 4);
    const u = try getDiceRoll("2d6");
    try testing.expect(u == 12);
}
