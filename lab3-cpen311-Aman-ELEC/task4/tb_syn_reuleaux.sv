module tb_syn_reuleaux();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

logic clk;
logic rst_n;  
logic [2:0] colour;
logic [7:0] centre_x;  
logic [6:0] centre_y;  
logic [7:0] diameter;
logic start;  
logic done;
logic [7:0] vga_x;  
logic [6:0] vga_y;
logic [2:0] vga_colour;  
logic vga_plot;

reuleaux dut(clk, rst_n, colour, centre_x, centre_y, 
           diameter, start, done, vga_x, vga_y, vga_colour, vga_plot);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

endmodule: tb_syn_reuleaux
