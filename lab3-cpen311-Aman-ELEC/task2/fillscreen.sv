`define INITIAL           2'b00 
`define CHECK             2'b01 
`define RESET             2'b10 
`define DONE              2'b11 

module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);
     // fill the screen

     logic [7:0] x;
     logic load_x;

     logic [6:0] y;
     logic load_y;
     logic reset_y;


     register_fs_x rfsx(clk, start, x, load_x);
     register_fs_y rfsy(clk, start, y, load_y, reset_y);

     logic [1:0] state;

     statemachine_mooremachine_fs smfs(clk, start, x, y, state);
     statemachine_combinational_fs scfs(state, x, y, load_x, load_y, reset_y,
                                        vga_x, vga_y, vga_colour, vga_plot, done);

endmodule

module register_fs_x(input logic clk, input logic start,             // register module
            output logic [7:0] x, input logic load_x);

            always_ff @(posedge clk) begin
            if (start == 1'b0)
                x <= 8'b00000000;
            else if (load_x == 1'b1)
                x <= x + 8'b00000001;
            else
                x <= x;
        end
endmodule

module register_fs_y(input logic clk, input logic start,             // register module
            output logic [6:0] y, input logic load_y, input logic reset_y);

            always_ff @(posedge clk) begin
            if (start == 1'b0 || reset_y == 1'b1)
                y <= 7'b0000000;
            else if (load_y == 1'b1)
                y <= y + 7'b0000001;
            else
                y <= y;
        end
endmodule

module statemachine_mooremachine_fs(input logic clk, input logic start,
                                    input logic [7:0] x, input logic [6:0] y, 
                                    output logic [1:0] state);
    
    logic [1:0] present_state;

    always @(posedge clk) begin

        if (start == 1'b0) begin // goes through FSM when start is 1
            present_state = `INITIAL;
        end else begin
            case(present_state)

             `INITIAL: present_state = `CHECK;

             `CHECK: if (x <= 8'b10011111) begin
               if (y < 7'b1110111) begin
                    present_state = `CHECK;
               end else begin 
                    present_state = `RESET;
               end
             end else begin
               present_state = `DONE;
             end

             `RESET: present_state = `CHECK;

             `DONE: present_state = `DONE;

            default: present_state = 2'bxx;
                            
    
            endcase
        end

        state = present_state;
    
    end

endmodule

module statemachine_combinational_fs(input logic [1:0] state, 
                                     input logic [7:0] x,
                                     input logic [6:0] y,
                                     output logic load_x, 
                                     output logic load_y, 
                                     output logic reset_y,
                                     output logic [7:0] vga_x, 
                                     output logic [6:0] vga_y, 
                                     output logic [2:0] vga_colour, 
                                     output logic vga_plot, 
                                     output logic done);
     
     always @(state or x or y) begin
    
        case(state)
        
        `INITIAL: begin
                load_x <=           1'b0;
                load_y <=           1'b0;
                reset_y <=          1'b0;

                vga_x <=            x;
                vga_y <=            y;
                vga_colour <=       (x % 8);
                vga_plot <=         1'b0; 

                done <= 1'b0;
            end

            `CHECK: begin
                load_x <=           1'b0;
                load_y <=           1'b1;
                reset_y <=          1'b0;

                vga_x <=            x;
                vga_y <=            y;
                vga_colour <=       (x % 8);
                vga_plot <=         1'b1; 

                done <= 1'b0;
            end

            `RESET: begin
                load_x <=           1'b1;
                load_y <=           1'b0;
                reset_y <=          1'b1;

                vga_x <=            x;
                vga_y <=            y;
                vga_colour <=       (x % 8);
                vga_plot <=         1'b1; 

                done <= 1'b0;
            end

            `DONE: begin
                load_x <=           1'b0;
                load_y <=           1'b0;
                reset_y <=          1'b0;

                vga_x <=            8'b00000000;
                vga_y <=            7'b0000000;
                vga_colour <=       3'b000;
                vga_plot <=         1'b0; 

                done <= 1'b1;
            end

            default: begin
                load_x =           1'bx;
                load_y =           1'bx;
                reset_y =          1'bx;

                vga_x =            8'bxxxxxxxx;
                vga_y =            7'bxxxxxxx;
                vga_colour =       3'bxxx;
                vga_plot =         1'bx;

                done = 1'bx;
            end

        endcase
    end
     
endmodule

