`timescale 1ns / 1ps
`timescale 1ns / 1ps

module tb();

// Parameters
localparam CLK_PERIOD = 10; 

// Signals
logic [23:0] data_in;
logic [15:0] data_out;
logic clk, rst;

// Instantiate the DUT
codec dut (
    .data_in(data_in),
    .data_out(data_out),
    .clk(clk),
    .rst(rst)
);

// Clock generation
initial begin
    clk = 1'b0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test procedure
initial begin
    // Initialize inputs
    data_in = 24'h0;
    rst = 1'b1;
    
    // Reset the system
    #(CLK_PERIOD*2);
    rst = 1'b0;
    
    // Test case 1: Zero input
    data_in = 24'h000000;
    #(CLK_PERIOD);
    $display("Input: %h, Output: %h", data_in, data_out);
    
    // Test case 2: Maximum positive input
    data_in = 24'h7FFFFF;
    #(CLK_PERIOD*2); // Wait 2 cycles to see the effect of dithering
    $display("Input: %h, Output: %h", data_in, data_out);
    
    // Test case 3: Maximum negative input
    data_in = 24'h800000;
    #(CLK_PERIOD*2);
    $display("Input: %h, Output: %h", data_in, data_out);
    
    // Test case 4: Random values
    for (int i = 0; i < 10; i++) begin
        data_in = $random;
        #(CLK_PERIOD*2);
        $display("Input: %h, Output: %h", data_in, data_out);
    end
    
    // Test case 5: Small positive value (to observe dithering effect)
    data_in = 24'h000100; // Small value where dithering will be noticeable
    #(CLK_PERIOD*10); 
    $display("Observing dithering effect on small value:");
    for (int i = 0; i < 10; i++) begin
        $display("Cycle %0d: Output: %h", i, data_out);
        #(CLK_PERIOD);
    end
    
    $finish;
end

// Monitor for checking behavior
always @(posedge clk) begin
    if (!rst) begin
        if (data_in > 24'h7FFFFF) begin
            if (data_out !== 16'h7FFF) begin
                $warning("Positive overflow not handled as expected");
            end
        end
        else if (data_in < 24'h800000) begin
            if (data_out !== 16'h8000) begin
                $warning("Negative overflow not handled as expected");
            end
        end
    end
end

endmodule