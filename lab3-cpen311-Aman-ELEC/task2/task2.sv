`define WAIT                2'b00 
`define START_ON            2'b01 
`define START_OFF           2'b10 

module task2(input logic CLOCK_50, input logic [3:0] KEY,
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
    logic start;
    logic done;

    logic [9:0] VGA_R_10;
    logic [9:0] VGA_G_10;
    logic [9:0] VGA_B_10;
    logic VGA_BLANK, VGA_SYNC;

    assign VGA_R = VGA_R_10[9:2];
    assign VGA_G = VGA_G_10[9:2];
    assign VGA_B = VGA_B_10[9:2];

    // instantiate and connect the VGA adapter and your module

        fillscreen fs(.clk(CLOCK_50), .rst_n(~reset), .colour(colour),
                  .start(start), .done(done),
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

        // vga_adapter#(.RESOLUTION("160x120")) vd(.resetn(reset), 
        //         .clock(CLOCK_50), 
        //         .colour(VGA_COLOUR),
        //         .x(VGA_X), .y(VGA_Y), .plot(VGA_PLOT),
        //         .VGA_R(VGA_R), 
        //         .VGA_G(VGA_G), 
        //         .VGA_B(VGA_B),
        //         .VGA_HS(VGA_HS), 
        //         .VGA_VS(VGA_VS),
        //         .VGA_BLANK(VGA_BLANK), 
        //         .VGA_SYNC(VGA_SYNC),
        //         .VGA_CLK(VGA_CLK));



    logic [1:0] state;

    statemachine_mooremachine_task2 mt2(CLOCK_50, reset, state, done);

    statemachine_combinational_task2 ct2(state, start);

endmodule: task2

module statemachine_mooremachine_task2(input logic CLOCK_50, input logic reset,
                                        output logic [1:0] state, input logic done);

    logic [1:0] present_state;

    always @(posedge CLOCK_50) begin

        if (reset) begin
            present_state = `WAIT;
        end else begin
            case(present_state)

                `WAIT: present_state = `START_ON;

                `START_ON: if (done == 1'b1) 
                            present_state = `START_OFF;
                            else
                            present_state = `START_ON;

                `START_OFF: present_state = `START_OFF;

                default: present_state = 2'bxx;

            endcase
        end

        state = present_state;

    end
endmodule

module statemachine_combinational_task2(input logic [1:0] state, 
                                        output logic start);

    always @(state) begin

            case(state)

            `WAIT: begin
                start <= 1'b0;
            end

            `START_ON: begin
                start <= 1'b1;
            end

            `START_OFF: begin
                start <= 1'b0;
            end

            default: begin
                start <= 1'bx;
            end

            endcase
    end

endmodule