/*
 * UART transmit module
 * ~ nlscc, Jan '21
 */

module uart_tx(
    input aclk,
    input [7:0] tdata, input tvalid, output reg tready,
    output reg tx_out
);

reg [9:0] data_shift_reg;
reg [7:0] bit_counter = 0;
reg idle = 1'b1;

parameter prescale_div = 10417; // 100MHz => 9600Hz
reg [15:0] prescale_ctr = 0;

always @(posedge aclk) begin
    if (idle) begin
        if (tvalid) begin
            tready <= 0;
            data_shift_reg <= {1'b1, tdata, 1'b0}; // start bit, data, stop bit
            idle <= 0;
        end else begin
            tready <= 1;
            tx_out <= 1;
        end
    end else begin
        if (prescale_ctr < prescale_div - 1)
            prescale_ctr <= prescale_ctr + 1;
        else begin
            prescale_ctr <= 0;
            if (bit_counter < 10) begin
                {data_shift_reg, tx_out} <= {1'b0, data_shift_reg};
                bit_counter <= bit_counter + 1;
            end else begin
                bit_counter <= 0;
                tready <= 1;
                idle <= 1;
            end
        end
    end
end

endmodule
