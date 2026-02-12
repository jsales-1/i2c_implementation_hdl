`timescale 1ns / 10ps

// ============================================================================
// Testbench: i2c_multi_slave_tb
// Objetivo: Simular 1 master comunicando com 2 slaves no mesmo barramento
// ============================================================================

module i2c_multi_slave_tb;

    // ============================
    // Sinais do Master
    // ============================
    logic clk;
    logic rst;
    logic [6:0] address;
    logic [7:0] master_data_in;
    logic enable;
    logic rw;
    logic [7:0] master_data_out;
    logic ready;

    // ============================
    // Dados Slaves
    // ============================
    logic [7:0] slave0_data_to_send;
    logic [7:0] slave0_data_received;

    logic [7:0] slave1_data_to_send;
    logic [7:0] slave1_data_received;

    // ============================
    // Barramento I2C compartilhado
    // ============================
    tri sda;
    tri scl;

    // Pullups (opcional se seu slave já implementa open-drain)
    pullup (sda);
    pullup (scl);

    // ============================
    // Instância Master
    // ============================
    i2c_master_controller master (
        .clk      (clk),
        .rst      (rst),
        .address  (address),
        .data_in  (master_data_in),
        .enable   (enable),
        .rw       (rw),
        .data_out (master_data_out),
        .ready    (ready),
        .i2c_sda  (sda),
        .i2c_scl  (scl)
    );

    // ============================
    // Instância Slave 0
    // ============================
    i2c_slave_controller #(
        .SLAVE_ADDR(7'b0101010)
    ) slave0 (
        .rst           (rst),
        .sda           (sda),
        .scl           (scl),
        .data_received (slave0_data_received),
        .data_to_send  (slave0_data_to_send)
    );

    // ============================
    // Instância Slave 1
    // ============================
    i2c_slave_controller #(
        .SLAVE_ADDR(7'b0110011)
    ) slave1 (
        .rst           (rst),
        .sda           (sda),
        .scl           (scl),
        .data_received (slave1_data_received),
        .data_to_send  (slave1_data_to_send)
    );

    // ============================
    // Clock
    // ============================
    initial begin
        clk = 0;
        forever #1 clk = ~clk;   // período 2ns
    end

    // ============================
    // Testes
    // ============================
    initial begin

        $dumpfile("waveform.vcd");
        $dumpvars(0, i2c_multi_slave_tb);

        rst = 1;
        enable = 0;
        rw = 0;
        address = 0;
        master_data_in = 0;
        slave0_data_to_send = 0;
        slave1_data_to_send = 0;

        #20;
        rst = 0;

        // ============================================================
        // TESTE 1 — Escrita no Slave 0
        // ============================================================
        address = 7'b0101010;
        master_data_in = 8'hA5;
        rw = 0;
        enable = 1;
        #10 enable = 0;

        #400;

        if (slave0_data_received == 8'hA5)
            $display("OK: Slave0 recebeu corretamente %h", slave0_data_received);
        else
            $display("ERRO: Slave0 recebeu %h", slave0_data_received);

        // ============================================================
        // TESTE 2 — Escrita no Slave 1
        // ============================================================
        address = 7'b0110011;
        master_data_in = 8'h3C;
        rw = 0;
        enable = 1;
        #10 enable = 0;

        #400;

        if (slave1_data_received == 8'h3C)
            $display("OK: Slave1 recebeu corretamente %h", slave1_data_received);
        else
            $display("ERRO: Slave1 recebeu %h", slave1_data_received);

        // ============================================================
        // TESTE 3 — Leitura do Slave 0
        // ============================================================
        address = 7'b0101010;
        slave0_data_to_send = 8'hF0;
        rw = 1;
        enable = 1;
        #10 enable = 0;

        #600;

        if (master_data_out == 8'hF0)
            $display("OK: Master leu corretamente de Slave0: %h", master_data_out);
        else
            $display("ERRO: Master leu %h do Slave0", master_data_out);

        // ============================================================
        // TESTE 4 — Leitura do Slave 1
        // ============================================================
        address = 7'b0110011;
        slave1_data_to_send = 8'h55;
        rw = 1;
        enable = 1;
        #10 enable = 0;

        #600;

        if (master_data_out == 8'h55)
            $display("OK: Master leu corretamente de Slave1: %h", master_data_out);
        else
            $display("ERRO: Master leu %h do Slave1", master_data_out);

        $display("==== FIM DA SIMULACAO ====");
        $finish;
    end

endmodule
