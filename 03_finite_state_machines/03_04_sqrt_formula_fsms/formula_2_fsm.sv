//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);
    // Task:
    // Implement a module that calculates the folmula from the `formula_2_fn.svh` file
    // using only one instance of the isrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value

    //------------------------------------------------------------------------
    // States

    enum logic [1:0]
    {
        st_idle     = 2'b00,
        st_wait_c   = 2'b01,
        st_wait_cb  = 2'b10,
        st_wait_cba = 2'b11
    }
    state, next_state;

    //------------------------------------------------------------------------
    // Next state and isqrt interface

    always_comb
    begin
        next_state  = state;

        isqrt_x_vld = '0;
        isqrt_x     = 'x;  // Don't care

        case (state)
        st_idle:
        begin
            isqrt_x = c;

            if (arg_vld)
            begin
                isqrt_x_vld = '1;
                next_state  = st_wait_c;
            end
        end

        st_wait_c:
        begin
            if (isqrt_y_vld)
            begin
                isqrt_x = b + isqrt_y;
                isqrt_x_vld = '1;
                next_state  = st_wait_cb;
            end
        end

        st_wait_cb:
        begin
            if (isqrt_y_vld)
            begin
                isqrt_x = a + isqrt_y;
                isqrt_x_vld = '1;
                next_state  = st_wait_cba;
            end
        end

        st_wait_cba:
        begin
            if (isqrt_y_vld)
            begin
                next_state = st_idle;
            end
        end
        endcase
    end

    //------------------------------------------------------------------------
    // Assigning next state

    always_ff @ (posedge clk)
        if (rst)
            state <= st_idle;
        else
            state <= next_state;

    //------------------------------------------------------------------------
    // Accumulating the result

    always_ff @ (posedge clk)
        if (rst)
            res_vld <= '0;
        else
            res_vld <= ((state == st_wait_cba) & isqrt_y_vld);

    always_ff @ (posedge clk)
        if (state == st_idle)
            res <= '0;
        else if (isqrt_y_vld)
            res <= isqrt_y;


endmodule
