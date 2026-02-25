// SPDX-FileCopyrightText: 2026 IObundle, Lda
//
// SPDX-License-Identifier: MIT
//
// Py2HWSW Version 0.81.0 has generated this code (https://github.com/IObundle/py2hwsw).

`timescale 1ns / 1ps
`include "iob_uut_conf.vh"

module iob_uut #(
    parameter ADDR_W = `IOB_UUT_ADDR_W,
    parameter DATA_W = `IOB_UUT_DATA_W
) (
    // clk_en_rst_s: Clock, clock enable and reset
    input clk_i,
    input cke_i,
    input arst_i,
    // pbus_s: Testbench UART16550 sim wrapper csrs interface
    input iob_valid_i,
    input [6-1:0] iob_addr_i,
    input [32-1:0] iob_wdata_i,
    input [32/8-1:0] iob_wstrb_i,
    output iob_rvalid_o,
    output [32-1:0] iob_rdata_o,
    output iob_ready_o
);

// uart16550 #0 CSRs interface
    wire uart16550_0_csrs_iob_valid;
    wire [5-1:0] uart16550_0_csrs_iob_addr;
    wire [32-1:0] uart16550_0_csrs_iob_wdata;
    wire [32/8-1:0] uart16550_0_csrs_iob_wstrb;
    wire uart16550_0_csrs_iob_rvalid;
    wire [32-1:0] uart16550_0_csrs_iob_rdata;
    wire uart16550_0_csrs_iob_ready;
// Testbench uart csrs bus
    wire internal_uart0_iob_valid;
    wire [5-1:0] internal_uart0_iob_addr;
    wire [32-1:0] internal_uart0_iob_wdata;
    wire [32/8-1:0] internal_uart0_iob_wstrb;
    wire internal_uart0_iob_rvalid;
    wire [32-1:0] internal_uart0_iob_rdata;
    wire internal_uart0_iob_ready;
// UART16550 #0 Interrupt signal
    wire uart16550_0_interrupt;
// uart16550 #0 RS232 interface
    wire uart0_rs232_rxd;
    wire uart0_rs232_txd;
    wire uart0_rs232_rts;
    wire uart0_rs232_cts;
// uart16550 #1 CSRs interface
    wire uart16550_1_csrs_iob_valid;
    wire [5-1:0] uart16550_1_csrs_iob_addr;
    wire [32-1:0] uart16550_1_csrs_iob_wdata;
    wire [32/8-1:0] uart16550_1_csrs_iob_wstrb;
    wire uart16550_1_csrs_iob_rvalid;
    wire [32-1:0] uart16550_1_csrs_iob_rdata;
    wire uart16550_1_csrs_iob_ready;
// Testbench uart csrs bus
    wire internal_uart1_iob_valid;
    wire [5-1:0] internal_uart1_iob_addr;
    wire [32-1:0] internal_uart1_iob_wdata;
    wire [32/8-1:0] internal_uart1_iob_wstrb;
    wire internal_uart1_iob_rvalid;
    wire [32-1:0] internal_uart1_iob_rdata;
    wire internal_uart1_iob_ready;
// UART16550 #1 Interrupt signal
    wire uart16550_1_interrupt;
