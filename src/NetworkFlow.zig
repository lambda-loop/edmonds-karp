
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
        t    : Node, // terminal
        
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

        pub fn searchForSAP (self: @This()) ?void {
            var visited = std.AutoHashMap(Node, void).init(self.graph.allocator);
            const len = self.graph.data.count();

            var to_explore = std.Deque(Node).empty;
            to_explore.pushBack(self.s);
            // var currently_visiting = self.s;

            // TODO: better condition when?
            while (visited.count() < len) {
                
                // TODO: if its empty, then use `continue` after resetupping
                var iter = self.graph.data.get(to_explore.front()).?;
                while (iter.next()) |node| {
                    if (!visited.contains(node)) {
                        visited.put(node);
                        to_explore.pushBack(self.graph.allocator, node);
                    }

                }

                to_explore.popFront();
            }




        }



    };
}
