/*
 * nX-u8 debugger / programmer core
 * ~ nlscc, Jan '21
 */

module u8dbg(
    input clk,                          // input clock (at 2x debug speed)
    input [15:0] write_data,            // data written to target
    output reg [15:0] read_data,        // data read from target
    input start, output reg trigger,    // start to begin transaction, trigger is set once complete
    input [6:0] dbgreg,                 // 7-bit debug register
    input direction,                    // 1 for read, 0 for write
    output reg dbg_clk, inout dbg_sdata // output pins to target MCU
);

// tri-state driver for sdata
reg dbg_we = 1'b0; // enable write to sdata
reg dbg_sw = 1'b0;
assign dbg_sdata = dbg_we ? dbg_sw : 1'bz;

localparam STATE_IDLE = 3'b000;     // waiting for tranaction
localparam STATE_COMMAND = 3'b001;  // write command octet (register + direction)
localparam STATE_READ = 3'b010;     // read 16 bits from the target
localparam STATE_WRITE = 3'b011;    // write 16 bits to the target
localparam STATE_END = 3'b100;      // end of transaction
reg [2:0] state = STATE_IDLE;

wire [7:0] command = {dbgreg, direction}; // the first octet sent to the target
reg [7:0] cycle_counter = 0;

always @(posedge clk) begin
    case (state)
        STATE_IDLE: begin
            dbg_we <= 0; // don't drive the output pin
            dbg_clk <= 1;
            trigger <= 0;
            if (start)
                state <= STATE_COMMAND; // begin transfer
        end
        STATE_COMMAND: begin
            if (cycle_counter < 16) begin
                dbg_we <= 1;
                if (cycle_counter & 1)
                    dbg_clk <= 1;
                else begin // write on falling edge
                    dbg_clk <= 0;
                    dbg_sw <= command[7 - (cycle_counter >> 1)];
                end
                cycle_counter <= cycle_counter + 1;
            end else begin
                cycle_counter <= 0;
                if (direction) begin
                    dbg_we <= 0;
                    state <= STATE_READ;
                end else begin
                    dbg_we <= 1;
                    state <= STATE_WRITE;
                end
            end
        end
        STATE_READ: begin
            if (cycle_counter < 32) begin
                if (cycle_counter & 1) begin // read on rising edge
                    dbg_clk <= 1;
                    read_data[15 - (cycle_counter >> 1)] <= dbg_sdata;
                end else
                    dbg_clk <= 0;
                cycle_counter <= cycle_counter + 1;
            end else begin
                cycle_counter <= 0;
                state <= STATE_END;
            end
        end
        STATE_WRITE: begin
            if (cycle_counter < 32) begin
                if (cycle_counter & 1)
                    dbg_clk <= 1;
                else begin // write on falling edge
                    dbg_clk <= 0;
                    dbg_sw <= write_data[15 - (cycle_counter >> 1)];
                end
                cycle_counter <= cycle_counter + 1;
            end else begin
                dbg_we <= 0;
                cycle_counter <= 0;
                state <= STATE_END;
            end
        end
        STATE_END: begin
            trigger <= 1;
            state <= STATE_IDLE;
        end
        default: state <= STATE_IDLE;
    endcase
end

endmodule
