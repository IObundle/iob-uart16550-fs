// SPDX-FileCopyrightText: 2026 IObundle, Lda
//
// SPDX-License-Identifier: MIT
//
// Py2HWSW Version 0.81.0 has generated this code (https://github.com/IObundle/py2hwsw).

`timescale 1ns / 1ps
`include "iob_iob2wishbone_conf.vh"

module iob_iob2wishbone #(
   parameter DATA_W     = `IOB_IOB2WISHBONE_DATA_W,
   parameter ADDR_W     = `IOB_IOB2WISHBONE_ADDR_W,
   parameter READ_BYTES = `IOB_IOB2WISHBONE_READ_BYTES
) (
   // clk_en_rst_s: Clock, clock enable and reset
   input                 clk_i,
   input                 cke_i,
   input                 arst_i,
   // iob_s: IOb native subordinate interface
   input                 iob_valid_i,
   input  [  ADDR_W-1:0] iob_addr_i,
   input  [  DATA_W-1:0] iob_wdata_i,
   input  [DATA_W/8-1:0] iob_wstrb_i,
   output                iob_rvalid_o,
   output [  DATA_W-1:0] iob_rdata_o,
   output                iob_ready_o,
   // wb_m: Wishbone manager interface
   input  [  DATA_W-1:0] wb_dat_i,
   output [  DATA_W-1:0] wb_datout_o,
   input                 wb_ack_i,
   output [  ADDR_W-1:0] wb_adr_o,
   output                wb_cyc_o,
   output [DATA_W/8-1:0] wb_sel_o,
   output                wb_stb_o,
   output                wb_we_o
);

   // valid output wire
   wire                iob_valid_r;
   // addr output wire
   wire [  ADDR_W-1:0] iob_address_r;
   // data output wire
   wire [  DATA_W-1:0] iob_wdata_r;
   // we intput wire
   wire                wb_we;
   // we output wire
   wire                wb_we_r;
   // strb intput wire
   wire [DATA_W/8-1:0] wb_select;
   // strb output wire
   wire [DATA_W/8-1:0] wb_select_r;
   // wb_data output wire
   wire [  DATA_W-1:0] wb_data_r;
   reg                 iob_rvalid_o_nxt;
   reg                 iob_rvalid_o_en;
   reg                 iob_rvalid_o_rst;

   always @(*) begin

      // Set rvalid on next cycle if read successful
      iob_rvalid_o_en  = iob_valid_i & iob_ready_o & (~wb_we_r);
      iob_rvalid_o_rst = iob_rvalid_o;  // Enable for one clock cycle
      iob_rvalid_o_nxt = 1'b1;

   end



   // Logic
   assign wb_adr_o    = iob_valid_i ? iob_addr_i : iob_address_r;
   assign wb_cyc_o    = iob_valid_i ? iob_valid_i : iob_valid_r;
   assign wb_stb_o    = wb_cyc_o;
   assign wb_datout_o = iob_valid_i ? iob_wdata_i : iob_wdata_r;
   assign wb_sel_o    = iob_valid_i ? wb_select : wb_select_r;
   assign wb_we_o     = iob_valid_i ? wb_we : wb_we_r;

   generate
      if (READ_BYTES >= (DATA_W / 8)) begin : gen_pad_read_bytes
         localparam RB_MASK = {READ_BYTES{1'b1}};
         assign wb_select = wb_we ? iob_wstrb_i : (RB_MASK) << (iob_addr_i[1:0]);
      end else begin : gen_read_bytes
         localparam RB_MASK = {{(DATA_W / 8 - READ_BYTES) {1'b0}}, {READ_BYTES{1'b1}}};
         assign wb_select = wb_we ? iob_wstrb_i : (RB_MASK) << (iob_addr_i[1:0]);
      end
   endgenerate
   assign wb_we       = |iob_wstrb_i;

   assign iob_rdata_o = wb_ack_i ? wb_dat_i : wb_data_r;
   assign iob_ready_o = wb_ack_i;


   // Default description
   iob_reg_care #(
      .DATA_W (1),
      .RST_VAL(0)
   ) iob_reg_valid (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .rst_i (wb_ack_i),
      .en_i  (iob_valid_i),
      // data_i port: Data input
      .data_i(iob_valid_i),
      // data_o port: Data output
      .data_o(iob_valid_r)
   );

   // Default description
   iob_reg_cae #(
      .DATA_W (ADDR_W),
      .RST_VAL(0)
   ) iob_reg_addr (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .en_i  (iob_valid_i),
      // data_i port: Data input
      .data_i(iob_addr_i),
      // data_o port: Data output
      .data_o(iob_address_r)
   );

   // Default description
   iob_reg_cae #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
   ) iob_reg_data (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .en_i  (iob_valid_i),
      // data_i port: Data input
      .data_i(iob_wdata_i),
      // data_o port: Data output
      .data_o(iob_wdata_r)
   );

   // Default description
   iob_reg_cae #(
      .DATA_W (1),
      .RST_VAL(0)
   ) iob_reg_we (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .en_i  (iob_valid_i),
      // data_i port: Data input
      .data_i(wb_we),
      // data_o port: Data output
      .data_o(wb_we_r)
   );

   // Default description
   iob_reg_cae #(
      .DATA_W (DATA_W / 8),
      .RST_VAL(0)
   ) iob_reg_strb (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .en_i  (iob_valid_i),
      // data_i port: Data input
      .data_i(wb_select),
      // data_o port: Data output
      .data_o(wb_select_r)
   );

   // Default description
   iob_reg_cae #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
   ) iob_reg_wb_data (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .en_i  (wb_ack_i),
      // data_i port: Data input
      .data_i(wb_dat_i),
      // data_o port: Data output
      .data_o(wb_data_r)
   );

   // iob_rvalid_o register
   iob_reg_care #(
      .DATA_W (1),
      .RST_VAL(0)
   ) iob_rvalid_o_reg (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .rst_i (iob_rvalid_o_rst),
      .en_i  (iob_rvalid_o_en),
      // data_i port: Data input
      .data_i(iob_rvalid_o_nxt),
      // data_o port: Data output
      .data_o(iob_rvalid_o)
   );


endmodule
