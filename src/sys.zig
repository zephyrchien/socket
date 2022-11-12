const builtin = @import("builtin");
pub const unix = @import("sys/unix.zig");
pub const windows = @import("sys/windows.zig");
pub usingnamespace switch(builtin.os.tag) {
    .windows => windows,
    else     => unix,
};
