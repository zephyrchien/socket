const std = @import("std");
const os = std.os;
const net = std.net;

const socket = @import("socket");
const Socket = socket.Socket;

const addr = net.Address.parseIp("127.0.0.1", 8080) catch unreachable;

pub fn main() !void {
    const sock = try Socket.open(os.AF.INET, os.SOCK.STREAM, 0);
    defer sock.close();

    try sock.setReuseAddr(true);
    try sock.bind(&addr);
    try sock.listen(1024);

    var client_addr: net.Address = undefined;
    const client = try sock.accept(&client_addr, 0);
    defer client.close();
    std.debug.print("client from {}\n", .{&client_addr});

    var buf: [1024]u8 = undefined;
    const recvn = try client.recv(&buf, 0);
    std.debug.print("{s}", .{buf[0..recvn]});
    const sendn = try client.send(buf[0..recvn], 0);
    std.debug.assert(recvn == sendn);
}
