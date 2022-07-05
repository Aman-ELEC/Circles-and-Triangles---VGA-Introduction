`timescale 1 ps / 1 ps

`define INITIAL             4'b0000 
`define CHECK_X             4'b0001 
`define CHECK_Y             4'b0010 
`define FILL                4'b0011 
`define SET_LOAD_Y          4'b0100 
`define INC_Y               4'b0101 
`define RESET_Y             4'b0110 
`define SET_LOAD_X          4'b0111 
`define INC_X               4'b1000 
`define DONE                4'b1001 

module tb_rtl_fillscreen();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

// Your testbench goes here.

fillscreen dut(.*);

logic clk;
logic rst_n;
logic [2:0] colour;
logic start;
logic done;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;
logic vga_plot;

logic [7:0] count_x;
assign count_x = 8'b00000000;

logic [6:0] count_y;
assign count_y = 7'b0000000;


initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

start = 1'b0;
#10;
start = 1'b1;

if (dut.state !== `INITIAL) begin
        $display("Wrong. Not at INITIAL state");
        $stop;
end

if (dut.state == `FILL && dut.vga_x == 8'd0 && dut.vga_y == 7'd0) begin
    if (dut.vga_colour !== 3'd0) begin
        $display("incorrect VGA colour (3'd0)");
        $stop;
    end
    if (dut.vga_plot !== 1'b1) begin
        $display("first pixel not plotted");
        $stop;

    end
        
end

if (dut.vga_x == count_x) begin
    $display("dut.vga_x == i (0)");
end
else begin
    $display("dut.vga_x NOT EQ i (0)");

end

for (int x = 0; x < 160; x++) begin
    
    for (int y = 0; y < 120; y++) begin

        if (dut.vga_x == count_x) begin
        $display("dut.vga_x == i (0)");
        end
        else begin
            $display("dut.vga_x NOT EQ i (0)");

        end


    #10;

    end

end

 // last pixel test

    // if (dut.vga_x == 8'd159 && dut.vga_y == 7'd119) begin
    //     if (dut.vga_colour !== 3'd7) begin
    //         $display("not right end VGA color");
    //         $stop;
    //     end
    //     if (dut.vga_plot !== 1'b1) begin
    //         $display("last pixel not plotted");
    //         //$stop;
    //     end
    //     //$display("correct final VGA colour");    
    // end
end

endmodule: tb_rtl_fillscreen
