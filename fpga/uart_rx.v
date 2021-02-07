/*
 * UART receive module
 * ~ nlscc, Jan '21
 */

module uart_rx(
    input aclk,
    output reg [7:0] tdata, output reg tvalid, input tready,
    input rx_in
);

reg [8:0] data_shift_reg = 0;
reg [7:0] bit_counter = 0;
reg idle = 1'b1;

parameter prescale_div = 10417; // 100MHz => 9600Hz
reg [15:0] prescale_ctr = 0;

always @(posedge aclk) begin
    if (prescale_ctr < prescale_div - 1)
        prescale_ctr <= prescale_ctr + 1;
    else begin
        if (idle) begin
            if (~rx_in) // start bit
                idle <= 0;
        end else begin
            prescale_ctr <= 0;
            if (bit_counter < 9) begin // read data, stop bit
                bit_counter <= bit_counter + 1;
                data_shift_reg <= {rx_in, data_shift_reg[7:1]};
            end else begin
                bit_counter <= 0;
                tdata <= data_shift_reg[7:0];
                tvalid <= 1;
                idle <= 1;
            end
        end
    end
    if (tvalid & tready)
        tvalid <= 0;
end

endmodule
