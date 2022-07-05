module tb_syn_fillscreen();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

logic clk;
logic rst_n;
logic [2:0] colour;
logic start;
logic done;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;
logic vga_plot;

fillscreen dut(clk, rst_n, colour, start, done, vga_x, vga_y, vga_colour, vga_plot);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

endmodule: tb_syn_fillscreen
