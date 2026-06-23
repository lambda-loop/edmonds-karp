
const std         = @import("std");
const Graph       = @import("Graph.zig").Graph;
const NetworkFlow = @import("NetworkFlow.zig").NetworkFlow;


fn homeworkGraph (allocator: std.mem.Allocator) !NetworkFlow(u8) {
    var network_flow = try NetworkFlow(u8).init(allocator, 's', 't');
    for ('A'..'J') |C| try network_flow.addNode(  @as(u8, @intCast(C))  );

    // from s:
    try network_flow.addEdge('s', .{ .used = 0, .available =  7 } ,'A');
    try network_flow.addEdge('s', .{ .used = 0, .available =  2 } ,'B');
    try network_flow.addEdge('s', .{ .used = 0, .available =  1 } ,'C');

    // from A: 
    try network_flow.addEdge('A', .{ .used = 0, .available =  2 } ,'D');
    try network_flow.addEdge('A', .{ .used = 0, .available =  4 } ,'E'); // WARNING: ambiguos with C->D
    try network_flow.addEdge('A', .{ .used = 0, .available =  5 } ,'B'); // WARNING: image didnt had a weight
    
    // from B: 
    try network_flow.addEdge('B', .{ .used = 0, .available =  5 } ,'E');
    try network_flow.addEdge('B', .{ .used = 0, .available =  6 } ,'F');

    // from C: 
    try network_flow.addEdge('C', .{ .used = 0, .available =  4 } ,'D'); // WARNING: ambiguos with A->E
    try network_flow.addEdge('C', .{ .used = 0, .available =  8 } ,'H');

    // from D:
    try network_flow.addEdge('D', .{ .used = 0, .available =  7 } ,'G');
    try network_flow.addEdge('D', .{ .used = 0, .available =  1 } ,'H');

    // from E:
    try network_flow.addEdge('E', .{ .used = 0, .available =  3 } ,'G');
    try network_flow.addEdge('E', .{ .used = 0, .available =  3 } ,'I');
    try network_flow.addEdge('E', .{ .used = 0, .available =  8 } ,'F');

    // from F:
    try network_flow.addEdge('F', .{ .used = 0, .available =  3 } ,'I');
    
    // from G:
    try network_flow.addEdge('G', .{ .used = 0, .available =  1 } ,'t');

    // from H:
    try network_flow.addEdge('H', .{ .used = 0, .available =  3 } ,'t');

    // from I:
    try network_flow.addEdge('I', .{ .used = 0, .available =  4 } ,'t');

    return network_flow;
}

// the Edge type talks about what the edges cares other the two nodes
// in between it

// for testing
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const networkFlow= try homeworkGraph(allocator);

    // try graph.print();
    const g = try networkFlow.searchForSAP();
    if (g) |graph| {
        try graph.print();
    }

    std.debug.print("\n\n{any}\n", .{try networkFlow.findPathWithInfo()});
    // var deque = std.Deque(u8).empty;
    // try deque.pushFront(allocator, 42);
    // try deque.pushFront(allocator, 16);
    // try deque.pushFront(allocator, 21);
    //
    // std.debug.print(
    //     "\n\n{any}\n",
    //     .{ deque.items }
    // );
    //
    //
    //
    //

}
    

