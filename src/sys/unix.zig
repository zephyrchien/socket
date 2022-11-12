const std = @import("std");
const os = std.os;

pub fn fcntlAdd(fd: os.fd_t, get: i32, set: i32, flag: u32) os.FcntlError!void {
    const old_flag = try os.fcntl(fd, get, 0);
    const new_flag = old_flag | flag;
    if (new_flag != old_flag) {
        return os.fcntl(fd, set, new_flag);
    }
}

pub fn fcntlRemove(fd: os.fd_t, get: i32, set: i32, flag: u32) os.FcntlError!void {
    const old_flag = try os.fcntl(fd, get, 0);
    const new_flag = old_flag & ~flag;
    if (new_flag != old_flag) {
        return os.fcntl(fd, set, new_flag);
    }
}

pub fn setNonblocking(fd: os.socket_t, nonblocking: bool) os.FcntlError!void {
    const get = os.F.GETFL;
    const set = os.F.SETFL;
    if (nonblocking) {
        return fcntlAdd(fd, get, set, os.O.NONBLOCK);
    } else {
        return fcntlRemove(fd, get, set, os.O.NONBLOCK);
    }
}
