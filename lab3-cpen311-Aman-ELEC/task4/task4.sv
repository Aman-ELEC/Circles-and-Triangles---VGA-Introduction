`define WAIT                   3'b000 
`define START_FS_ON            3'b001 
`define START_FS_OFF           3'b010 
`define START_R_ON             3'b011 
`define START_R_OFF            3'b100 

module task4(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    // instantiate and connect the VGA adapter and your module
    
    logic reset;
    assign reset = KEY[3];

    logic [2:0] colour;
    assign colour = 3'b010; // green colour

    logic start_fs;
    logic done_fs;

    logic start_r;
    logic done_r;
    logic [7:0] centre_x;
    assign centre_x = 8'b01010000;  // 80
    // assign centre_x = 8'b00001010;  // 10
    // assign centre_x = 8'd140;  // 10


    logic [6:0] centre_y;
    assign centre_y = 7'b0111100;   // 60
    // assign centre_y = 7'd10;   
    // assign centre_y = 7'd100;   


    logic [7:0] diameter;
    assign diameter = 8'b01010000;  // 80
    // assign diameter = 8'b00101000;  // 40
    // assign diameter = 8'b01111000;  // 120

    logic [7:0] vga_x_fs;
    logic [6:0] vga_y_fs;
    logic [2:0] vga_colour_fs;
    logic vga_plot_fs;

    logic [7:0] vga_x_r;
    logic [6:0] vga_y_r;
    logic [2:0] vga_colour_r;
    logic vga_plot_r;

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
        
        reuleaux r(.clk(CLOCK_50), .rst_n(~reset), .colour(colour),
              .centre_x(centre_x), .centre_y(centre_y), .diameter(diameter),
              .start(start_r), .done(done_r),
              .vga_x(vga_x_r), .vga_y(vga_y_r),
              .vga_colour(vga_colour_r), .vga_plot(vga_plot_r));

    logic [2:0] state;

    statemachine_mooremachine_task3 mt3(CLOCK_50, reset, state, done_fs, done_r);

    statemachine_combinational_task3 ct3(state, start_fs, start_r,
                                         vga_x_fs, vga_y_fs, vga_colour_fs, vga_plot_fs,
                                         vga_x_r, vga_y_r, vga_colour_r, vga_plot_r,
                                         VGA_X, VGA_Y, VGA_COLOUR, VGA_PLOT);

endmodule: task4

module statemachine_mooremachine_task3(input logic CLOCK_50, input logic reset,
                                        output logic [2:0] state, 
                                        input logic done_fs,
                                        input logic done_r);

    logic [2:0] present_state;

    always @(posedge CLOCK_50) begin

        if (reset) begin
            present_state = `WAIT;
        end else begin
            case(present_state)

                `WAIT: present_state = `START_FS_ON;

                // `WAIT: present_state = `START_R_ON;


                `START_FS_ON: if (done_fs == 1'b1) 
                            present_state = `START_FS_OFF;
                            else
                            present_state = `START_FS_ON;

                `START_FS_OFF: present_state = `START_R_ON;

                `START_R_ON: if (done_r == 1'b1) 
                            present_state = `START_R_OFF;
                            else
                            present_state = `START_R_ON;

                `START_R_OFF: present_state = `START_R_OFF;

                default: present_state = 3'bxxx;

            endcase
        end

        state = present_state;

    end
endmodule

module statemachine_combinational_task3(input logic [2:0] state, 
                                        output logic start_fs,
                                        output logic start_r,
                                        input logic [7:0] vga_x_fs, 
                                        input logic [6:0] vga_y_fs, 
                                        input logic [2:0] vga_colour_fs, 
                                        input logic vga_plot_fs,
                                        input logic [7:0] vga_x_r, 
                                        input logic [6:0] vga_y_r, 
                                        input logic [2:0] vga_colour_r, 
                                        input logic vga_plot_r,
                                        output logic [7:0] VGA_X, 
                                        output logic [6:0] VGA_Y, 
                                        output logic [2:0] VGA_COLOUR, 
                                        output logic VGA_PLOT);

    always @(state or vga_x_fs or vga_y_fs or vga_colour_fs or vga_plot_fs or vga_x_r or vga_y_r or vga_colour_r or vga_plot_r) begin

            case(state)

            `WAIT: begin
                start_fs <= 1'b0;
                start_r  <= 1'b0;

                VGA_X      <= vga_x_fs;
                VGA_Y      <= vga_y_fs;
                VGA_COLOUR <= vga_colour_fs;
                VGA_PLOT   <= vga_plot_fs;
            end

            `START_FS_ON: begin
                start_fs <= 1'b1;
                start_r  <= 1'b0;

                VGA_X      <= vga_x_fs;
                VGA_Y      <= vga_y_fs;
                VGA_COLOUR <= vga_colour_fs;
                VGA_PLOT   <= vga_plot_fs;
            end

            `START_FS_OFF: begin
                start_fs <= 1'b0;
                start_r  <= 1'b0;

                VGA_X      <= vga_x_r;
                VGA_Y      <= vga_y_r;
                VGA_COLOUR <= vga_colour_r;
                VGA_PLOT   <= vga_plot_r;
            end

            `START_R_ON: begin
                start_fs <= 1'b0;
                start_r  <= 1'b1;

                VGA_X      <= vga_x_r;
                VGA_Y      <= vga_y_r;
                VGA_COLOUR <= vga_colour_r;
                VGA_PLOT   <= vga_plot_r;
            end

            `START_R_OFF: begin
                start_fs <= 1'b0;
                start_r  <= 1'b0;

                VGA_X      <= vga_x_r;
                VGA_Y      <= vga_y_r;
                VGA_COLOUR <= vga_colour_r;
                VGA_PLOT   <= vga_plot_r;
            end

            default: begin
                start_fs <= 1'bx;
                start_r  <= 1'bx;

                VGA_X      <= 8'bxxxxxxxx;
                VGA_Y      <= 7'bxxxxxxx;
                VGA_COLOUR <= 3'bxxx;
                VGA_PLOT   <= 1'bx;
            end

            endcase
    end

endmodule
