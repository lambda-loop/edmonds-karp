const std = @import("std");

pub fn Graph (comptime N: type, comptime I: type) type {
    return struct {
        
        // OBS: Its enough to represent multiGraphs cause u could always 
        // represent them with I being some kind of colletion.
        data: std.AutoHashMap(N, std.AutoHashMap(N, I)),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) @This() {
            return .{
                .data = std.AutoHashMap(N, std.AutoHashMap(N, I)).init(allocator),
                .allocator = allocator,
            };
        }

        pub fn deinit (self: *@This()) void {
            var iter = self.data.keyIterator();
            while (iter.next()) |key_ptr| 
                self.data.getPtr(key_ptr.*).?.deinit(self.allocator);

            self.data.deinit();
        }

        pub fn addNode (self: *@This(), node: N) !void {
            // TODO: provide a better error handling
            if (self.data.contains(node)) unreachable;
            
            const newHashMap = std.AutoHashMap(N, I).init(self.allocator);
            try self.data.put(node, newHashMap);
        }
        
        pub fn addEdge (
            self: *@This(),
            from: N,
            info: I,
            to  : N
        ) !void { 
            // TODO: also provide a better error handling right here
            if (!self.data.contains(to) or !self.data.contains(from)) 
                unreachable;

            const edge_ptr = self.data.getPtr(from).?;
            // TODO: DO
            // if (edges.contains(.{ info, to })) unreachable;

            try edge_ptr.put(to, info);
        }

        pub fn print (self: @This()) !void {
            var keys = std.ArrayList(N).empty;
            std.debug.print ("My edges: --------------------------\n", .{});

            var iter = self.data.iterator();
            while (iter.next()) |entry| {
                try keys.append(self.allocator, entry.key_ptr.*);
                // var inner_iter = entry.value_ptr.keyIterator();
                var iter_inner = entry.value_ptr.iterator();
                while (iter_inner.next()) |entry_inner| {
                    const from = entry.key_ptr.*;
                    const with = entry_inner.value_ptr.*;
                    const to   = entry_inner.key_ptr.*;


                    if (N == u8) {
                        std.debug.print (
                            "Im coming from: {c}, with: {any}, to: {c}\n",
                            .{ from, with, to},
                        );
                    } else {
                        std.debug.print (
                            "Im coming from: {any}, with: {any}, to: {any}\n",
                            .{ from, with, to},
                        );

                    }
                
                }
            }

            std.debug.print ("My keys: --------------------------\n", .{});
            for (keys.items) |key| {
                std.debug.print (
                    "{any}, ",
                    .{key},
                );
            }
        }


        
    };
}
