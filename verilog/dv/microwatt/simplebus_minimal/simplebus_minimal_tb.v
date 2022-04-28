`default_nettype none
/*
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *  Copyright (C) 2018  Tim Edwards <tim@efabless.com>
 *  Copyright (C) 2020  Anton Blanchard <anton@linux.ibm.com>
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

`include "uprj_netlists.v"
`include "caravel_netlists.v"
`include "spiflash.v"


module simplebus_tb (
	input clk,

	input [7:0] ext_bus_in,
	input ext_bus_pty_in,

	output [7:0] ext_bus_out,
	output ext_bus_pty_out
);
	localparam [7:0] CMD_READ = 8'h2;
	localparam [7:0] CMD_WRITE = 8'h3;
	localparam [7:0] CMD_READ_ACK = 8'h82;
	localparam [7:0] CMD_WRITE_ACK = 8'h83;

	localparam [3:0] ADDR_BYTES = 4;
	localparam [3:0] DATA_BYTES = 8;

	localparam [3:0] READ_DELAY_CYCLES = 8;

	localparam [3:0] RECV_STATE_IDLE = 0;
	localparam [3:0] RECV_STATE_WRITE_ADDR = 1;
	localparam [3:0] RECV_STATE_WRITE_DATA = 2;
	localparam [3:0] RECV_STATE_WRITE_SEL = 3;
	localparam [3:0] RECV_STATE_READ_ADDR = 4;
	localparam [3:0] RECV_STATE_READ_DELAY = 5;
	reg [3:0] recv_state;

	reg [31:0] recv_addr;
	reg [63:0] recv_data;
	reg [7:0] recv_sel;
	reg [3:0] recv_count;
	reg [127:0] tx_data;

	reg [7:0] bus_out;

	assign ext_bus_out = bus_out;
	assign ext_bus_pty_out = ~^bus_out;

	initial begin
		bus_out <= 8'h0;
		recv_state <= 0;
		recv_addr <= 0;
		recv_sel <= 0;
		recv_data <= 0;
		recv_count <= 0;
		tx_data <= 0;
	end

	// receive on positive edge
	always @(posedge clk) begin
		if (ext_bus_pty_in != ~^ext_bus_in) begin
			$display("Bad parity on bus");
			$fatal;
		end

		case (recv_state)
			RECV_STATE_IDLE: begin
				//$display("Idle state");

				if (ext_bus_in == CMD_WRITE) begin
					$display("Got write command");
					recv_state <= RECV_STATE_WRITE_ADDR;
					recv_addr <= 0;
					recv_sel <= 0;
					recv_data <= 0;
					recv_count <= ADDR_BYTES;
				end
				if (ext_bus_in == CMD_READ) begin
					$display("Got read command");
					recv_state <= RECV_STATE_READ_ADDR;
					recv_addr <= 0;
					recv_sel <= 0;
					recv_data <= 0;
					recv_count <= ADDR_BYTES;
				end
			end

			RECV_STATE_WRITE_ADDR: begin
				$display("RECV_STATE_WRITE_ADDR state");

				recv_addr <= { ext_bus_in, recv_addr[31:8] };
				$display("A: %02x", ext_bus_in);
				if (recv_count == 1) begin
					recv_state <= RECV_STATE_WRITE_SEL;
				end else begin
					recv_count <= recv_count - 1;
				end
			end

			RECV_STATE_WRITE_SEL: begin
				$display("RECV_STATE_WRITE_SEL state");

				$display("S: %02x", ext_bus_in);
				recv_sel <= ext_bus_in;
				recv_state <= RECV_STATE_WRITE_DATA;
				recv_count <= DATA_BYTES;
			end

			RECV_STATE_WRITE_DATA: begin
				$display("RECV_STATE_WRITE_DATA state");

				recv_data <= { ext_bus_in, recv_data[63:8] };
				$display("D: %02x", ext_bus_in);
				if (recv_count == 1) begin
					tx_data <= CMD_WRITE_ACK;
					recv_state <= RECV_STATE_IDLE;
				end else begin
					recv_count <= recv_count - 1;
				end
			end

			RECV_STATE_READ_ADDR: begin
				$display("RECV_STATE_READ_ADDR state");

				recv_addr <= { ext_bus_in, recv_addr[31:8] };
				$display("A: %02x", ext_bus_in);
				if (recv_count == 1) begin
					recv_count <= READ_DELAY_CYCLES;
					recv_state <= RECV_STATE_READ_DELAY;
				end else begin
					recv_count <= recv_count - 1;
				end
			end

			RECV_STATE_READ_DELAY: begin
				$display("RECV_STATE_READ_DELAY state");
				if (recv_count == 1) begin
					tx_data <= { 64'h0102030405060708, CMD_READ_ACK};
					recv_state <= RECV_STATE_IDLE;
				end else begin
					recv_count <= recv_count - 1;
				end
			end

			default: begin
				$display("BAD state");
				$fatal;
			end
		endcase
	end

	// transmit on negative edge
	always @(negedge clk) begin
		if (|tx_data) begin
			$display("T: %02x", tx_data[7:0]);
			bus_out <= tx_data[7:0];
			tx_data <= tx_data[127:8];
		end else begin
			bus_out <= 8'h0;
		end
	end
endmodule

module simplebus_minimal_tb;
	reg clock;
	reg RSTB;
	reg microwatt_reset;
	reg power1, power2;
	reg power3, power4;

	wire gpio;
	wire [37:0] mprj_io;
	wire [1:0] checkbits;
	wire user_flash_csb;
	wire user_flash_clk;
	inout user_flash_io0;
	inout user_flash_io1;

	assign mprj_io[7] = microwatt_reset;

	assign mprj_io[35] = 1'b1; // Boot from flash

	wire ext_bus_clk;
	wire [7:0] ext_bus_in;
	wire ext_bus_pty_in;
	wire [7:0] ext_bus_out;
	wire ext_bus_pty_out;

	assign user_flash_csb = mprj_io[8];
	assign user_flash_clk = mprj_io[9];
	assign user_flash_io0 = mprj_io[10];
	assign mprj_io[11] = user_flash_io1;

	assign checkbits = mprj_io[17:16];

	assign mprj_io[3] = 1'b1;  // Force CSB high.

	// tie uart RX high
	assign mprj_io[5] = 1;

	// tie JTAG inputs low
	assign mprj_io[15:13] = 0;

	assign ext_bus_clk = mprj_io[16];
	assign ext_bus_in[7:0] = mprj_io[24:17];
	assign ext_bus_pty_in = mprj_io[25];
	assign mprj_io[33:26] = ext_bus_out[7:0];
	assign mprj_io[34] = ext_bus_pty_out;

	// 100 MHz clock
	always #5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end

	initial begin
		$dumpfile("simplebus_minimal.vcd");
		$dumpvars(0, simplebus_minimal_tb);

		$display("Microwatt external bus minimal test");

		repeat (1000000) begin
			@(posedge clock);
		end

		$display("Timeout, test failed");
		$fatal;
	end

	initial begin
		RSTB <= 1'b0;
		microwatt_reset <= 1'b1;
		#2000;
		// Would prefer to keep the management engine in reset
		//RSTB <= 1'b1;
		//#500;
		microwatt_reset <= 1'b0;
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
		// simple_por simulates the GPIO POR reset circuit as a 500 ns
		// delay. We want microwatt to power on after this, so wait
		// 1000 ns.
		#1000;
		power3 <= 1'b1;
		#100;
		power4 <= 1'b1;
	end

	//initial begin
		//wait(checkbits == 2'h1);
		//$display("Management engine started");

		//wait(checkbits == 2'h2);
		//$display("Microwatt alive!");

		//// Wait for Microwatt to respond with success
		//wait(checkbits == 2'h3);
		//$display("Success!");
		//$finish;
	//end

	wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;

	caravel uut (
		.vddio	  (VDD3V3),
		.vddio_2  (VDD3V3),
		.vssio	  (VSS),
		.vssio_2  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (USER_VDD3V3),
		.vdda1_2  (USER_VDD3V3),
		.vdda2    (USER_VDD3V3),
		.vssa1	  (VSS),
		.vssa1_2  (VSS),
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

	spiflash #(
		.FILENAME("microwatt.hex")
	) spiflash_microwatt (
		.csb(user_flash_csb),
		.clk(user_flash_clk),
		.io0(user_flash_io0),
		.io1(user_flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

	simplebus_tb simplebus_tb (
		.clk(ext_bus_clk),
		.ext_bus_in(ext_bus_in),
		.ext_bus_pty_in(ext_bus_pty_in),
		.ext_bus_out(ext_bus_out),
		.ext_bus_pty_out(ext_bus_pty_out)
	);
endmodule
`default_nettype wire
