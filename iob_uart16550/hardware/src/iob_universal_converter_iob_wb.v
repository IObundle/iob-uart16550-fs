// SPDX-FileCopyrightText: 2026 IObundle, Lda
//
// SPDX-License-Identifier: MIT
//
// Py2HWSW Version 0.81.0 has generated this code (https://github.com/IObundle/py2hwsw).

`timescale 1ns / 1ps
`include "iob_universal_converter_iob_wb_conf.vh"

module iob_universal_converter_iob_wb #(
   parameter ADDR_W     = `IOB_UNIVERSAL_CONVERTER_IOB_WB_ADDR_W,
   parameter DATA_W     = `IOB_UNIVERSAL_CONVERTER_IOB_WB_DATA_W,
   parameter READ_BYTES = `IOB_UNIVERSAL_CONVERTER_IOB_WB_READ_BYTES
) (
   // clk_en_rst_s: Clock, clock enable and reset
   input                 clk_i,
   input                 cke_i,
   input                 arst_i,
   // s_s: Subordinate port
   input                 iob_valid_i,
   input  [  ADDR_W-1:0] iob_addr_i,
   input  [  DATA_W-1:0] iob_wdata_i,
   input  [DATA_W/8-1:0] iob_wstrb_i,
   output                iob_rvalid_o,
   output [  DATA_W-1:0] iob_rdata_o,
   output                iob_ready_o,
   // m_m: Manager port
   input  [  DATA_W-1:0] wb_dat_i,
   output [  DATA_W-1:0] wb_datout_o,
   input                 wb_ack_i,
   output [  ADDR_W-1:0] wb_adr_o,
   output                wb_cyc_o,
   output [DATA_W/8-1:0] wb_sel_o,
   output                wb_stb_o,
   output                wb_we_o
);

   // Internal IOb wire
   wire                iob_valid;
   wire [  ADDR_W-1:0] iob_addr;
   wire [  DATA_W-1:0] iob_wdata;
   wire [DATA_W/8-1:0] iob_wstrb;
   wire                iob_rvalid;
   wire [  DATA_W-1:0] iob_rdata;
   wire                iob_ready;


   // Directly connect subordinate IOb port to intetnal IOb wire
   assign iob_valid    = iob_valid_i;
   assign iob_addr     = iob_addr_i;
   assign iob_wdata    = iob_wdata_i;
   assign iob_wstrb    = iob_wstrb_i;
   assign iob_rvalid_o = iob_rvalid;
   assign iob_rdata_o  = iob_rdata;
   assign iob_ready_o  = iob_ready;


   // Convert IOb from internal wire into Wishbone interface for manager port
   iob_iob2wishbone #(
      .ADDR_W    (ADDR_W),
      .DATA_W    (DATA_W),
      .READ_BYTES(READ_BYTES)
   ) iob_iob2wishbone_converter (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i       (clk_i),
      .cke_i       (cke_i),
      .arst_i      (arst_i),
      // iob_s port: IOb native subordinate interface
      .iob_valid_i (iob_valid),
      .iob_addr_i  (iob_addr),
      .iob_wdata_i (iob_wdata),
      .iob_wstrb_i (iob_wstrb),
      .iob_rvalid_o(iob_rvalid),
      .iob_rdata_o (iob_rdata),
      .iob_ready_o (iob_ready),
      // wb_m port: Wishbone manager interface
      .wb_dat_i    (wb_dat_i),
      .wb_datout_o (wb_datout_o),
      .wb_ack_i    (wb_ack_i),
      .wb_adr_o    (wb_adr_o),
      .wb_cyc_o    (wb_cyc_o),
      .wb_sel_o    (wb_sel_o),
      .wb_stb_o    (wb_stb_o),
      .wb_we_o     (wb_we_o)
   );


endmodule
