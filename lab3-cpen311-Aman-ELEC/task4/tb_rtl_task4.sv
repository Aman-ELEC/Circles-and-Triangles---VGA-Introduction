`define WAIT                   3'b000 
`define START_FS_ON            3'b001 
`define START_FS_OFF           3'b010 
`define START_R_ON             3'b011 
`define START_R_OFF            3'b100 

`timescale 1 ps / 1 ps

module tb_rtl_task4();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

task4 dut(.*);

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
    forever #5 CLOCK_50 = ~CLOCK_50;
end

initial begin

KEY[3] = 1'b1;

#10;
KEY[3] = 1'b0;

    // WAIT
    assert(dut.state == 3'b000)
    else $error("Incorrect WAIT state");
    #10;

    // START_FS_ON
    assert(dut.state == 3'b001)
    else $error("Incorrect START_FS_ON state");
    #193630;

    // START_FS_OFF
    assert(dut.state == 3'b010)
    else $error("Incorrect START_FS_OFF state");
    #10;

    // START_R_ON
    assert(dut.state == 3'b011)
    else $error("Incorrect START_R_ON state");
    #21310;

    // START_R_OFF
    assert(dut.state == 3'b100)
    else $error("Incorrect START_R_OFF state");
    #10;

end
endmodule: tb_rtl_task4
