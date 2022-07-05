`define INITIAL_C         4'b0000 
`define CHECK_OFFSET      4'b0001 
`define OCTANT_1          4'b0010 
`define OCTANT_2          4'b0011 
`define OCTANT_4          4'b0100 
`define OCTANT_3          4'b0101 
`define OCTANT_5          4'b0110 
`define OCTANT_6          4'b0111 
`define OCTANT_8          4'b1000 
`define OCTANT_7          4'b1001 
`define INC_OFFSET_Y      4'b1010 
`define CHECK_CRIT        4'b1011 
`define UPDATE_A          4'b1100 
`define UPDATE_B_1        4'b1101 
`define UPDATE_B_2        4'b1110 
`define DONE_C            4'b1111 

module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);
     // draw the circle

     logic [6:0] offset_y;
     logic load_offset_y;

     logic [7:0] offset_x;
     logic load_offset_x;

     logic signed [9:0] crit;
     logic load_crit_a;
     logic load_crit_b;


     register_circle_offset_y rcoy(clk, start, offset_y, load_offset_y);
     register_circle_offset_x rcox(clk, start, offset_x, load_offset_x, radius);
     register_circle_crit rcc(clk, start, crit, load_crit_a, load_crit_b, offset_y, offset_x, radius);

     logic [3:0] state;

     statemachine_mooremachine_c smfc(clk, start, offset_y, offset_x, crit, state);
     statemachine_combinational_c scfc(state, offset_y, offset_x, centre_x, centre_y, colour,
                                       load_offset_y, load_offset_x, 
                                       load_crit_a, load_crit_b,
                                        vga_x, vga_y, vga_colour, vga_plot, done);

endmodule

