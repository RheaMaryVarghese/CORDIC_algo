`timescale 1ns / 1ps

module cordic_parallel_tb;

    parameter WIDTH = 16;
    parameter STAGES = 16;

    // Inputs
    reg clk;
    reg rst;
    reg signed [WIDTH-1:0] x_in;
    reg signed [WIDTH-1:0] y_in;
    reg signed [WIDTH-1:0] angle_in;

    // Outputs
    wire signed [WIDTH-1:0] x_out;
    wire signed [WIDTH-1:0] y_out;

    // Declare real variables for floating-point calculations
    real cosine_val;
    real sine_val;

    // Instantiate the Unit Under Test (UUT)
    cordic_parallel #(WIDTH, STAGES) uut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .y_in(y_in),
        .angle_in(angle_in),
        .x_out(x_out),
        .y_out(y_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock, 10ns period
    end

    // Function to convert fixed-point Q1.15 to floating-point
    function real fixed_to_float;
        input signed [WIDTH-1:0] fixed_point_value;
        begin
            // Divide the fixed-point value by 32768 (2^15) to get the float value
            fixed_to_float = fixed_point_value / 32768.0;
        end
    endfunction

    // Test vector generation for different angles
    initial begin
        // Initialize Inputs
        rst = 1;
        x_in = 16'h4db2; // x = 1 (fixed-point, Q1.15)
        y_in = 16'h0000; // y = 0 (fixed-point, Q1.15)
		  angle_in = 16'h0000;
		  rst = 0;
		  // Loop over angles from 0 to 360 degrees (in Q1.15 format, equivalent to 0 to 32768)
        repeat (1024) begin
            angle_in = angle_in + 16'h0192; // Increment angle (256 steps for a full sine wave)

            #10; // Wait for some clock cycles

            // Convert the fixed-point output to floating-point for verification
            cosine_val = fixed_to_float(x_out);
            sine_val = fixed_to_float(y_out);

            // Print the results
            $display("Angle: %d, Cosine: %f, Sine: %f", angle_in, cosine_val, sine_val);
        end

		  
		  //Trigonometric Functions
		  
//        // Test case for 30 degrees
//        angle_in = 16'h1555; // 30 degrees in Q1.15 format
//        #20;
//        rst = 0;
//        #160; // Wait for pipeline to finish
//        cosine_val = fixed_to_float(x_out);
//        sine_val = fixed_to_float(y_out);
//        $display("Angle: 30 degrees, cosine: %f, sine: %f", cosine_val, sine_val);
//
//        // Test case for 45 degrees
//        rst = 1;
//        #20;
//        angle_in = 16'h2000; // 45 degrees in Q1.15 format
//        #20;
//        rst = 0;
//        #160; // Wait for pipeline to finish
//        cosine_val = fixed_to_float(x_out);
//        sine_val = fixed_to_float(y_out);
//        $display("Angle: 45 degrees, cosine: %f, sine: %f", cosine_val, sine_val);
//
//        // Test case for 60 degrees
//        rst = 1;
//        #20;
//        angle_in = 16'h2aaa; // 60 degrees in Q1.15 format
//        #20;
//        rst = 0;
//        #160; // Wait for pipeline to finish
//        cosine_val = fixed_to_float(x_out);
//        sine_val = fixed_to_float(y_out);
//        $display("Angle: 60 degrees, cosine: %f, sine: %f", cosine_val, sine_val);
//
//        // Test case for 90 degrees
//        rst = 1;
//        #20;
//        angle_in = 16'h4000; // 90 degrees in Q1.15 format
//        #20;
//        rst = 0;
//        #160; // Wait for pipeline to finish
//        cosine_val = fixed_to_float(x_out);
//        sine_val = fixed_to_float(y_out);
//        $display("Angle: 90 degrees, cosine: %f, sine: %f", cosine_val, sine_val);

        // Finish simulation
        #20;
        $stop;
    end

endmodule
