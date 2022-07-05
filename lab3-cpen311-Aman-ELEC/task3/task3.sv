`define WAIT                   3'b000 
`define START_FS_ON            3'b001 
`define START_FS_OFF           3'b010 
`define START_C_ON             3'b011 
`define START_C_OFF            3'b100 

module task3(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);
        
    logic reset;
    assign reset = KEY[3];

    logic [2:0] colour;
    assign colour = 3'b010; // green colour

    logic start_fs;
    logic done_fs;

    logic start_c;
    logic done_c;
    logic [7:0] centre_x;
    assign centre_x = 8'b01010000; // 80
    // assign centre_x = 8'b01100100; // 100
    // assign centre_x = 8'b00000000; // 0

    logic [6:0] centre_y;
    assign centre_y = 7'b0111100; // 60
    // assign centre_y = 7'b1010000; // 80
    // assign centre_y = 7'b0000000; // 0

    logic [7:0] radius;
    assign radius = 8'b00101000; // 40
    // assign radius = 8'b00111000; // 56
    // assign radius = 8'b00111111; // 63

    logic [7:0] vga_x_fs;
    logic [6:0] vga_y_fs;
    logic [2:0] vga_colour_fs;
    logic vga_plot_fs;

    logic [7:0] vga_x_c;
    logic [6:0] vga_y_c;
    logic [2:0] vga_colour_c;
    logic vga_plot_c;

    logic [9:0] VGA_R_10;
    logic [9:0] VGA_G_10;
    logic [9:0] VGA_B_10;
    logic VGA_BLANK, VGA_SYNC;

    assign VGA_R = VGA_R_10[9:2];
    assign VGA_G = VGA_G_10[9:2];
    assign VGA_B = VGA_B_10[9:2];

    // instantiate and connect the VGA adapter and your module

        fillscreen fs(.clk(CLOCK_50), .rst_n(~reset), .colour(colour),
                  .start(start_fs), .done(done_fs),
                  .vga_x(vga_x_fs), .vga_y(vga_y_fs),
                  .vga_colour(vga_colour_fs), .vga_plot(vga_plot_fs));

        vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(~reset), 
                                            .clock(CLOCK_50), 
                                            .colour(VGA_COLOUR),
                                            .x(VGA_X), 
                                            .y(VGA_Y), 
                                            .plot(VGA_PLOT),
                                            .VGA_R(VGA_R_10), 
                                            .VGA_G(VGA_G_10),
                                            .VGA_B(VGA_B_10), 
                                            .VGA_HS(VGA_HS), 
                                            .VGA_VS(VGA_VS), 
                                            .VGA_BLANK(VGA_BLANK),
                                            .VGA_SYNC(VGA_SYNC), 
                                            .VGA_CLK(VGA_CLK));
        
        circle c(.clk(CLOCK_50), .rst_n(~reset), .colour(colour),
              .centre_x(centre_x), .centre_y(centre_y), .radius(radius),
              .start(start_c), .done(done_c),
              .vga_x(vga_x_c), .vga_y(vga_y_c),
              .vga_colour(vga_colour_c), .vga_plot(vga_plot_c));

    logic [2:0] state;

    statemachine_mooremachine_task3 mt3(CLOCK_50, reset, state, done_fs, done_c);

    statemachine_combinational_task3 ct3(state, start_fs, start_c,
                                         vga_x_fs, vga_y_fs, vga_colour_fs, vga_plot_fs,
                                         vga_x_c, vga_y_c, vga_colour_c, vga_plot_c,
                                         VGA_X, VGA_Y, VGA_COLOUR, VGA_PLOT);

endmodule: task3

module statemachine_mooremachine_task3(input logic CLOCK_50, input logic reset,
                                        output logic [2:0] state, 
                                        input logic done_fs,
                                        input logic done_c);

    logic [2:0] present_state;

    always @(posedge CLOCK_50) begin

        if (reset) begin
            present_state = `WAIT;
        end else begin
            case(present_state)

                `WAIT: present_state = `START_FS_ON;

                `START_FS_ON: if (done_fs == 1'b1) 
                            present_state = `START_FS_OFF;
                            else
                            present_state = `START_FS_ON;

                `START_FS_OFF: present_state = `START_C_ON;

                `START_C_ON: if (done_c == 1'b1) 
                            present_state = `START_C_OFF;
                            else
                            present_state = `START_C_ON;

                `START_C_OFF: present_state = `START_C_OFF;

                default: present_state = 3'bxxx;

            endcase
        end

        state = present_state;

    end
endmodule

module statemachine_combinational_task3(input logic [2:0] state, 
                                        output logic start_fs,
                                        output logic start_c,
                                        input logic [7:0] vga_x_fs, 
                                        input logic [6:0] vga_y_fs, 
                                        input logic [2:0] vga_colour_fs, 
                                        input logic vga_plot_fs,
                                        input logic [7:0] vga_x_c, 
                                        input logic [6:0] vga_y_c, 
                                        input logic [2:0] vga_colour_c, 
                                        input logic vga_plot_c,
                                        output logic [7:0] VGA_X, 
                                        output logic [6:0] VGA_Y, 
                                        output logic [2:0] VGA_COLOUR, 
                                        output logic VGA_PLOT);

    always @(state or vga_x_fs or vga_y_fs or vga_colour_fs or vga_plot_fs or vga_x_c or vga_y_c or vga_colour_c or vga_plot_c) begin

            case(state)

            `WAIT: begin
                start_fs <= 1'b0;
                start_c  <= 1'b0;

                VGA_X      <= vga_x_fs;
                VGA_Y      <= vga_y_fs;
                VGA_COLOUR <= vga_colour_fs;
                VGA_PLOT   <= vga_plot_fs;
            end

            `START_FS_ON: begin
                start_fs <= 1'b1;
                start_c  <= 1'b0;

                VGA_X      <= vga_x_fs;
                VGA_Y      <= vga_y_fs;
                VGA_COLOUR <= vga_colour_fs;
                VGA_PLOT   <= vga_plot_fs;
            end

            `START_FS_OFF: begin
                start_fs <= 1'b0;
                start_c  <= 1'b0;
                
                VGA_X      <= vga_x_c;
                VGA_Y      <= vga_y_c;
                VGA_COLOUR <= vga_colour_c;
                VGA_PLOT   <= vga_plot_c;
            end

            `START_C_ON: begin
                start_fs <= 1'b0;
                start_c  <= 1'b1;

                VGA_X      <= vga_x_c;
                VGA_Y      <= vga_y_c;
                VGA_COLOUR <= vga_colour_c;
                VGA_PLOT   <= vga_plot_c;
            end

            `START_C_OFF: begin
                start_fs <= 1'b0;
                start_c  <= 1'b0;

                VGA_X      <= vga_x_c;
                VGA_Y      <= vga_y_c;
                VGA_COLOUR <= vga_colour_c;
                VGA_PLOT   <= vga_plot_c;
            end

            default: begin
                start_fs <= 1'bx;
                start_c  <= 1'bx;

                VGA_X      <= 8'bxxxxxxxx;
                VGA_Y      <= 7'bxxxxxxx;
                VGA_COLOUR <= 3'bxxx;
                VGA_PLOT   <= 1'bx;
            end

            endcase
    end

endmodule