module register_circle_offset_y(input logic clk, input logic start,             // register module
            output logic [6:0] offset_y, input logic load_offset_y);

            always_ff @(posedge clk) begin
            if (start == 1'b0)
                offset_y <= 7'b0000000;
            else if (load_offset_y == 1'b1)
                offset_y <= offset_y + 7'b0000001;
            else
                offset_y <= offset_y;
        end
endmodule

module register_circle_offset_x(input logic clk, input logic start,             // register module
            output logic [7:0] offset_x, input logic load_offset_x, input logic [7:0] radius);

            always_ff @(posedge clk) begin
            if (start == 1'b0)
                offset_x <= radius;
            else if (load_offset_x == 1'b1)
                offset_x <= offset_x - 8'b00000001;
            else
                offset_x <= offset_x;
        end
endmodule

module register_circle_crit (input logic clk, 
                                input logic start, 
                                output logic [9:0] crit, 
                                input logic load_crit_a, 
                                input logic load_crit_b, 
                                input logic [6:0] offset_y, 
                                input logic [7:0] offset_x,
                                input logic [7:0] radius);

          always_ff @(posedge clk) begin
            if (start == 1'b0)
                crit <= (8'b00000001 - radius);
            else if (load_crit_a == 1'b1)
                crit <= (crit + 8'b00000010 * offset_y + 8'b00000001);
            else if (load_crit_b == 1'b1)
                crit <= (crit + 8'b00000010 * (offset_y - offset_x) + 8'b00000001);
            else
                crit <= crit;
        end        
endmodule

module statemachine_mooremachine_c(input logic clk, input logic start, 
                                   input logic [6:0] offset_y, input logic [7:0] offset_x, 
                                   input logic [9:0] crit, 
                                   output logic [3:0] state);
    
    logic [3:0] present_state;

    always @(posedge clk) begin

        if (start == 1'b0) begin // goes through FSM when start is 1
            present_state = `INITIAL_C;
        end else begin
            case(present_state)

             `INITIAL_C: present_state = `CHECK_OFFSET;

             `CHECK_OFFSET: if (offset_y <= offset_x)
                            present_state = `OCTANT_1;
                            else
                            present_state = `DONE_C;

             `OCTANT_1: present_state = `OCTANT_2;

             `OCTANT_2: present_state = `OCTANT_4;

             `OCTANT_4: present_state = `OCTANT_3;

             `OCTANT_3: present_state = `OCTANT_5;

             `OCTANT_5: present_state = `OCTANT_6;

             `OCTANT_6: present_state = `OCTANT_8;

             `OCTANT_8: present_state = `OCTANT_7;

             `OCTANT_7: present_state = `INC_OFFSET_Y;

             `INC_OFFSET_Y: present_state = `CHECK_CRIT;

             `CHECK_CRIT: if (crit[9] == 1'b1)
                            present_state = `UPDATE_A;
                            else
                            present_state = `UPDATE_B_1;

             `UPDATE_A: present_state = `CHECK_OFFSET;

             `UPDATE_B_1: present_state = `UPDATE_B_2;

             `UPDATE_B_2: present_state = `CHECK_OFFSET;

             `DONE_C: present_state = `DONE_C;

            default: present_state = 4'bxxxx;
                            
    
            endcase
        end

        state = present_state;
    
    end

endmodule

module statemachine_combinational_c(input logic [3:0] state, 
                                    input logic [6:0] offset_y, 
                                    input logic [7:0] offset_x, 
                                    input logic [7:0] centre_x, 
                                    input logic [6:0] centre_y,
                                    input logic [2:0] colour,
                                    output logic load_offset_y, 
                                    output logic load_offset_x, 
                                    output logic load_crit_a,
                                    output logic load_crit_b,
                                    output logic [7:0] vga_x, 
                                    output logic [6:0] vga_y, 
                                    output logic [2:0] vga_colour, 
                                    output logic vga_plot, 
                                    output logic done);

     always @(state or offset_y or offset_x or centre_x or centre_y or colour) begin
    
        case(state)
        
        `INITIAL_C: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                done <= 1'b0;
            end

            `CHECK_OFFSET: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                done <= 1'b0;
            end

            `OCTANT_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;
    
                vga_x <=            centre_x + offset_x;
                vga_y <=            centre_y + offset_y;

                if ((centre_x + offset_x) > 159 || (centre_y + offset_y) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end
          
                done <= 1'b0;
            end

            `OCTANT_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            centre_x + offset_y;
                vga_y <=            centre_y + offset_x[6:0];

                if ((centre_x + offset_y) > 159 || (centre_y + offset_x) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end

                done <= 1'b0;
            end

            `OCTANT_4: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            centre_x - offset_x;
                vga_y <=            centre_y + offset_y;

                if ((centre_x - offset_x) > 159 || (centre_y + offset_y) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end 

                done <= 1'b0;
            end

            `OCTANT_3: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            centre_x - offset_y;
                vga_y <=            centre_y + offset_x[6:0];

                if ((centre_x - offset_y) > 159 || (centre_y + offset_x) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end 

                done <= 1'b0;
            end

            `OCTANT_5: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            centre_x - offset_x;
                vga_y <=            centre_y - offset_y;

                if ((centre_x - offset_x) > 159 || (centre_y - offset_y) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end 

                done <= 1'b0;
            end

            `OCTANT_6: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            centre_x - offset_y;
                vga_y <=            centre_y - offset_x[6:0];

                if ((centre_x - offset_y) > 159 || (centre_y - offset_x) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end

                done <= 1'b0;
            end

            `OCTANT_8: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            centre_x + offset_x;
                vga_y <=            centre_y - offset_y;

                if ((centre_x + offset_x) > 159 || (centre_y - offset_y) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end

                done <= 1'b0;
            end

            `OCTANT_7: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;
                
                vga_x <=            centre_x + offset_y;
                vga_y <=            centre_y - offset_x[6:0];

                if ((centre_x + offset_y) > 159 || (centre_y - offset_x) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end 

                done <= 1'b0;
            end

            `INC_OFFSET_Y: begin
                load_offset_y <=    1'b1;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                done <= 1'b0;
            end

            `CHECK_CRIT: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                done <= 1'b0;
            end

            `UPDATE_A: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b1;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                done <= 1'b0;
            end

            `UPDATE_B_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b1;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                done <= 1'b0;
            end

            `UPDATE_B_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b1;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                done <= 1'b0;
            end

            `DONE_C: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                done <= 1'b1;
            end

            default: begin
                load_offset_y <=    1'bx;
                load_offset_x <=    1'bx;
                load_crit_a <=      1'bx;
                load_crit_b <=      1'bx;

                vga_x <=            8'bxxxxxxxx;
                vga_y <=            7'bxxxxxxx;
                vga_colour <=       3'bxxx;
                vga_plot <=         1'bx; 

                done <= 1'bx;
            end

        endcase
    end

endmodule