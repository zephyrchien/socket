const std = @import("std");
const builtin = @import("builtin");
const sys = @import("sys.zig");
const os = std.os;
const net = std.net;

pub const Socket = struct {
    handle: os.socket_t,

    const Self = @This();

    pub fn open(domain: u32, ty: u32, proto: u32) os.SocketError!Self {
        const handle = try os.socket(domain, ty, proto);
        return .{.handle = handle};
    }

    pub fn close(self: Self) void {
        os.closeSocket(self.handle);
    }

    pub fn bind(self: Self, addr: *const net.Address) os.BindError!void {
        return os.bind(self.handle, &addr.any, addr.getOsSockLen());
    }

    pub fn connect(self: Self, addr: *const net.Address) os.ConnectError!void {
        return os.connect(self.handle, &addr.any, addr.getOsSockLen());
    }

    pub fn listen(self: Self, backlog: u31) os.ListenError!void {
        return os.listen(self.handle, backlog);
    }

    pub fn accept(self: Self, addr: ?*net.Address, flags: u32) os.AcceptError!Self {
        var handle: os.socket_t = undefined;
        if (addr) |sa| {
            var len: u32 = @sizeOf(net.Address);
            @memset(@ptrCast([*]u8, sa), 0, len);
            handle = try os.accept(self.handle, &sa.any, &len, flags);
        } else {
            handle = try os.accept(self.handle, null, null, flags);
        }
        return .{.handle = handle};
    }

    pub fn send(self: Self, buf: []const u8, flags: u32) os.SendError!usize {
        return os.send(self.handle, buf, flags);
    }

    pub fn sendto(self: Self, buf: []const u8, flags: u32, addr: *const net.Address) os.SendToError!usize {
        return os.sendto(self.handle, buf, flags, &addr.any, addr.getOsSockLen());
    }

    pub fn recv(self: Self, buf: []u8, flags: u32) os.RecvFromError!usize {
        return os.recv(self.handle, buf, flags);
    }

    pub fn recvfrom(self: Self, buf: []u8, flags: u32, addr: ?*net.Address) os.RecvFromError!usize {
        if (addr) |sa| {
            var len: u32 = @sizeOf(net.Address);
            @memset(@ptrCast([*]u8, sa), 0, len);
            return try os.recvfrom(self.handle, buf, flags, &sa.any, &len);
        } else {
            return os.recvfrom(self.handle, buf, flags, null, null);
        }
    }

    pub fn shutdown(self: Self, how: os.ShutdownHow) os.ShutdownError!void {
        return os.shutdown(self.handle, how);
    }

    pub fn localAddr(self: Self) os.GetSockNameError!net.Address {
        var addr = std.mem.zeroes(net.Address);
        var len: u32 = @sizeOf(net.Address);
        try os.getsockname(self.handle, &addr.any, &len);
        return addr;
    }

    pub fn peerAddr(self: Self) os.GetSockNameError!net.Address {
        var addr = std.mem.zeroes(net.Address);
        var len: u32 = @sizeOf(net.Address);
        try os.getpeername(self.handle, &addr.any, &len);
        return addr;
    }

    // ========== socket option ==========
    pub fn setOption(self: Self, level: u32, opt: u32, ptr: anytype) os.SetSockOptError!void {
        return os.setsockopt(self.handle, level, opt, std.mem.asBytes(ptr));
    }
    
    pub fn setNonblocking(self: Self, nonblocking: bool) os.FcntlError!void {
        return sys.setNonblocking(self.handle, nonblocking);
    }

    // ========== SOL_SOCKET ==========
    pub const setReuseAddr = optflag(os.SOL.SOCKET, os.SO.REUSEADDR);
    pub const setBroadcast = optflag(os.SOL.SOCKET, os.SO.BROADCAST);

    // ========== IPPROTO ==========
    pub const setOnlyV6 = optflag(os.IPPROTO.IPV6, os.IPV6.V6ONLY);
    pub const setNodelay = optflag(os.IPPROTO.TCP, os.TCP.nodelay);
};

fn optflag(comptime level: u32, comptime opt: u32) 
    fn(Socket, bool) os.SetSockOptError!void {
    const F = struct {
        fn f(socket: Socket, b: bool) os.SetSockOptError!void {
            const val = if (b) @as(c_int, 1) else @as(c_int, 0);
            return os.setsockopt(socket.handle, level, opt, std.mem.asBytes(&val));
        }
    };
    return F.f;
}
