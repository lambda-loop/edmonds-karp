
const std         = @import("std");
const Graph       = @import("Graph.zig").Graph;
const NetworkFlow = @import("NetworkFlow.zig").NetworkFlow;


fn homeworkGraph (allocator: std.mem.Allocator) !NetworkFlow(u8) {
    var network_flow = try NetworkFlow(u8).init(allocator, 's', 't');
    for ('A'..'J') |C| try network_flow.addNode(  @as(u8, @intCast(C))  );

    // from s:
    try network_flow.addEdge('s', .{ 0, 7 } ,'A');
    try network_flow.addEdge('s', .{ 0, 2 } ,'B');
    try network_flow.addEdge('s', .{ 0, 1 } ,'C');

    // from A: 
    try network_flow.addEdge('A', .{ 0, 2 } ,'D');
    try network_flow.addEdge('A', .{ 0, 4 } ,'E'); // WARNING: ambiguos with C->D
    try network_flow.addEdge('A', .{ 0, 5 } ,'B'); // WARNING: image didnt had a weight
    
    // from B: 
    try network_flow.addEdge('B', .{ 0, 5 } ,'E');
    try network_flow.addEdge('B', .{ 0, 6 } ,'F');

    // from C: 
    try network_flow.addEdge('C', .{ 0, 4 } ,'D'); // WARNING: ambiguos with A->E
    try network_flow.addEdge('C', .{ 0, 8 } ,'H');

    // from D:
    try network_flow.addEdge('D', .{ 0, 7 } ,'G');
    try network_flow.addEdge('D', .{ 0, 1 } ,'H');

    // from E:
    try network_flow.addEdge('E', .{ 0, 3 } ,'G');
    try network_flow.addEdge('E', .{ 0, 3 } ,'I');
    try network_flow.addEdge('E', .{ 0, 8 } ,'F');

    // from F:
    try network_flow.addEdge('F', .{ 0, 3 } ,'I');
    
    // from G:
    try network_flow.addEdge('G', .{ 0, 1 } ,'t');

    // from H:
    try network_flow.addEdge('H', .{ 0, 3 } ,'t');

    // from I:
    try network_flow.addEdge('I', .{ 0, 4 } ,'t');

    return network_flow;
}

// the Edge type talks about what the edges cares other the two nodes
// in between it

// for testing
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const graph = try homeworkGraph(allocator);

    try graph.print();



}
    

