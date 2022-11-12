const std = @import("std");
const os = std.os;
const net = std.net;

const socket = @import("socket");
const Socket = socket.Socket;

const addr = net.Address.parseIp("127.0.0.1", 8080) catch unreachable;

pub fn main() !void {
    const sock = try Socket.open(os.AF.INET, os.SOCK.DGRAM, 0);
    defer sock.close();

    try sock.setReuseAddr(true);
    try sock.bind(&addr);

    var buf: [1024]u8 = undefined;
    var client_addr: net.Address = undefined;

    const recvn = try sock.recvfrom(&buf, 0, &client_addr);
    std.debug.print("from {}: {s}", .{&client_addr, buf[0..recvn]});
    const sendn = try sock.sendto(buf[0..recvn], 0, &client_addr);
    std.debug.assert(recvn == sendn);
}
