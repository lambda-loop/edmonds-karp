
const std = @import("std");

// version with only f64
fn NetworkFlow (comptime Node: type) type {
    const FlowCtx = struct { f64, f64 };

    const InternalGraph = Graph(Node, FlowCtx);
    return struct {
        graph: InternalGraph,
        s    : Node, // source
        t    : Node, // terminal
        
        pub fn init (allocator: std.mem.Allocator, source: Node, terminal: Node) @This() {
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
            try self.addNode(node);
        }
        
        pub fn addEdge (
            self: *@This(),
            from: Node,
            info: FlowCtx,
            to  : Node
        ) !void { 
            try self.addEdge(from, info, to);
        }

        pub fn print (self: @This()) !void {
            try self.print();
        }
    };
}


fn homeworkGraph (allocator: std.mem.Allocator) NetworkFlow {
    var network_flow = NetworkFlow(u8).init(allocator, 's', 't');
    for ('A'..'J') |C| try network_flow.addNode(C);

    // from s:
    try network_flow.addEdge('s', .{ 0, 7 } ,'A');
    try network_flow.addEdge('s', .{ 0, 2 } ,'B');
    try network_flow.addEdge('s', .{ 0, 1 } ,'C');

    // from A: 
    try network_flow.addEdge('A', .{ 0, 2 } ,'D');
    try network_flow.addEdge('A', .{ 0, 4 } ,'E');
    try network_flow.addEdge('A', .{ 0, 5 } ,'B');

    
    // from B: 
    try network_flow.addEdge('B', .{ 0, 5 } ,'E');
    try network_flow.addEdge('B', .{ 0, 6 } ,'F');

    // .. 

}

// the Edge type talks about what the edges cares other the two nodes
// in between it
fn Graph (comptime Node: type, comptime Edge: type) type {
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

// for testing
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var graph = Graph(u32, f64).init(allocator);
    defer graph.deinit();

    try graph.addNode(0);
    try graph.addNode(1);
    try graph.addNode(2);
    try graph.addNode(3);
    try graph.addNode(4);
    

    try graph.addEdge(0, 64.0, 1);
    try graph.addEdge(1, 24.1, 2);
    try graph.addEdge(2, 44.3, 3);
    try graph.addEdge(3, 4.4, 4);

    // try graph.addEdge(3, 64.0, 4);
    try graph.print();



}
    

