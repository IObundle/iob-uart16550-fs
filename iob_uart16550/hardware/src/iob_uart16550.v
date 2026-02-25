// SPDX-FileCopyrightText: 2026 IObundle, Lda
//
// SPDX-License-Identifier: MIT
//
// Py2HWSW Version 0.81.0 has generated this code (https://github.com/IObundle/py2hwsw).

`timescale 1ns / 1ps
`include "iob_uart16550_conf.vh"

module iob_uart16550 #(
   parameter ADDR_W = `IOB_UART16550_ADDR_W,
   parameter DATA_W = `IOB_UART16550_DATA_W
) (
   // clk_en_rst_s: Clock, clock enable and reset
   input           clk_i,
   input           cke_i,
   input           arst_i,
   // csrs_cbus_s: Control and status interface, when selecting the IOb CSR interface.
   input           iob_valid_i,
   input  [ 5-1:0] iob_addr_i,
   input  [32-1:0] iob_wdata_i,
   input  [ 4-1:0] iob_wstrb_i,
   output          iob_rvalid_o,
   output [32-1:0] iob_rdata_o,
   output          iob_ready_o,
   // rs232_m: RS232 interface
   input           rs232_rxd_i,
   output          rs232_txd_o,
   output          rs232_rts_o,
   input           rs232_cts_i,
   // interrupt_o: UART16550 interrupt related signals
   output          interrupt_o
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
   // RS232 interface
   wire              internal_rs232_dcd;
   wire              internal_rs232_rxd;
   wire              internal_rs232_txd;
   wire              internal_rs232_dtr;
   wire              internal_rs232_dsr;
   wire              internal_rs232_rts;
   wire              internal_rs232_cts;
   wire              internal_rs232_ri;


   // Assign RS232 interface signals
   assign internal_rs232_rxd = rs232_rxd_i;
   assign rs232_txd_o        = internal_rs232_txd;
   assign rs232_rts_o        = internal_rs232_rts;
   assign internal_rs232_cts = rs232_cts_i;
   // internal_rs232_dtr floating
   assign internal_rs232_dsr = 1'b1;
   assign internal_rs232_ri  = 1'b0;
   assign internal_rs232_dcd = 1'b0;


   // Convert CSRs interface into internal wishbone bus
   iob_universal_converter_iob_wb #(
      .ADDR_W    (ADDR_W),
      .DATA_W    (DATA_W),
      .READ_BYTES(1)
   ) universal_converter (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i       (clk_i),
      .cke_i       (cke_i),
      .arst_i      (arst_i),
      // s_s port: Subordinate port
      .iob_valid_i (iob_valid_i),
      .iob_addr_i  (iob_addr_i),
      .iob_wdata_i (iob_wdata_i),
      .iob_wstrb_i (iob_wstrb_i),
      .iob_rvalid_o(iob_rvalid_o),
      .iob_rdata_o (iob_rdata_o),
      .iob_ready_o (iob_ready_o),
      // m_m port: Manager port
      .wb_dat_i    (internal_wb_dat),
      .wb_datout_o (internal_wb_datout),
      .wb_ack_i    (internal_wb_ack),
      .wb_adr_o    (internal_wb_adr),
      .wb_cyc_o    (internal_wb_cyc),
      .wb_sel_o    (internal_wb_sel),
      .wb_stb_o    (internal_wb_stb),
      .wb_we_o     (internal_wb_we)
   );

   // UART16550 Serial Transceiver
   iob_uart16550_st serial_transceiver (
      // wb_s port: CSRs wisbhone subordinate interface
      .wb_dat_o   (internal_wb_dat),
      .wb_datout_i(internal_wb_datout),
      .wb_ack_o   (internal_wb_ack),
      .wb_adr_i   (internal_wb_adr),
      .wb_cyc_i   (internal_wb_cyc),
      .wb_sel_i   (internal_wb_sel),
      .wb_stb_i   (internal_wb_stb),
      .wb_we_i    (internal_wb_we),
      // rs232_m port: RS232 interface
      .rs232_dcd_i(internal_rs232_dcd),
      .rs232_rxd_i(internal_rs232_rxd),
      .rs232_txd_o(internal_rs232_txd),
      .rs232_dtr_o(internal_rs232_dtr),
      .rs232_dsr_i(internal_rs232_dsr),
      .rs232_rts_o(internal_rs232_rts),
      .rs232_cts_i(internal_rs232_cts),
      .rs232_ri_i (internal_rs232_ri),
      // interrupt_o port: UART16550 interrupt related signals
      .int_o      (interrupt_o),
      // clk_rst_s port: Clock and reset
      .clk_i      (clk_i),
      .arst_i     (arst_i)
   );


endmodule
