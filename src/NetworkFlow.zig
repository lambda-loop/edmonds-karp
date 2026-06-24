
const std   = @import("std");
const Graph = @import("Graph.zig").Graph;

// version with only f64
pub fn NetworkFlow (comptime Node: type) type {

    const FlowCtx = struct { 
        used      : f64, 
        available : f64,
    };

    const InternalGraph = Graph(Node, FlowCtx);
    return struct {
        graph: InternalGraph,
        s    : Node, // source
        t    : Node, // target

        pub fn init (allocator: std.mem.Allocator, source: Node, terminal: Node) !@This() {
            var graph = InternalGraph.init(allocator);
            try graph.addNode(source);
            try graph.addNode(terminal);
            return .{
                .graph = graph,
                .s     = source,
                .t     = terminal,
            };
        }

        pub fn deinit (self: *@This()) @This() {
            self.graph.deinit();
            self.s.deinit();
            self.t.deinit();
        }

        pub fn addNode (self: *@This(), node: Node) !void {
            try self.graph.addNode(node);
        }

        pub fn addEdge (
        self: *@This(),
        from: Node,
        info: FlowCtx,
        to  : Node
    ) !void { 
            try self.graph.addEdge(from, info, to);
        }

        pub fn print (self: @This()) !void {
            var keys = std.ArrayList(Node).empty;
            defer keys.deinit(self.graph.allocator);
            var max_outs = std.ArrayList(struct { Node, Node }).empty;
            defer max_outs.deinit(self.graph.allocator); // WARNING: works with `.empty`?
            std.debug.print ("My edges: --------------------------\n", .{});

            var iter = self.graph.data.iterator();
            while (iter.next()) |entry| {
                try keys.append(self.graph.allocator, entry.key_ptr.*);
                // var inner_iter = entry.value_ptr.keyIterator();
                var iter_inner = entry.value_ptr.iterator();
                while (iter_inner.next()) |entry_inner| {
                    const from = entry.key_ptr.*;
                    const with = entry_inner.value_ptr.*;
                    const to   = entry_inner.key_ptr.*;

                    if (with.used == -1) continue;
                    if (with.available == 0) {
                        try max_outs.append(self.graph.allocator, .{from, to});
                    }

                    if (Node == u8) {
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

            if (Node == u8) {
                std.debug.print ("My nodes: --------------------------\n", .{});
                for (keys.items) |key| {
                    std.debug.print (
                        "{c}, ",
                        .{key},
                    );
                }
            } else {

                std.debug.print ("My nodes: --------------------------\n", .{});
                for (keys.items) |key| {
                    std.debug.print (
                        "{any}, ",
                        .{key},
                    );
                }
            }


            std.debug.print ("\n\nMy MAXEDOUT EDGES: --------------------------\n", .{});
            if (Node == u8) {
                for (max_outs.items) |edge| {
                    std.debug.print (
                        "{c} -> {c}, ",
                        .{ edge.@"0", edge.@"1" },
                    );
                }
            } else {
                for (max_outs.items) |edge| {
                    std.debug.print (
                        "{any} -> {any}, ",
                        .{ edge.@"0", edge.@"1" },
                    );
                }
            }

        }
        
        pub fn searchForSAP (self: @This()) !?Graph(Node, f64) {
            var visited = std.AutoHashMap(Node, void).init(self.graph.allocator);
            try visited.put(self.s, {});
            var bfs = init_bfs: { 
                var bfs = Graph (Node, f64).init(self.graph.allocator);

                var iter = self.graph.data.keyIterator();
                while (iter.next()) |key_ptr| {
                    try bfs.addNode(key_ptr.*);
                }

                break :init_bfs bfs;
            };

            var to_explore = std.Deque(Node).empty;
            defer to_explore.deinit(self.graph.allocator);

            try to_explore.pushBack(self.graph.allocator, self.s);
            // var currently_visiting = self.s;

            while (to_explore.len > 0) {
                const currentlyVisiting = to_explore.popFront() orelse unreachable;
                // TODO: if its empty, then use `continue` after resetupping
                const neighbours      = self.graph.data.get(currentlyVisiting).?;
                var   neighbours_iter = neighbours.iterator();
                while (neighbours_iter.next()) |*entry| {
                    const node = entry.key_ptr.*;
                    const info = entry.value_ptr.*;
                    if (info.available > 0) {

                        if (node == self.t) {
                            try bfs.addEdge (
                            node, 
                            info.available,
                            currentlyVisiting,
                        );

                            return bfs;
                        }

                        if (!visited.contains(node)) {
                            try visited.put(node, {});
                            try to_explore.pushBack(self.graph.allocator, node);
                            try bfs.addEdge (
                            node, 
                            info.available, 
                            currentlyVisiting,
                        );
                        }
                    }
                }
            }

            return null;
        }

        // The `s` and `t` will be here
        // TODO: use array instead of ArrayList
        pub fn findPathWithInfo (self: @This()) !?struct { std.ArrayList(Node), f64 } {
            const g: Graph(Node, f64) = try self.searchForSAP() orelse return null;
            var path = std.Deque(Node).empty;
            defer path.deinit(self.graph.allocator);

            var currently_visiting = self.t;

            var iter_to_fst = g.data.get(self.t).?.iterator();
            var min = iter_to_fst.next().?.value_ptr.*;

            while (currently_visiting != self.s) {
                try path.pushFront(self.graph.allocator, currently_visiting);

                const previousEdge = getPreviousEdge: {
                    var iter_to_previous = g.data.get(currently_visiting).?.iterator();
                    const entry = iter_to_previous.next().?;
                    break :getPreviousEdge .{ entry.value_ptr.*, entry.key_ptr.* };
                };

                if (previousEdge[0] < min) min = previousEdge[0];
                currently_visiting = previousEdge[1];
            }

            var path_array = std.ArrayList(Node).empty;
            var iter = path.iterator();
            try path_array.append(self.graph.allocator, self.s);
            while (iter.next()) |node| try path_array.append(self.graph.allocator, node);

            return .{ path_array, min };
        }

        // used -1 means the red edges
        // The returning edges (WARNING: modifyes ur networkflow) 
        pub fn EdmondsKarp(self: *@This()) !void {

            while (true) {
                const opt_path_info = try self.findPathWithInfo();
                if (opt_path_info) |path_info| {
                    var path = path_info.@"0";
                    const min  = path_info.@"1";
                    defer path.deinit(self.graph.allocator);

                    std.debug.print("new path: ", .{});
                    if (Node == u8 ) {
                        for (path.items) |item| 
                            std.debug.print("{c} -> ", .{item}); 
                    } else { 
                        for (path.items) |item| 
                            std.debug.print("{any} -> ", .{item});
                    }
                    

                    std.debug.print(" with {d:.2}\n", .{min});

                    // update graph
                    for (0..path.items.len-1) |i| {
                        const from: Node = path.items[i]; 
                        const to  : Node = path.items[i+1];

                        const info_ptr = self.graph
                        .data
                        .getPtr(from).?
                        .getPtr(to).?;

                        // if its a red arrow!
                        if (info_ptr.used == -1) {
                            info_ptr.available -= min;

                            // cause its red, we know that a white version exists!
                            const white_ptr = self.graph
                            .data
                            .getPtr(to).?
                            .getPtr(from).?;

                            white_ptr.available += min;
                            white_ptr.used      -= min;

                        } else { // if its a white arrow!
                            info_ptr.available -= min;
                            info_ptr.used      += min;


                            // we dont have any garantees about this one cause 
                            // we had not create all the reds at the beggining..
                            const opt_red_ptr = self.graph
                            .data
                            .getPtr(to).?
                            .getPtr(from);

                            if (opt_red_ptr) |red_ptr| red_ptr.available += min
                            else try self.graph.data
                            .getPtr(to).?
                            .put(from, .{
                                .available = min,
                                .used     = -1,
                            });
                        }
                    }
                } else break;

                // try self.print();
            }
        }




    };
}
