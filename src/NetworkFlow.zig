
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



    };
}
