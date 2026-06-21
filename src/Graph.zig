const std = @import("std");

pub fn Graph (comptime Node: type, comptime Edge: type) type {
    const EdgeData = struct { Edge, Node };
    return struct {
        data: std.AutoHashMap(Node, std.ArrayList(EdgeData)),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) @This() {
            return .{
                .data = std.AutoHashMap(Node, std.ArrayList(EdgeData)).init(allocator),
                .allocator = allocator,
            };
        }

        pub fn deinit (self: *@This()) void {
            var iter = self.data.keyIterator();
            while (iter.next()) |key_ptr| 
                self.data.getPtr(key_ptr.*).?.deinit(self.allocator);

            self.data.deinit();
        }

        pub fn addNode (self: *@This(), node: Node) !void {
            // TODO: provide a better error handling
            if (self.data.contains(node)) unreachable;
            
            const newHashMap = std.ArrayList(EdgeData).empty;
            try self.data.put(node, newHashMap);
        }
        
        pub fn addEdge (
            self: *@This(),
            from: Node,
            info: Edge,
            to  : Node
        ) !void { 
            // TODO: also provide a better error handling right here
            if (!self.data.contains(to) or !self.data.contains(from)) 
                unreachable;

            const edgesFrom_ptr = self.data.getPtr(from).?;
            // TODO: DO
            // if (edgesFrom_ptr.contains(.{ info, to })) unreachable;

            try edgesFrom_ptr.append(self.allocator ,.{info, to});
        }

        pub fn print (self: @This()) !void {
            var keys = std.ArrayList(Node).empty;
            std.debug.print ("My edges: --------------------------\n", .{});

            var iter = self.data.iterator();
            while (iter.next()) |entry| {
                try keys.append(self.allocator, entry.key_ptr.*);
                // var inner_iter = entry.value_ptr.keyIterator();
                for (entry.value_ptr.items) | edgeData | {
                    const from = entry.key_ptr.*;
                    const with = edgeData.@"0";
                    const to   = edgeData.@"1";

                    std.debug.print (
                        "Im coming from: {any}, with: {any}, to: {any}\n",
                        .{ from, with, to},
                    );
                
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
