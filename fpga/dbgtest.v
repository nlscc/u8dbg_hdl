/*
 * nX-u8 programmer interface
 * ~ nlscc, Feb '21
 */

`include "u8dbg.v"

`include "uart_tx.v"
`include "uart_rx.v"

module dbgtest(
    input clk,
    inout [1:0] JA,
    input RsRx, output RsTx
);

// debug clock prescaler
parameter debug_clk_div = 24;
reg debug_clk = 1'b0;
reg [15:0] debug_clk_ctr = 0;
always @(posedge clk) begin
    if (debug_clk_ctr < debug_clk_div / 2 - 1)
        debug_clk_ctr <= debug_clk_ctr + 1;
    else begin
        debug_clk_ctr <= 0;
        debug_clk <= ~debug_clk;
    end
end

reg [15:0] write_data = 0; wire [15:0] read_data;
reg start = 1'b0; wire trigger; reg [6:0] dbgreg; reg direction = 1'b0;
u8dbg debug(debug_clk, write_data, read_data,
    start, trigger, dbgreg, direction,
    JA[0], JA[1]); // sclk, sdata on JA1, JA2

reg [7:0] tx_tdata = 0; reg tx_tvalid = 1'b0; wire tx_tready;
uart_tx ser_tx(clk, tx_tdata, tx_tvalid, tx_tready, RsTx);
wire [7:0] rx_tdata; wire rx_tvalid; reg rx_tready = 1'b0;
uart_rx ser_rx(clk, rx_tdata, rx_tvalid, rx_tready, RsRx);

localparam STATE_START = 3'b000;        // idle
localparam STATE_READ_CMD = 3'b001;     // reading command octet
localparam STATE_READ_REG = 3'b010;     // reading debug register
localparam STATE_READ_VAL = 3'b011;     // reading 16-bit write value
localparam STATE_RUNNING = 3'b100;      // waiting for command to complete
localparam STATE_WRITE_RESP = 3'b101;   // writing response

reg [3:0] state = STATE_START;
reg [1:0] val_onum = 0;

always @(posedge clk) begin
    case (state)
        STATE_START: begin
            state <= STATE_READ_CMD;
        end
        STATE_READ_CMD: begin
            rx_tready <= 1;
            if (rx_tvalid) begin
                if (rx_tdata == 8'h72) begin // 'r' => read
                    direction <= 1;
                    state <= STATE_READ_REG;
                end else if (rx_tdata == 8'h77) begin // 'w' => write
                    direction <= 0;
                    state <= STATE_READ_REG;
                end else // invalid command
                    state <= STATE_START;
            end
        end
        STATE_READ_REG: begin
            if (rx_tvalid) begin
                dbgreg <= rx_tdata[6:0];
                if (direction) begin // read
                    rx_tready <= 0;
                    state <= STATE_RUNNING;
                end else // write, we need the write value as well
                    state <= STATE_READ_VAL;
            end
        end
        STATE_READ_VAL: begin
            if (rx_tvalid) begin
                if (val_onum == 0) begin // reading first octet
                    write_data[15:8] <= rx_tdata;
                    val_onum <= 1;
                end else begin // reading second octet
                    write_data[7:0] <= rx_tdata;
                    rx_tready <= 0;
                    val_onum <= 0;
                    state <= STATE_RUNNING;
                end
            end
        end
        STATE_RUNNING: begin
            if (trigger) begin
                start <= 0;
                state <= STATE_WRITE_RESP;
            end else
                start <= 1;
        end
        STATE_WRITE_RESP: begin
            if (tx_tready) begin
                if (val_onum == 0) begin // writing first octet
                    if (~direction)
                        tx_tdata <= 8'h10;
                    else
                        tx_tdata <= read_data[15:8];
                    tx_tvalid <= 1;
                    val_onum <= 1;
                end else if (val_onum == 1) begin // writing second octet
                    if (~direction)
                        tx_tdata <= 8'h00;
                    else
                        tx_tdata <= read_data[7:0];
                    tx_tvalid <= 1;
                    val_onum <= 2;
                end else begin // done write
                    tx_tvalid <= 0;
                    val_onum <= 0;
                    state <= STATE_START;
                end
            end
        end
        default: state <= STATE_START;
    endcase
end

endmodule
