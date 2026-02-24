// SPDX-FileCopyrightText: 2025 IObundle, Lda
//
// SPDX-License-Identifier: MIT
//
// Py2HWSW Version 0.81 has generated this code (https://github.com/IObundle/py2hwsw).

`timescale 1ns / 1ps
`include "iob_uart16550_conf.vh"

module iob_uart16550 #(
   parameter ADDR_W = `IOB_UART16550_ADDR_W,
   parameter DATA_W = `IOB_UART16550_DATA_W
) (
   // clk_en_rst_s: Clock, clock enable and reset
   input             clk_i,
   input             cke_i,
   input             arst_i,
   // iob_csrs_cbus_s: Control and Status Registers interface
   input             iob_valid_i,
   input  [   5-1:0] iob_addr_i,
   input  [  32-1:0] iob_wdata_i,
   input  [32/8-1:0] iob_wstrb_i,
   output            iob_rvalid_o,
   output [  32-1:0] iob_rdata_o,
   output            iob_ready_o,
   // rs232_m: RS232 interface
   input             rs232_rxd_i,
   output            rs232_txd_o,
   output            rs232_rts_o,
   input             rs232_cts_i,
   // interrupt_o: UART16550 interrupt related signals
   output            interrupt_o
);

   // UART CSRs bus
   wire [    32-1:0] internal_wb_dat;
   wire [    32-1:0] internal_wb_datout;
   wire              internal_wb_ack;
   wire [ADDR_W-1:0] internal_wb_adr;
   wire              internal_wb_cyc;
   wire [  32/8-1:0] internal_wb_sel;
   wire              internal_wb_stb;
   wire              internal_wb_we;


   uart_top uart16550 (
      .wb_clk_i(clk_i),
      // WISHBONE interface
      .wb_rst_i(arst_i),

      .wb_dat_o (internal_wb_dat),
      .wb_dat_i (internal_wb_datout),
      .wb_ack_o (internal_wb_ack),
      .wb_adr_i (internal_wb_adr),
      .wb_cyc_i (internal_wb_cyc),
      .wb_sel_i (internal_wb_sel),
      .wb_stb_i (internal_wb_stb),
      .wb_we_i  (internal_wb_we),
      .int_o    (interrupt_o),
`ifdef UART_HAS_BAUDRATE_OUTPUT
      .baud1_o  (),
`endif
      // UART signals
      .srx_pad_i(rs232_rxd_i),
      .stx_pad_o(rs232_txd_o),
      .rts_pad_o(rs232_rts_o),
      .cts_pad_i(rs232_cts_i),
      .dtr_pad_o(),
      .dsr_pad_i(1'b1),
      .ri_pad_i (1'b0),
      .dcd_pad_i(1'b0)
   );


   // IOb to Wishbone converter.
   iob_iob2wishbone #(
      .ADDR_W    (ADDR_W),
      .DATA_W    (DATA_W),
      .READ_BYTES(1)
   ) iob2wishbone (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i       (clk_i),
      .cke_i       (cke_i),
      .arst_i      (arst_i),
      // iob_s port: IOb native subordinate interface
      .iob_valid_i (iob_valid_i),
      .iob_addr_i  (iob_addr_i),
      .iob_wdata_i (iob_wdata_i),
      .iob_wstrb_i (iob_wstrb_i),
      .iob_rvalid_o(iob_rvalid_o),
      .iob_rdata_o (iob_rdata_o),
      .iob_ready_o (iob_ready_o),
      // wb_m port: Wishbone manager interface
      .wb_dat_i    (internal_wb_dat),
      .wb_datout_o (internal_wb_datout),
      .wb_ack_i    (internal_wb_ack),
      .wb_adr_o    (internal_wb_adr),
      .wb_cyc_o    (internal_wb_cyc),
      .wb_sel_o    (internal_wb_sel),
      .wb_stb_o    (internal_wb_stb),
      .wb_we_o     (internal_wb_we)
   );


endmodule
