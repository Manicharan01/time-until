const std = @import("std");
const c = @cImport(@cInclude("time.h"));

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const now: c.time_t = c.time(null);

    var target_tm: c.struct_tm = std.mem.zeroes(c.struct_tm);

    target_tm.tm_year = 2026 - 1900;
    target_tm.tm_mon = 2;
    target_tm.tm_mday = 8;
    target_tm.tm_hour = 9;
    target_tm.tm_min = 30;
    target_tm.tm_sec = 0;
    target_tm.tm_isdst = -1;

    const target_time: c.time_t = c.mktime(&target_tm);

    if (target_time == -1) {
        std.debug.print("Error converting target time.\n", .{});
        return;
    }

    const diff_sec: f64 = c.difftime(target_time, now);
    var total_seconds: i64 = @intFromFloat(diff_sec);

    if (total_seconds <= 0) {
        std.debug.print("The target date has passed!\n", .{});
        return;
    }

    const seconds_in_day = 86400;
    const seconds_in_hour = 3600;
    const seconds_in_minute = 60;

    const days = @divTrunc(total_seconds, seconds_in_day);
    total_seconds = @rem(total_seconds, seconds_in_day);

    const hours = @divTrunc(total_seconds, seconds_in_hour);
    total_seconds = @rem(total_seconds, seconds_in_hour);

    const minutes = @divTrunc(total_seconds, seconds_in_minute);

    const seconds = @rem(total_seconds, seconds_in_minute);

    std.debug.print("Until target date: {} days {} hours {} minutes {} seconds\n", .{ days, hours, minutes, seconds });
}
