module top_module (
    input wire clk,
    input wire rst,
    input wire ps2_clk,
    input wire ps2_data,
    output wire[6:0] hex0,
    output wire[6:0] hex1,
     output wire [6:0]hex2,
    output wire [6:0]hex3,
     output wire[6:0] hex4,
    output wire [6:0]hex5,
    output wire overflow
);
wire[7:0] data;
wire nextdata_n;

wire ready;
wire [7:0] scan_code;
wire display_valid;
wire[7:0] count;
wire[7:0]ascii;
localparam [6:0] SEG_OFF = 7'b1111111;
wire key_valid;




wire [6:0] scan_lo_seg;
wire [6:0] scan_hi_seg;
wire [6:0] ascii_lo_seg;
wire [6:0] ascii_hi_seg;





ps2_keyboard u_ps2_keyboard(
    .clk(clk),
    .clrn(rst),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .nextdata_n(nextdata_n),
    .data(data),
    .ready(ready),
    .overflow(overflow)
);
// Validate the incoming FIFO byte.
scan_to_ascii check_key (
    .code(data),
    .ascii(),
    .valid(key_valid)
);

// Display the saved key rather than the changing FIFO byte.
scan_to_ascii convert_display (
    .code(scan_code),
    .ascii(ascii),
    .valid()
);

key_handler u_keyhandler(
    .clk(clk),
    .rst(rst),
    .data(data),
    .ready(ready),
    .key_valid(key_valid),
    .nextdata_n(nextdata_n),
    .scan_code(scan_code),
    .display_valid(display_valid),
    .count(count)
);
hex_decoder decode_scan_low (
    .value    (scan_code[3:0]),
    .segments (scan_lo_seg)
);

hex_decoder decode_scan_high (
    .value    (scan_code[7:4]),
    .segments (scan_hi_seg)
);

// 6. ASCII：中间两位
hex_decoder decode_ascii_low (
    .value    (ascii[3:0]),
    .segments (ascii_lo_seg)
);

hex_decoder decode_ascii_high (
    .value    (ascii[7:4]),
    .segments (ascii_hi_seg)
);

// 7. 累计次数：高两位，始终显示
hex_decoder decode_count_low (
    .value    (count[3:0]),
    .segments (hex4)
);

hex_decoder decode_count_high (
    .value    (count[7:4]),
    .segments (hex5)
);

// 8. 松开时，低四位全灭
assign hex0 = display_valid ? scan_lo_seg  : SEG_OFF;
assign hex1 = display_valid ? scan_hi_seg  : SEG_OFF;
assign hex2 = display_valid ? ascii_lo_seg : SEG_OFF;
assign hex3 = display_valid ? ascii_hi_seg : SEG_OFF;

endmodule