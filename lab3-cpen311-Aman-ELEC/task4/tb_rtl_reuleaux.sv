`timescale 1 ps / 1 ps


`define INITIAL_R         6'b000000 

`define CHECK_OFFSET      6'b000001 
`define OCTANT_1          6'b000010 
`define OCTANT_2          6'b000011 
`define OCTANT_4          6'b000100 
`define OCTANT_3          6'b000101 
`define OCTANT_5          6'b000110 
`define OCTANT_6          6'b000111 
`define OCTANT_8          6'b001000 
`define OCTANT_7          6'b001001 
`define INC_OFFSET_Y      6'b001010 
`define CHECK_CRIT        6'b001011 
`define UPDATE_A          6'b001100 
`define UPDATE_B_1        6'b001101 
`define UPDATE_B_2        6'b001110 

`define RESET_1           6'b101100 
`define CHECK_OFFSET_1    6'b001111 
`define OCTANT_1_1        6'b010000 
`define OCTANT_2_1        6'b010001 
`define OCTANT_4_1        6'b010010 
`define OCTANT_3_1        6'b010011 
`define OCTANT_5_1        6'b010100 
`define OCTANT_6_1        6'b010101 
`define OCTANT_8_1        6'b010110 
`define OCTANT_7_1        6'b010111 
`define INC_OFFSET_Y_1    6'b011000 
`define CHECK_CRIT_1      6'b011001 
`define UPDATE_A_1        6'b011010 
`define UPDATE_B_1_1      6'b011011 
`define UPDATE_B_2_1      6'b011100 

`define RESET_2           6'b101101 
`define CHECK_OFFSET_2    6'b011101 
`define OCTANT_1_2        6'b011110 
`define OCTANT_2_2        6'b011111 
`define OCTANT_4_2        6'b100000 
`define OCTANT_3_2        6'b100001 
`define OCTANT_5_2        6'b100010 
`define OCTANT_6_2        6'b100011 
`define OCTANT_8_2        6'b100100 
`define OCTANT_7_2        6'b100101 
`define INC_OFFSET_Y_2    6'b100110 
`define CHECK_CRIT_2      6'b100111 
`define UPDATE_A_2        6'b101000 
`define UPDATE_B_1_2      6'b101001 
`define UPDATE_B_2_2      6'b101010 

`define DONE_R            6'b101011 

module tb_rtl_reuleaux();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

reuleaux dut(.*);

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

// custom testbench wires
assign centre_x = 8'd80;  
assign centre_y = 8'd60;  
assign diameter = 8'd80;

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


int tb_c_x1;
int tb_c_x2;
int tb_c_x3;

int tb_c_y1;
int tb_c_y2;
int tb_c_y3;


initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

start = 1'b0;

tb_offset_y = 0;  
tb_offset_x = diameter;
tb_crit = 1 - diameter;  

#10;
start = 1'b1;

// $display("test1 %d",(centre_y + diameter * $sqrt(3)/6));

// Testing corner values
     // assign c_x = centre_x;
     // assign c_y = centre_y;
     // assign c_x1 = c_x + diameter/2;
     // assign c_y1 = c_y + diameter * $sqrt(3)/6;
     // assign c_x2 = c_x - diameter/2;
     // assign c_y2 = c_y + diameter * $sqrt(3)/6;
     // assign c_x3 = c_x;
     // assign c_y3 = c_y - diameter * $sqrt(3)/3;

tb_c_y1 = centre_y + diameter * $sqrt(3)/6;
tb_c_y2 = centre_y + diameter * $sqrt(3)/6;
tb_c_y3 = centre_y - diameter * $sqrt(3)/3;

tb_c_x1 = centre_x + diameter/2;
tb_c_x2 = centre_x - diameter/2;
tb_c_x3 = centre_x;


assert(dut.c_y1_temp == tb_c_y1 )
    else $error("Incorrect c_y1_temp value.");

assert(dut.c_y2_temp == tb_c_y2)
    else $error("Incorrect c_y2_temp value.");

assert(dut.c_y3_temp == tb_c_y3)
    else $error("Incorrect c_y3_temp value.");

assert(dut.c_x1 == tb_c_x1)
    else $error("Incorrect c_x1_temp value.");

assert(dut.c_x2_temp == tb_c_x2)
    else $error("Incorrect c_x2_temp value.");

assert(dut.c_x3 == tb_c_x3)
    else $error("Incorrect c_x3_temp value.");
    
// testing states

assert(dut.state == `INITIAL_R)
    else $error("Incorrect INITIAL_R state.");
#10;

#7090;
// for (int i = 0; i < 1000; i++) begin
//     if (dut.state == `RESET_1) begin
//         $display("RESET1 --- (%d)", i);
//         $stop;
//     end
//     #10;

// end

$display("state: %d", dut.state);

assert(dut.state == `RESET_1)
    else $error("Incorrect reset1 state.");


#50000;

assert(dut.state == `DONE_R)
    else $error("Incorrect DONE_R state.");
#10;
/*
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
       // $display("CRIT IS NEGATIVE. crit = %d (%d)", tb_crit, count); 
       tb_crit = tb_crit + (2 * tb_offset_y) + 1; 
    end
    else begin
        // $display("CRIT IS POSITIVE. crit = %d (%d)", tb_crit, count);
        tb_offset_x = tb_offset_x - 1;
        #10;
        tb_crit = tb_crit + (2 * (tb_offset_y - tb_offset_x)) + 1;
    end
    
    #40;
end
*/

$display("finished loop (%d)", count);




// if (dut.state !== `INITIAL) begin
//         $display("Wrong. Not at INITIAL state");
//         $stop;
// end

end
endmodule: tb_rtl_reuleaux
