`define WAIT                2'b00 
`define START_ON            2'b01 
`define START_OFF           2'b10 

`timescale 1 ps / 1 ps

module tb_rtl_task2();

// Your testbench goes here.

task2 dut(.*);

logic CLOCK_50;
logic [3:0] KEY;
logic [9:0] SW;  
logic [9:0] LEDR;
logic [6:0] HEX0;  
logic [6:0] HEX1;  
logic [6:0] HEX2;
logic [6:0] HEX3;  
logic [6:0] HEX4;  
logic [6:0] HEX5;
logic [7:0] VGA_R;  
logic [7:0] VGA_G;  
logic [7:0] VGA_B;
logic VGA_HS;  
logic VGA_VS;  
logic VGA_CLK;
logic [7:0] VGA_X;  
logic [6:0] VGA_Y;
logic [2:0] VGA_COLOUR;  
logic VGA_PLOT;

initial begin
    CLOCK_50 = 0;
    forever #1 CLOCK_50 = ~CLOCK_50;
end

initial begin

KEY[3] = 1'b1;
#2;
KEY[3] = 1'b0;

    // WAIT
    assert(dut.state == 2'b00)
    else $error("Incorrect WAIT state");
    #10;

    // START_ON
    assert(dut.state == 2'b01)
    else $error("Incorrect START_ON state");
    #193630;

    // START_OFF
    assert(dut.state == 2'b10)
    else $error("Incorrect START_OFF state");
    #10;

end

endmodule: tb_rtl_task2
