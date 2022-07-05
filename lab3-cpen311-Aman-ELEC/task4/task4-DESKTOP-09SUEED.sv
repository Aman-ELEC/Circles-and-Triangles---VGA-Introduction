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
    logic [6:0] centre_y;
    assign centre_y = 7'b0111100;   // 60
    logic [7:0] diameter;
    assign diameter = 8'b01010000;  // 80
    // assign diameter = 8'b00101000;  // 40
    // assign diameter = 8'b01111000;  // 120



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
                  .vga_x(VGA_X), .vga_y(VGA_Y),
                  .vga_colour(VGA_COLOUR), .vga_plot(VGA_PLOT));

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
              .vga_x(VGA_X), .vga_y(VGA_Y),
              .vga_colour(VGA_COLOUR), .vga_plot(VGA_PLOT));

    logic [2:0] state;

    statemachine_mooremachine_task3 mt3(CLOCK_50, reset, state, done_fs, done_r);

    statemachine_combinational_task3 ct3(state, start_fs, start_r);

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
                                        output logic start_r);

    always @(state) begin

            case(state)

            `WAIT: begin
                start_fs <= 1'b0;
                start_r  <= 1'b0;
            end

            `START_FS_ON: begin
                start_fs <= 1'b1;
                start_r  <= 1'b0;
            end

            `START_FS_OFF: begin
                start_fs <= 1'b0;
                start_r  <= 1'b0;
            end

            `START_R_ON: begin
                start_fs <= 1'b0;
                start_r  <= 1'b1;
            end

            `START_R_OFF: begin
                start_fs <= 1'b0;
                start_r  <= 1'b0;
            end

            default: begin
                start_fs <= 1'bx;
                start_r  <= 1'bx;
            end

            endcase
    end

endmodule
