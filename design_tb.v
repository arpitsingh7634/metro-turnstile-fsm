`timescale 1ns/1ps

module tb_fsm1;

    reg        clk = 1'b0;
    reg        rst_n;
    reg        validate_code;
    reg  [3:0] access_code;
    wire       open_access_door;
    wire [1:0] state_out;

    fsm1 dut (
        .clk             (clk),
        .rst_n           (rst_n),
        .validate_code   (validate_code),
        .access_code     (access_code),
        .open_access_door(open_access_door),
        .state_out       (state_out)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

 
    initial
        $monitor("t=%4t ns | code=%2d validate=%b | state=%0d | door=%b",
                 $time, access_code, validate_code, state_out, open_access_door);

    
    task press(input [3:0] code);
        begin
            @(negedge clk);
            validate_code = 1'b1;
            access_code   = code;
            @(negedge clk);
            validate_code = 1'b0;
            @(negedge clk);
            wait (state_out == 2'b00);
            repeat (2) @(negedge clk);
        end
    endtask

    initial begin
        rst_n         = 1'b0;
        validate_code = 1'b0;
        access_code   = 4'd0;

        repeat (3) @(negedge clk);
        rst_n = 1'b1;

        press(4'd9);     // valid
        press(4'd2);     // invalid
        press(4'd4);     // valid (boundary)
        press(4'd12);    // invalid (boundary)
        press(4'd11);    // valid (boundary)
        press(4'd3);     // invalid (boundary)

        $display("Demo finished");
        $finish;
    end

endmodule
