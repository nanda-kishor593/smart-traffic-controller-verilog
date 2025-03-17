`timescale 1ns / 1ps
cfmodule traffic_controller(
    input clk,
    input rst,
    input [3:0] Emergency, Jam, Empty,
    output reg [2:0] East_road, North_road, West_road, South_road
);
    reg [2:0] state;
    reg [4:0] count;

    parameter [2:0] EAST_GREEN  = 3'b000;
    parameter [2:0] EAST_YELLOW = 3'b001;
    parameter [2:0] NORTH_GREEN  = 3'b010;
    parameter [2:0] NORTH_YELLOW = 3'b011;
    parameter [2:0] WEST_GREEN  = 3'b100;
    parameter [2:0] WEST_YELLOW = 3'b101;
    parameter [2:0] SOUTH_GREEN  = 3'b110;
    parameter [2:0] SOUTH_YELLOW = 3'b111;
    
    always @(posedge clk or negedge rst) begin 
        if (!rst) begin 
            count <= 5'b00000;
            state <= EAST_GREEN;
        end 
        else if (Emergency != 4'b0000) begin
            // Emergency condition: immediate priority
            case (Emergency)
                4'b1000: state <= EAST_GREEN;
                4'b0100: state <= NORTH_GREEN;
                4'b0010: state <= WEST_GREEN;
                4'b0001: state <= SOUTH_GREEN;
                default: state <= EAST_GREEN;
            endcase
            count <= 5'b00000;
        end
        else if (Jam != 4'b0000) begin
            // Jam condition: extend green light
            case (Jam)
                4'b1000: state <= EAST_GREEN;
                4'b0100: state <= NORTH_GREEN;
                4'b0010: state <= WEST_GREEN;
                4'b0001: state <= SOUTH_GREEN;
                default: state <= state;
            endcase
            count <= count + 2; // Extend time due to jam
        end
        else if (Empty != 4'b0000) begin
            // Empty condition: skip phase faster
            case (Empty)
                4'b1000: state <= EAST_YELLOW;
                4'b0100: state <= NORTH_YELLOW;
                4'b0010: state <= WEST_YELLOW;
                4'b0001: state <= SOUTH_YELLOW;
                default: state <= state;
            endcase
            count <= 5'b00000; // Quickly move to the next phase
        end
        else begin
            // Normal operation
            case (state)
                EAST_GREEN: begin
                    if (count == 5'b10011) begin
                        count <= 5'b00000;
                        state <= EAST_YELLOW;
                    end else begin
                        count <= count + 1;
                    end
                end
                EAST_YELLOW: begin
                    if (count == 5'b00011) begin
                        count <= 5'b00000;
                        state <= NORTH_GREEN;
                    end else begin
                        count <= count + 1;
                    end
                end
                
                NORTH_GREEN: begin
                    if (count == 5'b10011) begin
                        count <= 5'b00000;
                        state <= NORTH_YELLOW;
                    end else begin
                        count <= count + 1;
                    end
                end
                NORTH_YELLOW: begin
                    if (count == 5'b00011) begin
                        count <= 5'b00000;
                        state <= WEST_GREEN;
                    end else begin
                        count <= count + 1;
                    end
                end
                
                WEST_GREEN: begin
                    if (count == 5'b10011) begin
                        count <= 5'b00000;
                        state <= WEST_YELLOW;
                    end else begin
                        count <= count + 1;
                    end
                end
                WEST_YELLOW: begin
                    if (count == 5'b00011) begin
                        count <= 5'b00000;
                        state <= SOUTH_GREEN;
                    end else begin
                        count <= count + 1;
                    end
                end
                
                SOUTH_GREEN: begin
                    if (count == 5'b10011) begin
                        count <= 5'b00000;
                        state <= SOUTH_YELLOW;
                    end else begin
                        count <= count + 1;
                    end
                end
                SOUTH_YELLOW: begin
                    if (count == 5'b00011) begin
                        count <= 5'b00000;
                        state <= EAST_GREEN;
                    end else begin
                        count <= count + 1;
                    end
                end
                default: begin
                    count <= 5'b00000;
                    state <= EAST_GREEN;
                end
            endcase
        end
    end
    
    always @(state) begin
        case (state)
            EAST_GREEN:  {East_road, North_road, West_road, South_road} = {3'b001, 3'b100, 3'b100, 3'b100};
            EAST_YELLOW: {East_road, North_road, West_road, South_road} = {3'b010, 3'b110, 3'b100, 3'b100};
            NORTH_GREEN: {East_road, North_road, West_road, South_road} = {3'b100, 3'b001, 3'b100, 3'b100};
            NORTH_YELLOW: {East_road, North_road, West_road, South_road} = {3'b100, 3'b010, 3'b110, 3'b100};
            WEST_GREEN:  {East_road, North_road, West_road, South_road} = {3'b100, 3'b100, 3'b001, 3'b100};
            WEST_YELLOW: {East_road, North_road, West_road, South_road} = {3'b100, 3'b100, 3'b010, 3'b100};
            SOUTH_GREEN: {East_road, North_road, West_road, South_road} = {3'b100, 3'b100, 3'b100, 3'b001};
            SOUTH_YELLOW: {East_road, North_road, West_road, South_road} = {3'b110, 3'b100, 3'b100, 3'b100};
            default:     {East_road, North_road, West_road, South_road} = {3'b100, 3'b100, 3'b100, 3'b100};
        endcase
    end
endmodule
