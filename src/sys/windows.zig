const std = @import("std");
const os = std.os;
const win32 = os.windows.ws2_32;

pub fn setNonblocking(socket: os.socket_t, nonblocking: bool) os.FcntlError!void {
    var val = if (nonblocking) @as(u32, 1) else @as(u32, 0);
    if (win32.ioctlsocket(socket, win32.FIONBIO, &val) < 0) {
        return os.UnexpectedError;
    }
}
