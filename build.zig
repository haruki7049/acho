const std = @import("std");
const l = @import("lightmix");

pub fn build(b: *std.Build) anyerror!void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Dependencies
    const lightmix = b.dependency("lightmix", .{});

    // Modules
    const mod = b.createModule(.{
        .root_source_file = b.path("src/acho.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "lightmix", .module = lightmix.module("lightmix") },
        },
    });

    // Library linking on Linux
    if (target.result.os.tag == .linux) {
        mod.linkSystemLibrary("alsa", .{});
        mod.linkSystemLibrary("libpulse", .{});
        mod.linkSystemLibrary("libpipewire-0.3", .{});
    }

    // Static Library Install
    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "acho",
        .root_module = mod,
    });
    b.installArtifact(lib);

    // Unit tests
    const unit_tests = b.addTest(.{ .root_module = mod });
    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Test step
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
