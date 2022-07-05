`timescale 1 ps / 1 ps

module tb_rtl_circle();

// Your testbench goes here. Our toplevel will give up after 1;000;000 ticks.

circle dut(.*);

logic clk;
logic rst_n;  
logic [2:0] colour;
logic [7:0] centre_x;  
logic [6:0] centre_y;  
logic [7:0] radius;
logic start;  
logic done;
logic [7:0] vga_x;  
logic [6:0] vga_y;
logic [2:0] vga_colour;  
logic vga_plot;

// custom testbench wires
assign centre_x = 8'd80;  
assign centre_y = 8'd60;  
assign radius = 8'd40;

logic [6:0] tb_offset_y;
logic [7:0] tb_offset_x;

logic signed [9:0] tb_crit;

int count = 0;

// drawCircle(centre_x, centre_y, radius):
//     offset_y = 0
//     offset_x = radius
//     crit = 1 - radius
//     while offset_y ≤ offset_x:
//         setPixel(centre_x + offset_x, centre_y + offset_y)   -- octant 1
//         setPixel(centre_x + offset_y, centre_y + offset_x)   -- octant 2
//         setPixel(centre_x - offset_x, centre_y + offset_y)   -- octant 4
//         setPixel(centre_x - offset_y, centre_y + offset_x)   -- octant 3
//         setPixel(centre_x - offset_x, centre_y - offset_y)   -- octant 5
//         setPixel(centre_x - offset_y, centre_y - offset_x)   -- octant 6
//         setPixel(centre_x + offset_x, centre_y - offset_y)   -- octant 8
//         setPixel(centre_x + offset_y, centre_y - offset_x)   -- octant 7
//         offset_y = offset_y + 1
//         if crit ≤ 0:
//             crit = crit + 2 * offset_y + 1
//         else:
//             offset_x = offset_x - 1
//             crit = crit + 2 * (offset_y - offset_x) + 1


initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

start = 1'b0;

tb_offset_y = 0;  
tb_offset_x = radius;
tb_crit = 1 - radius;  

#10;
start = 1'b1;

#20;
while (tb_offset_y <= tb_offset_x) begin
    
    if (count == 0) begin
        $display("--- entered while --- ");
    end

    if (vga_x != (centre_x + tb_offset_x) || vga_y != (centre_y + tb_offset_y)) begin
        $display("incorrect coordinate setPixel(1) (%d)", count);
        $display("vga_x = %d", vga_x);
        $display("vga_y = %d", vga_y);
        $display("centre_x + tb_offset_x = %d ", centre_x + tb_offset_x);
        $display("centre_y + tb_offset_y = %d",centre_y + tb_offset_y);
        $stop;
    end

    count++;
    #10;
    if (vga_x != (centre_x + tb_offset_y) || vga_y != (centre_y + tb_offset_x)) begin
        $display("incorrect coordinate setPixel(2) (%d)", count);
    end
    count++;
    #10;
    if (vga_x != (centre_x - tb_offset_x) || vga_y != (centre_y + tb_offset_y)) begin
        $display("incorrect coordinate setPixel(3) (%d)", count);
    end
    count++;
    #10;
    if (vga_x != (centre_x - tb_offset_y) || vga_y != (centre_y + tb_offset_x)) begin
        $display("incorrect coordinate setPixel(4) (%d)", count);
    end
    count++;
    #10;
    if (vga_x != (centre_x - tb_offset_x) || vga_y != (centre_y - tb_offset_y)) begin
        $display("incorrect coordinate setPixel(5) (%d)", count);
    end
    count++;
    #10;
    if (vga_x != (centre_x - tb_offset_y) || vga_y != (centre_y - tb_offset_x)) begin
        $display("incorrect coordinate setPixel(6) (%d)", count);
    end
    count++;
    #10;
    if (vga_x != (centre_x + tb_offset_x) || vga_y != (centre_y - tb_offset_y)) begin
        $display("incorrect coordinate setPixel(7) (%d)", count);
    end
    count++;
    #10;
    if (vga_x != (centre_x + tb_offset_y) || vga_y != (centre_y - tb_offset_x)) begin
        $display("incorrect coordinate setPixel(8) (%d)", count);
    end

    #10;   

    tb_offset_y = tb_offset_y + 1;

    if (tb_crit[9] == 1'b1) begin
       $display("CRIT IS NEGATIVE. crit = %d (%d)", tb_crit, count); 
       tb_crit = tb_crit + (2 * tb_offset_y) + 1; 
    end
    else begin
        $display("CRIT IS POSITIVE. crit = %d (%d)", tb_crit, count);
        tb_offset_x = tb_offset_x - 1;
        #10;
        tb_crit = tb_crit + (2 * (tb_offset_y - tb_offset_x)) + 1;
    end
    
    #40;
end

$display("finished loop (%d)", count);




// if (dut.state !== `INITIAL) begin
//         $display("Wrong. Not at INITIAL state");
//         $stop;
// end

end


endmodule: tb_rtl_circle
