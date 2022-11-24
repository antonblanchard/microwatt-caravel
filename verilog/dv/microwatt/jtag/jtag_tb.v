`default_nettype none
/*
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *  Copyright (C) 2018  Tim Edwards <tim@efabless.com>
 *  Copyright (C) 2020  Anton Blanchard <anton@linux.ibm.com>
 *  Copyright (C) 2021  Michael Neuling <mikey@linux.ibm.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`timescale 1 ns / 1 ps

module jtag_expect_idcode (
	input tdo,
	input tck,
	input en
);
	reg [4:0] recv_state;
	reg [31:0] pattern;

	reg clk;

	initial begin
		recv_state <= 0;
		pattern <= 0;
	end

	always @(posedge tck) begin
	   if (en == 1'b1) begin
	      pattern <= {tdo, pattern[31:1]};
	      recv_state <= recv_state + 1;
	   end
	   case (recv_state)
	     31: begin
		recv_state <= 0;
		$display("Testing: Read %x from JTAG", pattern);
		// Expecting 7 back
		if (pattern == 32'h14d57048) begin
		   $display("PASSED");
		   $finish;
		end else begin
		   $display("FAILED: should have been 14d57048");
		   $fatal;
		end
	     end
	   endcase
	end
endmodule

module jtag_tb;
	reg clock;
	reg RSTB;
	reg microwatt_reset;
	reg power1, power2;
	reg power3, power4;

	wire gpio;
	wire [37:0] mprj_io;
	wire [15:0] checkbits;
	wire user_flash_csb;
	wire user_flash_clk;
	inout user_flash_io0;
	inout user_flash_io1;

	wire jtag_tdo;
	reg jtag_tdo_en;
	reg jtag_tms;
	reg jtag_tck;
	reg jtag_tdi;

	assign mprj_io[7] = microwatt_reset;

	assign mprj_io[35] = 1'b1; // Boot from flash

	assign user_flash_csb = mprj_io[8];
	assign user_flash_clk = mprj_io[9];
	assign user_flash_io0 = mprj_io[10];
	assign mprj_io[11] = user_flash_io1;

	assign checkbits = mprj_io[31:16];

	assign mprj_io[3] = 1'b1;  // Force CSB high.

	assign jtag_tdo = mprj_io[12];
	assign mprj_io[13] = jtag_tms;
	assign mprj_io[14] = jtag_tck;
	assign mprj_io[15] = jtag_tdi;

	// 100 MHz clock
	always #5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end

	initial begin
		//$dumpfile("jtag.vcd");
		//$dumpvars(0, jtag_tb);

		$display("Microwatt JTAG IDCODE test");

		repeat (150) begin
			repeat (10000) @(posedge clock);
			// Diagnostic. . . interrupts output pattern.
		end
		$finish;
	end

	initial begin
		RSTB <= 1'b0;
		microwatt_reset <= 1'b1;
		#1000;
		microwatt_reset <= 1'b0;
		// Note: keep management engine in reset
		//RSTB <= 1'b1;
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		power3 <= 1'b0;
		power4 <= 1'b0;
		#100;
		power1 <= 1'b1;
		#100;
		power2 <= 1'b1;
		#100;
		power3 <= 1'b1;
		#100;
		power4 <= 1'b1;
	end

	initial begin
		jtag_tms <= 1'b1;
		jtag_tck <= 1'b1;
		jtag_tdi <= 1'b1;
		jtag_tdo_en <= 1'b0;

		#10000;

		jtag_tms <= 1'b1;
		jtag_tck <= 1'b0;
		#1000;
		jtag_tck <= 1'b1;
		#1000;

		jtag_tms <= 1'b0; //rti
		jtag_tck <= 1'b0;
		#1000;
		jtag_tck <= 1'b1;
		#1000;

		jtag_tms <= 1'b1; //drs
		jtag_tck <= 1'b0;
		#1000;
		jtag_tck <= 1'b1;
		#1000;

		jtag_tms <= 1'b0; // cdr
		jtag_tck <= 1'b0;
		#1000;
		jtag_tck <= 1'b1;
		#1000;

		jtag_tms <= 1'b0; // sdr
		jtag_tck <= 1'b0;
		#1000;
		jtag_tck <= 1'b1;
		#1000;

		jtag_tms <= 1'b0; // sdr
		jtag_tck <= 1'b0;
		#1000;
		jtag_tck <= 1'b1;
		#1000;

		jtag_tms <= 1'b0; // sdr
		jtag_tdo_en <= 1'b1;
		jtag_tck <= 1'b0;
		#1000;
		jtag_tck <= 1'b1;
		#1000;

		repeat (32) begin
			jtag_tck <= 1'b0;
			#1000;
			jtag_tck <= 1'b1;
			#1000;
		end 

	end

	wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;

	caravel uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (USER_VDD3V3),
		.vdda2    (USER_VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (USER_VDD1V8),
		.vccd2	  (USER_VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
		.mprj_io  (mprj_io),
		.resetb	  (RSTB)
	);

	spiflash_microwatt #(
		.FILENAME("microwatt.hex")
	) spiflash_microwatt (
		.csb(user_flash_csb),
		.clk(user_flash_clk),
		.io0(user_flash_io0),
		.io1(user_flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

	jtag_expect_idcode tb_jtag (
		.tdo(jtag_tdo),
		.tck(jtag_tck),
		.en(jtag_tdo_en)
	);

endmodule
`default_nettype wire
