// SPDX-FileCopyrightText: 2026 IObundle, Lda
//
// SPDX-License-Identifier: MIT
//
// Py2HWSW Version 0.81.0 has generated this code (https://github.com/IObundle/py2hwsw).

`timescale 1ns / 1ps
`include "iob_uart16550_csrs_conf.vh"

module iob_uart16550_csrs #(
   parameter ADDR_W = `IOB_UART16550_CSRS_ADDR_W,  // Don't change this parameter value!
   parameter DATA_W = `IOB_UART16550_CSRS_DATA_W
) (
   // clk_en_rst_s: Clock, clock enable and reset
   input                              clk_i,
   input                              cke_i,
   input                              arst_i,
   // control_if_s: CSR control interface. Interface type defined by `csr_if` parameter.
   input                              iob_valid_i,
   input  [                    4-1:0] iob_addr_i,
   input  [               DATA_W-1:0] iob_wdata_i,
   input  [             DATA_W/8-1:0] iob_wstrb_i,
   output                             iob_rvalid_o,
   output [               DATA_W-1:0] iob_rdata_o,
   output                             iob_ready_o,
   // rbr_thr_dll_io: rbr_thr_dll register interface
   output [                    8-1:0] rbr_thr_dll_rdata_o,
   input  [                    8-1:0] rbr_thr_dll_wdata_i,
   input  [((8/8 > 1) ? 8/8 : 1)-1:0] rbr_thr_dll_wstrb_i,
   // ier_dlm_io: ier_dlm register interface
   output [                    8-1:0] ier_dlm_rdata_o,
   input  [                    8-1:0] ier_dlm_wdata_i,
   input  [((8/8 > 1) ? 8/8 : 1)-1:0] ier_dlm_wstrb_i,
   // iir_fcr_io: iir_fcr register interface
   output [                    8-1:0] iir_fcr_rdata_o,
   input  [                    8-1:0] iir_fcr_wdata_i,
   input  [((8/8 > 1) ? 8/8 : 1)-1:0] iir_fcr_wstrb_i,
   // lcr_io: lcr register interface
   output [                    8-1:0] lcr_rdata_o,
   input  [                    8-1:0] lcr_wdata_i,
   input  [((8/8 > 1) ? 8/8 : 1)-1:0] lcr_wstrb_i,
   // mcr_o: mcr register interface
   output [                    8-1:0] mcr_rdata_o,
   // lsr_i: lsr register interface
   input  [                    8-1:0] lsr_wdata_i,
   // msr_i: msr register interface
   input  [                    8-1:0] msr_wdata_i
);

   // Internal iob interface
   wire                internal_iob_valid;
   wire [  ADDR_W-1:0] internal_iob_addr;
   wire [  DATA_W-1:0] internal_iob_wdata;
   wire [DATA_W/8-1:0] internal_iob_wstrb;
   wire                internal_iob_rvalid;
   wire [  DATA_W-1:0] internal_iob_rdata;
   wire                internal_iob_ready;
   wire                state;
   reg                 state_nxt;
   wire                write_en;
   wire [  ADDR_W-1:0] internal_iob_addr_stable;
   wire [  ADDR_W-1:0] internal_iob_addr_reg;
   wire                internal_iob_addr_reg_en;
   wire [       8-1:0] rbr_thr_dll_wdata;
   wire                rbr_thr_dll_w_valid;
   wire                rbr_thr_dll_reg_en;
   wire [       8-1:0] rbr_thr_dll_reg_data;
   wire [       8-1:0] ier_dlm_wdata;
   wire                ier_dlm_w_valid;
   wire                ier_dlm_reg_en;
   wire [       8-1:0] ier_dlm_reg_data;
   wire [       8-1:0] iir_fcr_wdata;
   wire                iir_fcr_w_valid;
   wire                iir_fcr_reg_en;
   wire [       8-1:0] iir_fcr_reg_data;
   wire [       8-1:0] lcr_wdata;
   wire                lcr_w_valid;
   wire                lcr_reg_en;
   wire [       8-1:0] lcr_reg_data;
   wire [       8-1:0] mcr_wdata;
   wire                mcr_w_valid;
   wire [       8-1:0] rbr_thr_dll_rdata;
   wire [       8-1:0] ier_dlm_rdata;
   wire [       8-1:0] iir_fcr_rdata;
   wire [       8-1:0] lcr_rdata;
   wire [       8-1:0] lsr_rdata;
   wire [       8-1:0] msr_rdata;
   wire                iob_rvalid_out;
   reg                 iob_rvalid_nxt;
   wire [      32-1:0] iob_rdata_out;
   reg  [      32-1:0] iob_rdata_nxt;
   wire                iob_ready_out;
   reg                 iob_ready_nxt;


   // Include iob_functions for use in parameters
   localparam IOB_MAX_W = ADDR_W;
   function [IOB_MAX_W-1:0] iob_max;
      input [IOB_MAX_W-1:0] a;
      input [IOB_MAX_W-1:0] b;
      begin
         if (a > b) iob_max = a;
         else iob_max = b;
      end
   endfunction

   function integer iob_abs;
      input integer a;
      begin
         iob_abs = (a >= 0) ? a : -a;
      end
   endfunction

   `define IOB_NBYTES (DATA_W/8)
   `define IOB_NBYTES_W $clog2(`IOB_NBYTES)
   `define IOB_WORD_ADDR(ADDR) ((ADDR>>`IOB_NBYTES_W)<<`IOB_NBYTES_W)

   localparam WSTRB_W = DATA_W / 8;

   //FSM states
   localparam WAIT_REQ = 1'd0;
   localparam WAIT_RVALID = 1'd1;


   assign internal_iob_addr_reg_en = internal_iob_valid;
   assign internal_iob_addr_stable = internal_iob_valid ? internal_iob_addr : internal_iob_addr_reg;

   assign write_en = |internal_iob_wstrb;

   //write address
   wire [($clog2(WSTRB_W)+1)-1:0] byte_offset;
   iob_ctls #(
      .W     (WSTRB_W),
      .MODE  (0),
      .SYMBOL(0)
   ) bo_inst (
      .data_i (internal_iob_wstrb),
      .count_o(byte_offset)
   );

   wire [ADDR_W-1:0] wstrb_addr;
   assign wstrb_addr = `IOB_WORD_ADDR(internal_iob_addr_stable) + byte_offset;

   // Create a special readstrobe for "REG" (auto) CSRs.
   // LSBs 0 = read full word; LSBs 1 = read byte; LSBs 2 = read half word; LSBs 3 = read byte.
   reg [1:0] shift_amount;
   always @(*) begin
      case (internal_iob_addr_stable[1:0])
         // Access entire word
         2'b00:   shift_amount = 2;
         // Access single byte
         2'b01:   shift_amount = 0;
         // Access half word
         2'b10:   shift_amount = 1;
         // Access single byte
         2'b11:   shift_amount = 0;
         default: shift_amount = 0;
      endcase
   end


   //NAME: rbr_thr_dll;
   //MODE: RW; WIDTH: 8; RST_VAL: 0; ADDR: 0; SPACE (bytes): 1 (max); TYPE: REG. 

   assign rbr_thr_dll_wdata = internal_iob_wdata[0+:8];
   wire rbr_thr_dll_addressed_w;
   assign rbr_thr_dll_addressed_w = (wstrb_addr < 1);
   assign rbr_thr_dll_w_valid     = internal_iob_valid & (write_en & rbr_thr_dll_addressed_w);
   assign rbr_thr_dll_rdata       = rbr_thr_dll_rdata_o;
   assign rbr_thr_dll_reg_en      = rbr_thr_dll_w_valid | (|rbr_thr_dll_wstrb_i);
   assign rbr_thr_dll_reg_data    = rbr_thr_dll_w_valid ? rbr_thr_dll_wdata : rbr_thr_dll_wdata_i;
   iob_reg_cae #(
      .DATA_W (8),
      .RST_VAL(8'd0)
   ) rbr_thr_dll_datareg_wr (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .en_i  (rbr_thr_dll_reg_en),
      .data_i(rbr_thr_dll_reg_data),
      .data_o(rbr_thr_dll_rdata_o)
   );



   //NAME: ier_dlm;
   //MODE: RW; WIDTH: 8; RST_VAL: 0; ADDR: 1; SPACE (bytes): 1 (max); TYPE: REG. 

   assign ier_dlm_wdata = internal_iob_wdata[8+:8];
   wire ier_dlm_addressed_w;
   assign ier_dlm_addressed_w = (wstrb_addr >= (1)) && (wstrb_addr < 2);
   assign ier_dlm_w_valid     = internal_iob_valid & (write_en & ier_dlm_addressed_w);
   assign ier_dlm_rdata       = ier_dlm_rdata_o;
   assign ier_dlm_reg_en      = ier_dlm_w_valid | (|ier_dlm_wstrb_i);
   assign ier_dlm_reg_data    = ier_dlm_w_valid ? ier_dlm_wdata : ier_dlm_wdata_i;
   iob_reg_cae #(
      .DATA_W (8),
      .RST_VAL(8'd0)
   ) ier_dlm_datareg_wr (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .en_i  (ier_dlm_reg_en),
      .data_i(ier_dlm_reg_data),
      .data_o(ier_dlm_rdata_o)
   );



   //NAME: iir_fcr;
   //MODE: RW; WIDTH: 8; RST_VAL: 193; ADDR: 2; SPACE (bytes): 1 (max); TYPE: REG. 

   assign iir_fcr_wdata = internal_iob_wdata[16+:8];
   wire iir_fcr_addressed_w;
   assign iir_fcr_addressed_w = (wstrb_addr >= (2)) && (wstrb_addr < 3);
   assign iir_fcr_w_valid     = internal_iob_valid & (write_en & iir_fcr_addressed_w);
   assign iir_fcr_rdata       = iir_fcr_rdata_o;
   assign iir_fcr_reg_en      = iir_fcr_w_valid | (|iir_fcr_wstrb_i);
   assign iir_fcr_reg_data    = iir_fcr_w_valid ? iir_fcr_wdata : iir_fcr_wdata_i;
   iob_reg_cae #(
      .DATA_W (8),
      .RST_VAL(8'd193)
   ) iir_fcr_datareg_wr (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .en_i  (iir_fcr_reg_en),
      .data_i(iir_fcr_reg_data),
      .data_o(iir_fcr_rdata_o)
   );



   //NAME: lcr;
   //MODE: RW; WIDTH: 8; RST_VAL: 3; ADDR: 3; SPACE (bytes): 1 (max); TYPE: REG. 

   assign lcr_wdata = internal_iob_wdata[24+:8];
   wire lcr_addressed_w;
   assign lcr_addressed_w = (wstrb_addr >= (3)) && (wstrb_addr < 4);
   assign lcr_w_valid     = internal_iob_valid & (write_en & lcr_addressed_w);
   assign lcr_rdata       = lcr_rdata_o;
   assign lcr_reg_en      = lcr_w_valid | (|lcr_wstrb_i);
   assign lcr_reg_data    = lcr_w_valid ? lcr_wdata : lcr_wdata_i;
   iob_reg_cae #(
      .DATA_W (8),
      .RST_VAL(8'd3)
   ) lcr_datareg_wr (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .en_i  (lcr_reg_en),
      .data_i(lcr_reg_data),
      .data_o(lcr_rdata_o)
   );



   //NAME: mcr;
   //MODE: W; WIDTH: 8; RST_VAL: 0; ADDR: 4; SPACE (bytes): 1 (max); TYPE: REG. 

   assign mcr_wdata = internal_iob_wdata[0+:8];
   wire mcr_addressed_w;
   assign mcr_addressed_w = (wstrb_addr >= (4)) && (wstrb_addr < 5);
   assign mcr_w_valid     = internal_iob_valid & (write_en & mcr_addressed_w);
   iob_reg_cae #(
      .DATA_W (8),
      .RST_VAL(8'd0)
   ) mcr_datareg_wr (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .en_i  (mcr_w_valid),
      .data_i(mcr_wdata),
      .data_o(mcr_rdata_o)
   );



   //NAME: rbr_thr_dll;
   //MODE: RW; WIDTH: 8; RST_VAL: 0; ADDR: 0; SPACE (bytes): 1 (max); TYPE: REG. 

   wire rbr_thr_dll_addressed_r;
   assign rbr_thr_dll_addressed_r = (internal_iob_addr_stable >> shift_amount <= iob_max(
       1, 0 >> shift_amount
   ));


   //NAME: ier_dlm;
   //MODE: RW; WIDTH: 8; RST_VAL: 0; ADDR: 1; SPACE (bytes): 1 (max); TYPE: REG. 

   wire ier_dlm_addressed_r;
   assign ier_dlm_addressed_r = (internal_iob_addr_stable>>shift_amount >= (1>>shift_amount)) && (internal_iob_addr_stable>>shift_amount <= iob_max(
       1, 1 >> shift_amount
   ));


   //NAME: iir_fcr;
   //MODE: RW; WIDTH: 8; RST_VAL: 193; ADDR: 2; SPACE (bytes): 1 (max); TYPE: REG. 

   wire iir_fcr_addressed_r;
   assign iir_fcr_addressed_r = (internal_iob_addr_stable>>shift_amount >= (2>>shift_amount)) && (internal_iob_addr_stable>>shift_amount <= iob_max(
       1, 2 >> shift_amount
   ));


   //NAME: lcr;
   //MODE: RW; WIDTH: 8; RST_VAL: 3; ADDR: 3; SPACE (bytes): 1 (max); TYPE: REG. 

   wire lcr_addressed_r;
   assign lcr_addressed_r = (internal_iob_addr_stable>>shift_amount >= (3>>shift_amount)) && (internal_iob_addr_stable>>shift_amount <= iob_max(
       1, 3 >> shift_amount
   ));


   //NAME: lsr;
   //MODE: R; WIDTH: 8; RST_VAL: 96; ADDR: 5; SPACE (bytes): 1 (max); TYPE: REG. 

   wire lsr_addressed_r;
   assign lsr_addressed_r = (internal_iob_addr_stable>>shift_amount >= (5>>shift_amount)) && (internal_iob_addr_stable>>shift_amount <= iob_max(
       1, 5 >> shift_amount
   ));
   iob_reg_ca #(
      .DATA_W (8),
      .RST_VAL(8'd96)
   ) lsr_datareg_rd (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .data_i(lsr_wdata_i),
      .data_o(lsr_rdata)
   );



   //NAME: msr;
   //MODE: R; WIDTH: 8; RST_VAL: 0; ADDR: 6; SPACE (bytes): 1 (max); TYPE: REG. 

   wire msr_addressed_r;
   assign msr_addressed_r = (internal_iob_addr_stable>>shift_amount >= (6>>shift_amount)) && (internal_iob_addr_stable>>shift_amount <= iob_max(
       1, 6 >> shift_amount
   ));
   iob_reg_ca #(
      .DATA_W (8),
      .RST_VAL(8'd0)
   ) msr_datareg_rd (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .data_i(msr_wdata_i),
      .data_o(msr_rdata)
   );



   //NAME: version;
   //MODE: R; WIDTH: 24; RST_VAL: 000104; ADDR: 8; SPACE (bytes): 4 (max); TYPE: REG. 

   wire version_addressed_r;
   assign version_addressed_r = (internal_iob_addr_stable>>shift_amount >= (8>>shift_amount)) && (internal_iob_addr_stable>>shift_amount <= iob_max(
       1, 11 >> shift_amount
   ));

   //RESPONSE SWITCH

   assign internal_iob_rvalid = iob_rvalid_out;
   assign internal_iob_rdata = iob_rdata_out;
   assign internal_iob_ready = iob_ready_out;

   always @* begin
      iob_rdata_nxt = 32'd0;
      if (rbr_thr_dll_addressed_r) begin
         iob_rdata_nxt[0+:8] = rbr_thr_dll_rdata | 8'd0;
      end

      if (ier_dlm_addressed_r) begin
         iob_rdata_nxt[8+:8] = ier_dlm_rdata | 8'd0;
      end

      if (iir_fcr_addressed_r) begin
         iob_rdata_nxt[16+:8] = iir_fcr_rdata | 8'd0;
      end

      if (lcr_addressed_r) begin
         iob_rdata_nxt[24+:8] = lcr_rdata | 8'd0;
      end

      if (lsr_addressed_r) begin
         iob_rdata_nxt[8+:8] = lsr_rdata | 8'd0;
      end

      if (msr_addressed_r) begin
         iob_rdata_nxt[16+:8] = msr_rdata | 8'd0;
      end

      if (version_addressed_r) begin
         iob_rdata_nxt[0+:32] = 32'h000104 | 32'd0;
      end



      // ######  FSM  #############

      //FSM default values
      iob_ready_nxt  = 1'b0;
      iob_rvalid_nxt = 1'b0;
      state_nxt      = state;

      //FSM state machine
      case (state)
         WAIT_REQ: begin
            if (internal_iob_valid) begin  // Wait for a valid request

               iob_ready_nxt = 1'b1;

               // If is read and ready, go to WAIT_RVALID
               if (iob_ready_nxt && (!write_en)) begin
                  state_nxt = WAIT_RVALID;
               end
            end
         end

         default: begin  // WAIT_RVALID

            if (iob_rvalid_out) begin  // Transfer done
               state_nxt = WAIT_REQ;
            end else begin
               iob_rvalid_nxt = 1'b1;

            end
         end
      endcase

   end  //always @*



        // store iob addr
   iob_reg_cae #(
      .DATA_W (ADDR_W),
      .RST_VAL({ADDR_W{1'b0}})
   ) internal_addr_reg (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .en_i  (internal_iob_addr_reg_en),
      // data_i port: Data input
      .data_i(internal_iob_addr),
      // data_o port: Data output
      .data_o(internal_iob_addr_reg)
   );

   // state register
   iob_reg_ca #(
      .DATA_W (1),
      .RST_VAL(1'b0)
   ) state_reg (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      // data_i port: Data input
      .data_i(state_nxt),
      // data_o port: Data output
      .data_o(state)
   );

   // Convert CSR interface into internal IOb port
   iob_universal_converter_iob_iob #(
      .ADDR_W(ADDR_W),
      .DATA_W(DATA_W)
   ) iob_universal_converter (
      // s_s port: Subordinate port
      .iob_valid_i (iob_valid_i),
      .iob_addr_i  (iob_addr_i),
      .iob_wdata_i (iob_wdata_i),
      .iob_wstrb_i (iob_wstrb_i),
      .iob_rvalid_o(iob_rvalid_o),
      .iob_rdata_o (iob_rdata_o),
      .iob_ready_o (iob_ready_o),
      // m_m port: Manager port
      .iob_valid_o (internal_iob_valid),
      .iob_addr_o  (internal_iob_addr),
      .iob_wdata_o (internal_iob_wdata),
      .iob_wstrb_o (internal_iob_wstrb),
      .iob_rvalid_i(internal_iob_rvalid),
      .iob_rdata_i (internal_iob_rdata),
      .iob_ready_i (internal_iob_ready)
   );

   // rvalid register
   iob_reg_ca #(
      .DATA_W (1),
      .RST_VAL(1'b0)
   ) rvalid_reg (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      // data_i port: Data input
      .data_i(iob_rvalid_nxt),
      // data_o port: Data output
      .data_o(iob_rvalid_out)
   );

   // rdata register
   iob_reg_ca #(
      .DATA_W (32),
      .RST_VAL(32'b0)
   ) rdata_reg (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      // data_i port: Data input
      .data_i(iob_rdata_nxt),
      // data_o port: Data output
      .data_o(iob_rdata_out)
   );

   // ready register
   iob_reg_ca #(
      .DATA_W (1),
      .RST_VAL(1'b0)
   ) ready_reg (
      // clk_en_rst_s port: Clock, clock enable and reset
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      // data_i port: Data input
      .data_i(iob_ready_nxt),
      // data_o port: Data output
      .data_o(iob_ready_out)
   );


endmodule
