/* Generated by Yosys 0.9+3743 (git sha1 UNKNOWN, clang 7.0.1-8+deb10u2 -fPIC -Os) */

module register_file(
`ifdef USE_POWER_PINS
	vccd1, vssd1,
`endif
	clk, d_in, w_in, d_out);
`ifdef USE_POWER_PINS
  inout vccd1;
  inout vssd1;
`endif
  wire _00_;
  wire [4095:0] _01_;
  wire [63:0] _02_;
  wire [4095:0] _03_;
  wire [63:0] _04_;
  wire [63:0] _05_;
  wire _06_;
  wire [63:0] _07_;
  wire _08_;
  wire [63:0] _09_;
  wire [191:0] _10_;
  wire [4095:0] _11_;
  wire [63:0] _12_;
  input clk;
  input [23:0] d_in;
  output [191:0] d_out;
  input [71:0] w_in;
  reg [63:0] \$mem$\88  [63:0];
  reg [63:0] \88  [63:0];
  initial begin
    \88 [0] = 64'h0000000000000000;
    \88 [1] = 64'h0000000000000000;
    \88 [2] = 64'h0000000000000000;
    \88 [3] = 64'h0000000000000000;
    \88 [4] = 64'h0000000000000000;
    \88 [5] = 64'h0000000000000000;
    \88 [6] = 64'h0000000000000000;
    \88 [7] = 64'h0000000000000000;
    \88 [8] = 64'h0000000000000000;
    \88 [9] = 64'h0000000000000000;
    \88 [10] = 64'h0000000000000000;
    \88 [11] = 64'h0000000000000000;
    \88 [12] = 64'h0000000000000000;
    \88 [13] = 64'h0000000000000000;
    \88 [14] = 64'h0000000000000000;
    \88 [15] = 64'h0000000000000000;
    \88 [16] = 64'h0000000000000000;
    \88 [17] = 64'h0000000000000000;
    \88 [18] = 64'h0000000000000000;
    \88 [19] = 64'h0000000000000000;
    \88 [20] = 64'h0000000000000000;
    \88 [21] = 64'h0000000000000000;
    \88 [22] = 64'h0000000000000000;
    \88 [23] = 64'h0000000000000000;
    \88 [24] = 64'h0000000000000000;
    \88 [25] = 64'h0000000000000000;
    \88 [26] = 64'h0000000000000000;
    \88 [27] = 64'h0000000000000000;
    \88 [28] = 64'h0000000000000000;
    \88 [29] = 64'h0000000000000000;
    \88 [30] = 64'h0000000000000000;
    \88 [31] = 64'h0000000000000000;
    \88 [32] = 64'h0000000000000000;
    \88 [33] = 64'h0000000000000000;
    \88 [34] = 64'h0000000000000000;
    \88 [35] = 64'h0000000000000000;
    \88 [36] = 64'h0000000000000000;
    \88 [37] = 64'h0000000000000000;
    \88 [38] = 64'h0000000000000000;
    \88 [39] = 64'h0000000000000000;
    \88 [40] = 64'h0000000000000000;
    \88 [41] = 64'h0000000000000000;
    \88 [42] = 64'h0000000000000000;
    \88 [43] = 64'h0000000000000000;
    \88 [44] = 64'h0000000000000000;
    \88 [45] = 64'h0000000000000000;
    \88 [46] = 64'h0000000000000000;
    \88 [47] = 64'h0000000000000000;
    \88 [48] = 64'h0000000000000000;
    \88 [49] = 64'h0000000000000000;
    \88 [50] = 64'h0000000000000000;
    \88 [51] = 64'h0000000000000000;
    \88 [52] = 64'h0000000000000000;
    \88 [53] = 64'h0000000000000000;
    \88 [54] = 64'h0000000000000000;
    \88 [55] = 64'h0000000000000000;
    \88 [56] = 64'h0000000000000000;
    \88 [57] = 64'h0000000000000000;
    \88 [58] = 64'h0000000000000000;
    \88 [59] = 64'h0000000000000000;
    \88 [60] = 64'h0000000000000000;
    \88 [61] = 64'h0000000000000000;
    \88 [62] = 64'h0000000000000000;
    \88 [63] = 64'h0000000000000000;
  end
  always @(posedge clk) begin
    if (w_in[71]) \88 [w_in[5:0]] <= w_in[70:7];
  end
  assign _12_ = \88 [d_in[22:17]];
  assign _02_ = \88 [d_in[14:9]];
  assign _04_ = \88 [d_in[6:1]];
  assign _00_ = { 1'h0, d_in[6:1] } == { 1'h0, w_in[5:0] };
  assign _05_ = _00_ ? w_in[70:7] : _04_;
  assign _06_ = { 1'h0, d_in[14:9] } == { 1'h0, w_in[5:0] };
  assign _07_ = _06_ ? w_in[70:7] : _02_;
  assign _08_ = { 1'h0, d_in[22:17] } == { 1'h0, w_in[5:0] };
  assign _09_ = _08_ ? w_in[70:7] : _12_;
  assign _10_ = w_in[71] ? { _09_, _07_, _05_ } : { _12_, _02_, _04_ };
  assign d_out = _10_;
endmodule