// uart16550 #1 RS232 interface
    wire uart1_rs232_rxd;
    wire uart1_rs232_txd;
    wire uart1_rs232_rts;
    wire uart1_rs232_cts;


        assign uart1_rs232_rxd = uart0_rs232_txd;
        assign uart0_rs232_rxd = uart1_rs232_txd;
        assign uart0_rs232_cts = 1'b1;
        assign uart1_rs232_cts = 1'b1;
            

        // Convert IOb port from testbench into correct interface for UART CSRs bus
        iob_universal_converter_iob_iob #(
        .ADDR_W(5),
        .DATA_W(DATA_W)
    ) iob_universal_converter0 (
            // s_s port: Subordinate port
        .iob_valid_i(uart16550_0_csrs_iob_valid),
        .iob_addr_i(uart16550_0_csrs_iob_addr),
        .iob_wdata_i(uart16550_0_csrs_iob_wdata),
        .iob_wstrb_i(uart16550_0_csrs_iob_wstrb),
        .iob_rvalid_o(uart16550_0_csrs_iob_rvalid),
        .iob_rdata_o(uart16550_0_csrs_iob_rdata),
        .iob_ready_o(uart16550_0_csrs_iob_ready),
        // m_m port: Manager port
        .iob_valid_o(internal_uart0_iob_valid),
        .iob_addr_o(internal_uart0_iob_addr),
        .iob_wdata_o(internal_uart0_iob_wdata),
        .iob_wstrb_o(internal_uart0_iob_wstrb),
        .iob_rvalid_i(internal_uart0_iob_rvalid),
        .iob_rdata_i(internal_uart0_iob_rdata),
        .iob_ready_i(internal_uart0_iob_ready)
        );

            // Unit Under Test (UUT) UART16550 instance 0.
        iob_uart16550 uart16550_inst0 (
            // clk_en_rst_s port: Clock, clock enable and reset
        .clk_i(clk_i),
        .cke_i(cke_i),
        .arst_i(arst_i),
        // csrs_cbus_s port: Control and status interface, when selecting the IOb CSR interface.
        .iob_valid_i(internal_uart0_iob_valid),
        .iob_addr_i(internal_uart0_iob_addr),
        .iob_wdata_i(internal_uart0_iob_wdata),
        .iob_wstrb_i(internal_uart0_iob_wstrb),
        .iob_rvalid_o(internal_uart0_iob_rvalid),
        .iob_rdata_o(internal_uart0_iob_rdata),
        .iob_ready_o(internal_uart0_iob_ready),
        // rs232_m port: RS232 interface
        .rs232_rxd_i(uart0_rs232_rxd),
        .rs232_txd_o(uart0_rs232_txd),
        .rs232_rts_o(uart0_rs232_rts),
        .rs232_cts_i(uart0_rs232_cts),
        // interrupt_o port: UART16550 interrupt related signals
        .interrupt_o(uart16550_0_interrupt)
        );

            // Convert IOb port from testbench into correct interface for UART CSRs bus
        iob_universal_converter_iob_iob #(
        .ADDR_W(5),
        .DATA_W(DATA_W)
    ) iob_universal_converter1 (
            // s_s port: Subordinate port
        .iob_valid_i(uart16550_1_csrs_iob_valid),
        .iob_addr_i(uart16550_1_csrs_iob_addr),
        .iob_wdata_i(uart16550_1_csrs_iob_wdata),
        .iob_wstrb_i(uart16550_1_csrs_iob_wstrb),
        .iob_rvalid_o(uart16550_1_csrs_iob_rvalid),
        .iob_rdata_o(uart16550_1_csrs_iob_rdata),
        .iob_ready_o(uart16550_1_csrs_iob_ready),
        // m_m port: Manager port
        .iob_valid_o(internal_uart1_iob_valid),
        .iob_addr_o(internal_uart1_iob_addr),
        .iob_wdata_o(internal_uart1_iob_wdata),
        .iob_wstrb_o(internal_uart1_iob_wstrb),
        .iob_rvalid_i(internal_uart1_iob_rvalid),
        .iob_rdata_i(internal_uart1_iob_rdata),
        .iob_ready_i(internal_uart1_iob_ready)
        );

            // Unit Under Test (UUT) UART16550 instance 1.
        iob_uart16550 uart16550_inst1 (
            // clk_en_rst_s port: Clock, clock enable and reset
        .clk_i(clk_i),
        .cke_i(cke_i),
        .arst_i(arst_i),
        // csrs_cbus_s port: Control and status interface, when selecting the IOb CSR interface.
        .iob_valid_i(internal_uart1_iob_valid),
        .iob_addr_i(internal_uart1_iob_addr),
        .iob_wdata_i(internal_uart1_iob_wdata),
        .iob_wstrb_i(internal_uart1_iob_wstrb),
        .iob_rvalid_o(internal_uart1_iob_rvalid),
        .iob_rdata_o(internal_uart1_iob_rdata),
        .iob_ready_o(internal_uart1_iob_ready),
        // rs232_m port: RS232 interface
        .rs232_rxd_i(uart1_rs232_rxd),
        .rs232_txd_o(uart1_rs232_txd),
        .rs232_rts_o(uart1_rs232_rts),
        .rs232_cts_i(uart1_rs232_cts),
        // interrupt_o port: UART16550 interrupt related signals
        .interrupt_o(uart16550_1_interrupt)
        );

            // Split between testbench peripherals
        tb_pbus_split iob_pbus_split (
            // clk_en_rst_s port: Clock, clock enable and async reset
        .clk_i(clk_i),
        .cke_i(cke_i),
        .arst_i(arst_i),
        // reset_i port: Reset signal
        .rst_i(arst_i),
        // s_s port: Split subordinate interface
        .s_iob_valid_i(iob_valid_i),
        .s_iob_addr_i(iob_addr_i),
        .s_iob_wdata_i(iob_wdata_i),
        .s_iob_wstrb_i(iob_wstrb_i),
        .s_iob_rvalid_o(iob_rvalid_o),
        .s_iob_rdata_o(iob_rdata_o),
        .s_iob_ready_o(iob_ready_o),
        // m_0_m port: Split manager interface
        .m0_iob_valid_o(uart16550_0_csrs_iob_valid),
        .m0_iob_addr_o(uart16550_0_csrs_iob_addr),
        .m0_iob_wdata_o(uart16550_0_csrs_iob_wdata),
        .m0_iob_wstrb_o(uart16550_0_csrs_iob_wstrb),
        .m0_iob_rvalid_i(uart16550_0_csrs_iob_rvalid),
        .m0_iob_rdata_i(uart16550_0_csrs_iob_rdata),
        .m0_iob_ready_i(uart16550_0_csrs_iob_ready),
        // m_1_m port: Split manager interface
        .m1_iob_valid_o(uart16550_1_csrs_iob_valid),
        .m1_iob_addr_o(uart16550_1_csrs_iob_addr),
        .m1_iob_wdata_o(uart16550_1_csrs_iob_wdata),
        .m1_iob_wstrb_o(uart16550_1_csrs_iob_wstrb),
        .m1_iob_rvalid_i(uart16550_1_csrs_iob_rvalid),
        .m1_iob_rdata_i(uart16550_1_csrs_iob_rdata),
        .m1_iob_ready_i(uart16550_1_csrs_iob_ready)
        );

    
endmodule
