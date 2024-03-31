module formula_1_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output logic res_vld,
    output logic [31:0] res
);
    // Task:
    //
    // Implement a pipelined module formula_1_pipe that computes the result
    // of the formula defined in the file formula_1_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_1_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm
    localparam pipe_stages = 16;
    logic [15:0] ret1;
    logic [15:0] ret2;
    logic [15:0] ret3;

    
    logic ret1_vld;
    logic ret2_vld;
    logic ret3_vld;
    
    isqrt #(.n_pipe_stages(pipe_stages)) sqrt_inst1
    (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld),
        .x(a),
        .y_vld(ret1_vld),
        .y(ret1)
    );

    isqrt #(.n_pipe_stages(pipe_stages)) sqrt_inst2
    (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld),
        .x(b),
        .y_vld(ret2_vld),
        .y(ret2)
    );

    isqrt #(.n_pipe_stages(pipe_stages)) sqrt_inst3
    (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld),
        .x(c),
        .y_vld(ret3_vld),
        .y(ret3)
    );

    always_ff@(posedge clk) begin
        if (rst)
            res_vld <= 0;
        else
            res_vld <= ret1_vld && ret2_vld && ret3_vld;
    end

    always_ff@(posedge clk) begin
        if (rst)
            res <= 0;
        else
            res <= ret1 + ret2 + ret3;   
    end

endmodule