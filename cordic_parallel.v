module cordic_parallel #(parameter WIDTH = 16, STAGES = 16) (
    input clk,
    input rst,
    input signed [WIDTH-1:0] x_in,
    input signed [WIDTH-1:0] y_in,
    input signed [WIDTH-1:0] angle_in,
    output signed [WIDTH-1:0] x_out,
    output signed [WIDTH-1:0] y_out
);

    // Define the angles as constants
    reg signed [WIDTH-1:0] atan_table [0:STAGES-1];

   initial begin
        atan_table[0] = 16'h2000; // arctan(2^-0) * (2^WIDTH-2)
        atan_table[1] = 16'h12DA; // arctan(2^-1) * (2^WIDTH-2)
        atan_table[2] = 16'h09F8; // arctan(2^-2) * (2^WIDTH-2)
        atan_table[3] = 16'h0510; // arctan(2^-3) * (2^WIDTH-2)
        atan_table[4] = 16'h028A; // arctan(2^-4) * (2^WIDTH-2)
        atan_table[5] = 16'h0145; // arctan(2^-5) * (2^WIDTH-2)
        atan_table[6] = 16'h00A3; // arctan(2^-6) * (2^WIDTH-2)
        atan_table[7] = 16'h0051; // arctan(2^-7) * (2^WIDTH-2)
        atan_table[8] = 16'h0028; // arctan(2^-8) * (2^WIDTH-2)
        atan_table[9] = 16'h0014; // arctan(2^-9) * (2^WIDTH-2)
        atan_table[10] = 16'h000A; // arctan(2^-10) * (2^WIDTH-2)
        atan_table[11] = 16'h0005; // arctan(2^-11) * (2^WIDTH-2)
        atan_table[12] = 16'h0002; // arctan(2^-12) * (2^WIDTH-2)
        atan_table[13] = 16'h0001; // arctan(2^-13) * (2^WIDTH-2)
        atan_table[14] = 16'h0000; // arctan(2^-14) * (2^WIDTH-2)
        atan_table[15] = 16'h0000; // arctan(2^-15) * (2^WIDTH-2)
    end

    // Pipeline registers for x, y, and angle
    reg signed [WIDTH-1:0] x [0:STAGES-1];
    reg signed [WIDTH-1:0] y [0:STAGES-1];
    reg signed [WIDTH-1:0] z [0:STAGES-1];


    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < STAGES; i = i + 1) begin
                x[i] <= 0;
                y[i] <= 0;
                z[i] <= 0;
            end
        end else begin
            // Initialize the first stage with input values
				
				case(angle_in[(WIDTH-1):(WIDTH-3)])
				
						3'b000: begin	// 0 .. 45, No change
							x[0] <= x_in;
							y[0] <= y_in;
							z[0] <= angle_in;
							end
							
						3'b001: begin	// 45 .. 90
							x[0] <= -y_in;
							y[0] <= x_in;
							z[0] <= angle_in - 16'h4000;
							end
							
						3'b010: begin	// 90 .. 135
							x[0] <= -y_in;
							y[0] <= x_in;
							z[0] <= angle_in - 16'h4000;
							end
							
						3'b011: begin	// 135 .. 180
						
							x[0] <= -x_in;
							y[0] <= -y_in;
							z[0] <= angle_in - 16'h8000;
							end
							
						3'b100: begin	// 180 .. 225
							x[0] <= -x_in;
							y[0] <= -y_in;
							z[0] <= angle_in - 16'h8000;
							end
							
						3'b101: begin	// 225 .. 270
						
							x[0] <= y_in;
							y[0] <= -x_in;
							z[0] <= angle_in + 16'h4000;
							end
						3'b110: begin	// 270 .. 315
							x[0] <= y_in;
							y[0] <= -x_in;
							z[0] <= angle_in + 16'h4000;
							end
			
						3'b111: begin	// 315 .. 360, No change
							x[0] <= x_in;
							y[0] <= y_in;
							z[0] <= angle_in;
							end
							
						endcase
									

            // Perform pipelined CORDIC computation
            for (i = 1; i < STAGES; i = i + 1) begin
                if (z[i-1] >= 0) begin
                    x[i] <= x[i-1] - (y[i-1] >>> (i-1));
                    y[i] <= y[i-1] + (x[i-1] >>> (i-1));
                    z[i] <= z[i-1] - atan_table[i-1];
                end else begin
                    x[i] <= x[i-1] + (y[i-1] >>> (i-1));
                    y[i] <= y[i-1] - (x[i-1] >>> (i-1));
                    z[i] <= z[i-1] + atan_table[i-1];
                end
            end
        end
    end

    // Assign the outputs from the last stage of the pipeline
    // Apply the scaling factor to the final output
    assign x_out = x[STAGES-1] ;
    assign y_out = y[STAGES-1];

endmodule


