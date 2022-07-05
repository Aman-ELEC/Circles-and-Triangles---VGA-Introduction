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

module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);
     // draw the Reuleaux triangle
 
     logic [7:0] offset_y;
     logic load_offset_y;
     logic reset_offset_y;

     logic [7:0] offset_x;
     logic load_offset_x;
     logic reset_offset_x;

     logic signed [9:0] crit;
     logic load_crit_a;
     logic load_crit_b;
     logic reset_crit;

     // assign c_x = centre_x;
     // assign c_y = centre_y;
     // assign c_x1 = c_x + diameter/2;
     // assign c_y1 = c_y + diameter * $sqrt(3)/6;
     // assign c_x2 = c_x - diameter/2;
     // assign c_y2 = c_y + diameter * $sqrt(3)/6;
     // assign c_x3 = c_x;
     // assign c_y3 = c_y - diameter * $sqrt(3)/3;

     logic [7:0] c_x3;                                      // centre for now
     assign c_x3 = centre_x;

     logic [6:0] c_y3;                                      // centre for now
     logic [50:0] c_y3_temp;
     assign c_y3_temp = (centre_y - ((diameter * 30'b100010011010011010101001111101) / 30'b111011100110101100101000000000));

    logic [50:0] c_y3_temp_2;
    assign c_y3_temp_2 = c_y3_temp[50] ? -c_y3_temp : c_y3_temp;

     assign c_y3 = c_y3_temp_2[6:0];

     logic [7:0] c_x1;                                      // bottom right for now
     assign c_x1 = (centre_x + diameter/8'b00000010);

     logic [6:0] c_y1;                                      // bottom right for now
     logic [50:0] c_y1_temp; 
     assign c_y1_temp = (centre_y + ((diameter * 30'b010001001101001101010100111110) / 30'b111011100110101100101000000000));
     assign c_y1 = c_y1_temp[6:0];

     logic [7:0] c_x2;                                      // bottom left for now
     logic [50:0] c_x2_temp;
     logic [50:0] c_x2_temp_2;
     assign c_x2_temp = (centre_x - diameter/8'b00000010);
     assign c_x2_temp_2 = c_x2_temp[50] ? -c_x2_temp : c_x2_temp;
     assign c_x2 = c_x2_temp_2[7:0];

     logic [6:0] c_y2;                                      // bottom left for now
     logic [50:0] c_y2_temp;
     assign c_y2_temp = (centre_y + ((diameter * 30'b010001001101001101010100111110) / 30'b111011100110101100101000000000));
     assign c_y2 = c_y2_temp[6:0];

    //  always@(diameter, centre_y) begin
    //     c_y3 <= (centre_y - ((diameter * 30'b100010011010011010101001111101) / 30'b111011100110101100101000000000));
    //     c_y1 <= (centre_y + ((diameter * 30'b010001001101001101010100111110) / 30'b111011100110101100101000000000));
    //     c_y2 <= (centre_y + ((diameter * 30'b010001001101001101010100111110) / 30'b111011100110101100101000000000));
    //  end

     register_r_offset_y rroy(clk, start, offset_y, load_offset_y, reset_offset_y);
     register_r_offset_x rrox(clk, start, offset_x, load_offset_x, diameter, reset_offset_x);
     register_r_crit rrc(clk, start, crit, load_crit_a, load_crit_b, offset_y, offset_x, diameter, reset_crit);

     logic [5:0] state;

     statemachine_mooremachine_r smr(clk, start, offset_y, offset_x, crit, state);
     statemachine_combinational_r scr(state, offset_y, offset_x, colour,
                                       load_offset_y, load_offset_x, 
                                       load_crit_a, load_crit_b,
                                        vga_x, vga_y, vga_colour, vga_plot, done,
                                        c_x1, c_y1,
                                        c_x2, c_y2,
                                        c_x3, c_y3,
                                        reset_crit,
                                        reset_offset_x,
                                        reset_offset_y, c_y3_temp, c_x2_temp);

endmodule

module register_r_offset_y(input logic clk, input logic start,             // register module
            output logic [7:0] offset_y, input logic load_offset_y, input logic reset_offset_y);

            always_ff @(posedge clk) begin
            if (start == 1'b0 || reset_offset_y == 1'b1)
                offset_y <= 8'b00000000;
            else if (load_offset_y == 1'b1)
                offset_y <= offset_y + 8'b00000001;
            else
                offset_y <= offset_y;
        end
endmodule

module register_r_offset_x(input logic clk, input logic start,             // register module
            output logic [7:0] offset_x, input logic load_offset_x, input logic [7:0] diameter,
            input logic reset_offset_x);

            always_ff @(posedge clk) begin
            if (start == 1'b0 || reset_offset_x == 1'b1)
                offset_x <= diameter;
            else if (load_offset_x == 1'b1)
                offset_x <= offset_x - 8'b00000001;
            else
                offset_x <= offset_x;
        end
endmodule

module register_r_crit(input logic clk, 
                                input logic start, 
                                output logic [9:0] crit, 
                                input logic load_crit_a, 
                                input logic load_crit_b, 
                                input logic [7:0] offset_y, 
                                input logic [7:0] offset_x,
                                input logic [7:0] diameter,
                                input logic reset_crit);

          always_ff @(posedge clk) begin
            if (start == 1'b0 || reset_crit == 1'b1)
                crit <= (8'b00000001 - diameter);
            else if (load_crit_a == 1'b1)
                crit <= (crit + 8'b00000010 * offset_y + 1);
            else if (load_crit_b == 1'b1)
                crit <= (crit + 8'b00000010 * (offset_y - offset_x) + 8'b00000001);
            else
                crit <= crit;
        end        
endmodule

module statemachine_mooremachine_r(input logic clk, input logic start, 
                                   input logic [7:0] offset_y, input logic [7:0] offset_x, 
                                   input logic [9:0] crit, 
                                   output logic [5:0] state);
    
    logic [5:0] present_state;

    always @(posedge clk) begin

        if (start == 1'b0) begin // goes through FSM when start is 1
            present_state = `INITIAL_R;
        end else begin
            case(present_state)

             `INITIAL_R: present_state = `CHECK_OFFSET;

             `CHECK_OFFSET: if (offset_y <= offset_x)
                            present_state = `OCTANT_1;
                            else
                            present_state = `RESET_1;

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
/*======================================================================*/
             
             `RESET_1: present_state = `CHECK_OFFSET_1;

             `CHECK_OFFSET_1: if (offset_y <= offset_x)
                            present_state = `OCTANT_1_1;
                            else
                            present_state = `RESET_2;

             `OCTANT_1_1: present_state = `OCTANT_2_1;

             `OCTANT_2_1: present_state = `OCTANT_4_1;

             `OCTANT_4_1: present_state = `OCTANT_3_1;

             `OCTANT_3_1: present_state = `OCTANT_5_1;

             `OCTANT_5_1: present_state = `OCTANT_6_1;

             `OCTANT_6_1: present_state = `OCTANT_8_1;

             `OCTANT_8_1: present_state = `OCTANT_7_1;

             `OCTANT_7_1: present_state = `INC_OFFSET_Y_1;

             `INC_OFFSET_Y_1: present_state = `CHECK_CRIT_1;

             `CHECK_CRIT_1: if (crit[9] == 1'b1)
                            present_state = `UPDATE_A_1;
                            else
                            present_state = `UPDATE_B_1_1;

             `UPDATE_A_1: present_state = `CHECK_OFFSET_1;

             `UPDATE_B_1_1: present_state = `UPDATE_B_2_1;

             `UPDATE_B_2_1: present_state = `CHECK_OFFSET_1;
/*======================================================================*/
             
             `RESET_2: present_state = `CHECK_OFFSET_2;

             `CHECK_OFFSET_2: if (offset_y <= offset_x)
                            present_state = `OCTANT_1_2;
                            else
                            present_state = `DONE_R;

             `OCTANT_1_2: present_state = `OCTANT_2_2;

             `OCTANT_2_2: present_state = `OCTANT_4_2;

             `OCTANT_4_2: present_state = `OCTANT_3_2;

             `OCTANT_3_2: present_state = `OCTANT_5_2;

             `OCTANT_5_2: present_state = `OCTANT_6_2;

             `OCTANT_6_2: present_state = `OCTANT_8_2;

             `OCTANT_8_2: present_state = `OCTANT_7_2;

             `OCTANT_7_2: present_state = `INC_OFFSET_Y_2;

             `INC_OFFSET_Y_2: present_state = `CHECK_CRIT_2;

             `CHECK_CRIT_2: if (crit[9] == 1'b1)
                            present_state = `UPDATE_A_2;
                            else
                            present_state = `UPDATE_B_1_2;

             `UPDATE_A_2: present_state = `CHECK_OFFSET_2;

             `UPDATE_B_1_2: present_state = `UPDATE_B_2_2;

             `UPDATE_B_2_2: present_state = `CHECK_OFFSET_2;

             `DONE_R: present_state = `DONE_R;

            default: present_state = 4'bxxxx;
                            
    
            endcase
        end

        state = present_state;
    
    end

endmodule

module statemachine_combinational_r(input logic [5:0] state, 
                                    input logic [7:0] offset_y, 
                                    input logic [7:0] offset_x,
                                    input logic [2:0] colour,
                                    output logic load_offset_y, 
                                    output logic load_offset_x, 
                                    output logic load_crit_a,
                                    output logic load_crit_b,
                                    output logic [7:0] vga_x, 
                                    output logic [6:0] vga_y, 
                                    output logic [2:0] vga_colour, 
                                    output logic vga_plot, 
                                    output logic done,
                                    input logic [7:0] c_x1, input logic [6:0] c_y1,
                                    input logic [7:0] c_x2, input logic [6:0] c_y2,
                                    input logic [7:0] c_x3, input logic [6:0] c_y3,
                                    output logic reset_crit,
                                    output logic reset_offset_x,
                                    output logic reset_offset_y,
                                    input logic [50:0] c_y3_temp,
                                    input logic [50:0] c_x2_temp);

     always @(state or offset_y or offset_x or c_x1 or c_y1 or 
                                               c_x2 or c_y2 or 
                                               c_x3 or c_y3 or colour or c_y3_temp or c_x2_temp) begin
    
        case(state)
        
        `INITIAL_R: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0;

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

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

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                if (c_y3_temp[50] == 1'b1) begin
                    vga_x <=            c_x3 + offset_x;
                    vga_y <=            c_y3 + offset_y - (2 * c_y3);

                    if ((c_x3 + offset_x) > 159 || (c_y3 + offset_y - (2 * c_y3)) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 + offset_y - (2 * c_y3)) <= c_y1 ) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end else begin
                    vga_x <=            c_x3 + offset_x;
                    vga_y <=            c_y3 + offset_y;

                    if ((c_x3 + offset_x) > 159 || (c_y3 + offset_y) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 + offset_y) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;
          
                done <= 1'b0;
            end

            `OCTANT_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                if (c_y3_temp[50] == 1'b1) begin
                    vga_x <=            c_x3 + offset_y;
                    vga_y <=            c_y3 + offset_x[6:0] - (2 * c_y3);

                    if ((c_x3 + offset_y) > 159 || (c_y3 + offset_x - (2 * c_y3)) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 + offset_x - (2 * c_y3)) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end else begin
                    vga_x <=            c_x3 + offset_y;
                    vga_y <=            c_y3 + offset_x[6:0];

                    if ((c_x3 + offset_y) > 159 || (c_y3 + offset_x) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 + offset_x) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_4: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;


                if (c_y3_temp[50] == 1'b1) begin
                    vga_x <=            c_x3 - offset_x;
                    vga_y <=            c_y3 + offset_y - (2 * c_y3);

                    if ((c_x3 - offset_x) > 159 || (c_y3 + offset_y - (2 * c_y3)) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 + offset_y - (2 * c_y3)) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end 

                    end else begin
                    vga_x <=            c_x3 - offset_x;
                    vga_y <=            c_y3 + offset_y;

                    if ((c_x3 - offset_x) > 159 || (c_y3 + offset_y) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 + offset_y) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end 

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_3: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;


                if (c_y3_temp[50] == 1'b1) begin
                    vga_x <=            c_x3 - offset_y;
                    vga_y <=            c_y3 + offset_x[6:0] - (2 * c_y3);

                    if ((c_x3 - offset_y) > 159 || (c_y3 + offset_x - (2 * c_y3)) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 + offset_x - (2 * c_y3)) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                end 

                end else begin
                    vga_x <=            c_x3 - offset_y;
                    vga_y <=            c_y3 + offset_x[6:0];

                    if ((c_x3 - offset_y) > 159 || (c_y3 + offset_x) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 + offset_x) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                end 

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_5: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0; 

                if (c_y3_temp[50] == 1'b1) begin
                    vga_x <=            c_x3 - offset_x;
                    vga_y <=            c_y3 - offset_y - (2 * c_y3);
    
                    if ((c_x3 - offset_x) > 159 || (c_y3 - offset_y - (2 * c_y3)) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 - offset_y - (2 * c_y3)) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end

                end else begin
                    vga_x <=            c_x3 - offset_x;
                    vga_y <=            c_y3 - offset_y;

                    if ((c_x3 - offset_x) > 159 || (c_y3 - offset_y) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 - offset_y) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_6: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;


                if (c_y3_temp[50] == 1'b1) begin
                    vga_x <=            c_x3 - offset_y;
                    vga_y <=            c_y3 - offset_x[6:0] - (2 * c_y3);
    
                    if ((c_x3 - offset_y) > 159 || (c_y3 - offset_x - (2 * c_y3)) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 - offset_x - (2 * c_y3)) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                end

                end else begin
                    vga_x <=            c_x3 - offset_y;
                    vga_y <=            c_y3 - offset_x[6:0];

                    if ((c_x3 - offset_y) > 159 || (c_y3 - offset_x) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 - offset_x) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                end

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_8: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                if (c_y3_temp[50] == 1'b1) begin
                    vga_x <=            c_x3 + offset_x;
                    vga_y <=            c_y3 - offset_y - (2 * c_y3);
    
                    if ((c_x3 + offset_x) > 159 || (c_y3 - offset_y - (2 * c_y3)) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 - offset_y - (2 * c_y3)) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end else begin
                    vga_x <=            c_x3 + offset_x;
                    vga_y <=            c_y3 - offset_y;

                    if ((c_x3 + offset_x) > 159 || (c_y3 - offset_y) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 - offset_y) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_7: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                if (c_y3_temp[50] == 1'b1) begin
                    vga_x <=            c_x3 + offset_y;
                    vga_y <=            c_y3 - offset_x[6:0] - (2 * c_y3);
    
                    if ((c_x3 + offset_y) > 159 || (c_y3 - offset_x - (2 * c_y3)) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 - offset_x - (2 * c_y3)) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end  

                end else begin
                    vga_x <=            c_x3 + offset_y;
                    vga_y <=            c_y3 - offset_x[6:0];

                    if ((c_x3 + offset_y) > 159 || (c_y3 - offset_x) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y3 - offset_x) <= c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end 

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

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

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

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

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

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

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

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

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

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

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

/*======================================================================*/
            
            `RESET_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b1;
                reset_offset_x <=   1'b1;
                reset_offset_y <=   1'b1;

                done <= 1'b0;
            end

            `CHECK_OFFSET_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_1_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;
    
                vga_x <=            c_x1 + offset_x;
                vga_y <=            c_y1 + offset_y;

                if ((c_x1 + offset_x) > 159 || (c_y1 + offset_y) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_x1 + offset_x) > c_x3) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_y1 + offset_y) > c_y1) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;
          
                done <= 1'b0;
            end

            `OCTANT_2_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            c_x1 + offset_y;
                vga_y <=            c_y1 + offset_x;

                if ((c_x1 + offset_y) > 159 || (c_y1 + offset_x) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_x1 + offset_y) > c_x3) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_y1 + offset_x) > c_y1) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_4_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            c_x1 - offset_x;
                vga_y <=            c_y1 + offset_y;

                if ((c_x1 - offset_x) > 159 || (c_y1 + offset_y) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_x1 - offset_x) > c_x3) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_y1 + offset_y) > c_y1) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_3_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            c_x1 - offset_y;
                vga_y <=            c_y1 + offset_x;

                if ((c_x1 - offset_y) > 159 || (c_y1 + offset_x) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_x1 - offset_y) > c_x3) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_y1 + offset_x) > c_y1) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_5_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            c_x1 - offset_x;
                vga_y <=            c_y1 - offset_y;

                if ((c_x1 - offset_x) > 159 || (c_y1 - offset_y) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_x1 - offset_x) > c_x3) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_y1 - offset_y) > c_y1) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_6_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            c_x1 - offset_y;
                vga_y <=            c_y1 - offset_x;

                if ((c_x1 - offset_y) > 159 || (c_y1 - offset_x) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_x1 - offset_y) > c_x3) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_y1 - offset_x) > c_y1) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_8_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            c_x1 + offset_x;
                vga_y <=            c_y1 - offset_y;

                if ((c_x1 + offset_x) > 159 || (c_y1 - offset_y) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_x1 + offset_x) > c_x3) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_y1 - offset_y) > c_y1) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_7_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;
                
                vga_x <=            c_x1 + offset_y;
                vga_y <=            c_y1 - offset_x;

                if ((c_x1 + offset_y) > 159 || (c_y1 - offset_x) > 119) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_x1 + offset_y) > c_x3) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end else if ((c_y1 - offset_x) > c_y1) begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b0; 
                end
                else begin
                    vga_colour <=       colour;
                    vga_plot <=         1'b1; 
                end 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `INC_OFFSET_Y_1: begin
                load_offset_y <=    1'b1;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `CHECK_CRIT_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `UPDATE_A_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b1;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `UPDATE_B_1_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b1;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `UPDATE_B_2_1: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b1;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

/*======================================================================*/

            `RESET_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b1;
                reset_offset_x <=   1'b1;
                reset_offset_y <=   1'b1;

                done <= 1'b0;
            end

            `CHECK_OFFSET_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_1_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                if (c_x2_temp[50] == 1'b1) begin

                    vga_x <=            c_x2 + offset_x - (2 * c_x2);
                    vga_y <=            c_y2 + offset_y;

                    if ((c_x2 + offset_x - (2 * c_x2)) > 159 || (c_y2 + offset_y) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 + offset_x - (2 * c_x2)) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 + offset_y) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end else begin

                    vga_x <=            c_x2 + offset_x;
                    vga_y <=            c_y2 + offset_y;

                    if ((c_x2 + offset_x) > 159 || (c_y2 + offset_y) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 + offset_x) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 + offset_y) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;
          
                done <= 1'b0;
            end

            `OCTANT_2_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                if (c_x2_temp[50] == 1'b1) begin

                    vga_x <=            c_x2 + offset_y - (2 * c_x2);
                    vga_y <=            c_y2 + offset_x;
    
                    if ((c_x2 + offset_y - (2 * c_x2)) > 159 || (c_y2 + offset_x) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 + offset_y - (2 * c_x2)) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 + offset_x) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end else begin

                    vga_x <=            c_x2 + offset_y;
                    vga_y <=            c_y2 + offset_x;

                    if ((c_x2 + offset_y) > 159 || (c_y2 + offset_x) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 + offset_y) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 + offset_x) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_4_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                if (c_x2_temp[50] == 1'b1) begin

                    vga_x <=            c_x2 - offset_x - (2 * c_x2);
                    vga_y <=            c_y2 + offset_y;
    
                    if ((c_x2 - offset_x - (2 * c_x2)) > 159 || (c_y2 + offset_y) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 - offset_x - (2 * c_x2)) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 + offset_y) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end 

                end else begin

                    vga_x <=            c_x2 - offset_x;
                    vga_y <=            c_y2 + offset_y;

                    if ((c_x2 - offset_x) > 159 || (c_y2 + offset_y) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 - offset_x) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 + offset_y) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end 

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_3_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                if (c_x2_temp[50] == 1'b1) begin

                    vga_x <=            c_x2 - offset_y - (2 * c_x2);
                    vga_y <=            c_y2 + offset_x;

                    if ((c_x2 - offset_y - (2 * c_x2)) > 159 || (c_y2 + offset_x) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 - offset_y - (2 * c_x2)) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 + offset_x) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end else begin

                    vga_x <=            c_x2 - offset_y;
                    vga_y <=            c_y2 + offset_x;

                    if ((c_x2 - offset_y) > 159 || (c_y2 + offset_x) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 - offset_y) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 + offset_x) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end 

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_5_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                if (c_x2_temp[50] == 1'b1) begin

                    vga_x <=            c_x2 - offset_x - (2 * c_x2);
                    vga_y <=            c_y2 - offset_y;

                    if ((c_x2 - offset_x - (2 * c_x2)) > 159 || (c_y2 - offset_y) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 - offset_x - (2 * c_x2)) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 - offset_y) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end 

                end else begin

                    vga_x <=            c_x2 - offset_x;
                    vga_y <=            c_y2 - offset_y;

                    if ((c_x2 - offset_x) > 159 || (c_y2 - offset_y) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 - offset_x) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 - offset_y) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end 

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_6_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                if (c_x2_temp[50] == 1'b1) begin

                    vga_x <=            c_x2 - offset_y - (2 * c_x2);
                    vga_y <=            c_y2 - offset_x;
    
                    if ((c_x2 - offset_y - (2 * c_x2)) > 159 || (c_y2 - offset_x) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 - offset_y - (2 * c_x2)) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 - offset_x) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end else begin

                    vga_x <=            c_x2 - offset_y;
                    vga_y <=            c_y2 - offset_x;

                    if ((c_x2 - offset_y) > 159 || (c_y2 - offset_x) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 - offset_y) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 - offset_x) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_8_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                if (c_x2_temp[50] == 1'b1) begin

                    vga_x <=            c_x2 + offset_x - (2 * c_x2);
                    vga_y <=            c_y2 - offset_y;
    
                    if ((c_x2 + offset_x - (2 * c_x2)) > 159 || (c_y2 - offset_y) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 + offset_x - (2 * c_x2)) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 - offset_y) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end else begin

                    vga_x <=            c_x2 + offset_x;
                    vga_y <=            c_y2 - offset_y;

                    if ((c_x2 + offset_x) > 159 || (c_y2 - offset_y) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 + offset_x) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 - offset_y) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `OCTANT_7_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                if (c_x2_temp[50] == 1'b1) begin

                    vga_x <=            c_x2 + offset_y - (2 * c_x2);
                    vga_y <=            c_y2 - offset_x;
    
                    if ((c_x2 + offset_y - (2 * c_x2)) > 159 || (c_y2 - offset_x) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 + offset_y - (2 * c_x2)) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 - offset_x) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end 

                end else begin

                    vga_x <=            c_x2 + offset_y;
                    vga_y <=            c_y2 - offset_x;

                    if ((c_x2 + offset_y) > 159 || (c_y2 - offset_x) > 119) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_x2 + offset_y) < c_x3) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end else if ((c_y2 - offset_x) > c_y1) begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b0; 
                    end
                    else begin
                        vga_colour <=       colour;
                        vga_plot <=         1'b1; 
                    end 

                end

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `INC_OFFSET_Y_2: begin
                load_offset_y <=    1'b1;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `CHECK_CRIT_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `UPDATE_A_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b1;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `UPDATE_B_1_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b1;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `UPDATE_B_2_2: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b1;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

                done <= 1'b0;
            end

            `DONE_R: begin
                load_offset_y <=    1'b0;
                load_offset_x <=    1'b0;
                load_crit_a <=      1'b0;
                load_crit_b <=      1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                reset_crit <=       1'b0;
                reset_offset_x <=   1'b0;
                reset_offset_y <=   1'b0;

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

                reset_crit <=       1'bx;
                reset_offset_x <=   1'bx;
                reset_offset_y <=   1'bx;

                done <= 1'bx;
            end

        endcase
    end

endmodule

