const std = @import("std");
const os = std.os;
const net = std.net;

const socket = @import("socket");
const Socket = socket.Socket;

const addr = net.Address.parseIp("1.1.1.1", 80) catch unreachable;
const request = "GET / HTTP/1.1\r\nHost: 1.1.1.1\r\n\r\n";

pub fn main() !void {
    const sock = try Socket.open(os.AF.INET, os.SOCK.STREAM, 0);
    defer sock.close();

    var buf: [1024]u8 = undefined;
    try sock.connect(&addr);
    const local_addr = try sock.localAddr();
    const peer_addr = try sock.peerAddr();
    std.debug.print("{} -> {}\n", .{&local_addr, &peer_addr});

    const sendn = try sock.send(request, 0);
    std.debug.assert(sendn == request.len);

    const recvn = try sock.recv(&buf, 0);
    std.debug.print("{s}", .{buf[0..recvn]});
}
