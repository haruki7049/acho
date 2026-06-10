const std = @import("std");
const lightmix = @import("lightmix");

pub fn inner(
    /// A type for Wave(T)
    comptime T: type,
    /// Channel type
    comptime C: type,
) type {
    return struct {
        const Self = @This();
        const Referee = fn (self: Self) anyerror![]const C;

        allocator: std.mem.Allocator,
        sources: std.ArrayList(lightmix.Wave(T)),
        referee: Referee,
        index: usize,

        pub fn init(allocator: std.mem.Allocator, referee: Referee) !Self {
            return .{ .allocator = allocator, .sources = .empty, .referee = referee, .index = 0 };
        }

        pub fn deinit(self: Self) void {
            // The sources' deinit
            for (self.sources.items) |wave| {
                wave.deinit();
            }
            self.sources.deinit(self.allocator);
        }

        pub fn run(self: *Self) !void {}

        pub fn gen() !lightmix.Wave(T) {}

        test "gen" {
            var acho: Self = try init();
            defer acho.deinit();
        }
    };
}
