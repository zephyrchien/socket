const std = @import("std");
const Pkg = std.build.Pkg;
const Builder = std.build.Builder;
const Mode = std.builtin.Mode;
const CrossTarget = std.zig.CrossTarget;

const socket = Pkg {
    .name = "socket",
    .source = .{.path = "src/lib.zig"},
};

fn bin(b: *Builder, mode: *const Mode, target: *const CrossTarget,
    comptime source: []const[]const u8) void {
    inline for (source) |s| {
        const file = b.addExecutable(s, "examples/" ++ s ++ ".zig");
        file.setBuildMode(mode.*);
        file.setTarget(target.*);
        file.addPackage(socket);
        file.install();
    }
}

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    const lib = b.addStaticLibrary("socket", "src/lib.zig");
    lib.setBuildMode(mode);
    lib.install();

    bin(b, &mode, &target, &.{"accept", "connect", "udp"});
}
