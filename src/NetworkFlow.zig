
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
            try self.graph.print();
        }

        pub fn searchForSAP (self: @This()) !?Graph(Node, f64) {
            var visited = std.AutoHashMap(Node, void).init(self.graph.allocator);
            var bfs = init_bfs: { 
                var bfs = Graph (Node, f64).init(self.graph.allocator);

                var iter = self.graph.data.keyIterator();
                while (iter.next()) |key_ptr| {
                    try bfs.addNode(key_ptr.*);
                }

                break :init_bfs bfs;
            };

            var to_explore = std.Deque(Node).empty;
            try to_explore.pushBack(self.graph.allocator, self.s);
            // var currently_visiting = self.s;

            while (to_explore.len > 0) {
                const currentlyVisiting = to_explore.popFront() orelse unreachable;
                // TODO: if its empty, then use `continue` after resetupping
                const neighbours = self.graph.data.get(currentlyVisiting).?;
                for (neighbours.items) |edge| {
                    const node = edge[1];

                    if (node == self.t) {
                        try bfs.addEdge (
                        node, 
                        edge[0].available, 
                        currentlyVisiting
                    );

                        return bfs;
                    }

                    if (!visited.contains(node) and
                    edge[0].available > 0) {

                        try visited.put(node, {});
                        try to_explore.pushBack(self.graph.allocator, node);
                        try bfs.addEdge (
                        node, 
                        edge[0].available, 
                        currentlyVisiting
                    );

                    }
                }

            }

            return null;
        }

        // The deque will not care about the t and s, cause they're trivial.
        // TODO: use array instead of ArrayList
        pub fn findPathWithInfo (self: @This()) !?struct { std.ArrayList(Node), f64 } {
            const g: Graph(Node, f64) = try self.searchForSAP() orelse return null;
            var path = std.Deque(Node).empty;

            var currently_visiting = self.t;

            var min = g.data.get(self.t).?.items[0][0];

            while (currently_visiting != self.s) {
                const previousEdge = g.data.get(currently_visiting).?.items[0];

                if (previousEdge[0] < min) min = previousEdge[0];
                currently_visiting = previousEdge[1];

                if (currently_visiting == self.s) break;
                try path.pushFront(self.graph.allocator, currently_visiting);
            }

            var path_array = std.ArrayList(Node).empty;
            var iter = path.iterator();
            while (iter.next()) |node| try path_array.append(self.graph.allocator, node);

            return .{ path_array, min };
        }

        // used -1 means the red edges
        // The returning edges (WARNING: modifyes ur networkflow) 
        pub fn EdmondsKarp(self: *@This()) !void {

            while (true) {
                const opt_path_info = try self.findPathWithInfo();
                if (opt_path_info) |path_info| {
                    const path = path_info.@"0";
                    const min  = path_info.@"1";

                    
                    _ = min;
                    for (0..path.@"0".len-1) |i| {
                        const from: Node = path.@"0"[i]; 
                        const to  : Node = path.@"0"[i+1];

                        const edge_ptr = find_edge: {
                            const from_ptr = try self.graph.data.getPtr(from);
                            for (&from_ptr.items) |*edge| {
                                if (edge.*.@"2" == to) 
                                break :find_edge;
                            }
                        };
                        _ = edge_ptr;

                        



                    }


                } else break;


            }
        }




    };
}
