
const std         = @import("std");
const Graph = @import("Graph.zig").Graph;
const NetworkFlow = @import("NetworkFlow").NetworkFlow;


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
    

