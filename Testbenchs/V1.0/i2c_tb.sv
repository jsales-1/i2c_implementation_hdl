`timescale 1ns / 10ps

// ============================================================================
// Testbench: i2c_controller_tb
// Objetivo: Simular a comunicação entre o módulo master e o módulo slave I2C
// ============================================================================

module i2c_controller_tb;

    // -------------------------------
    // Entradas e saídas do master
    // -------------------------------
    logic clk;
    logic rst;
    logic [6:0] address;
    logic [7:0] master_data_in;
    logic enable;
    logic rw;
    logic [7:0] master_data_out;
    logic ready;

    // -------------------------------
    // Dados do slave
    // -------------------------------
    logic [7:0] slave_data_to_send;
    logic [7:0] slave_data_received;

    // -------------------------------
    // Barramento I2C (bidirecional)
    // -------------------------------
    tri sda;
    tri scl;

    // Pull-ups do barramento I2C
    //pullup (sda);
    //pullup (scl);

    // -------------------------------
    // Instanciação do master (UUT)
    // -------------------------------
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

    // -------------------------------
    // Instanciação do slave
    // -------------------------------
    i2c_slave_controller slave (
        .rst           (rst),
        .sda           (sda),
        .scl           (scl),
        .data_received (slave_data_received),
        .data_to_send  (slave_data_to_send)
    );

    // -------------------------------
    // Geração do Clock do Sistema
    // -------------------------------
    initial begin
        clk = 0;
        forever #1 clk = ~clk;   // Clock com período de 2ns
    end

    // -------------------------------
    // Estímulos da Simulação
    // -------------------------------
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, i2c_controller_tb);

        // Inicialização
        rst = 1;
        enable = 0;
        rw = 0;
        address = '0;
        master_data_in = '0;
        slave_data_to_send = '0;

        $display("[%0t ns] Sistema inicializado em RESET.", $time);
        #10;
        rst = 0;
        $display("[%0t ns] RESET finalizado, iniciando testes.", $time);

        // -------------------------------
        // Teste 1: Escrita no slave
        // -------------------------------
        address = 7'b0101010;
        master_data_in = 8'b10101010;
        rw = 0;              // Escrita
        enable = 1;

        $display("[%0t ns] master iniciando escrita no slave (endereço=%b, dado=%b)",
                 $time, address, master_data_in);

        #10;
        enable = 0;

        // Aguarda transação completar
        #300;

        if (slave_data_received == master_data_in)
            $display("[%0t ns] Escrita concluída: slave recebeu corretamente o dado %b.",
                     $time, slave_data_received);
        else
            $display("[%0t ns] ERRO: slave recebeu %b, esperado %b.",
                     $time, slave_data_received, master_data_in);

        // -------------------------------
        // Reset entre testes
        // -------------------------------
        rst = 1;
        #50;
        rst = 0;
        $display("[%0t ns] Sistema reiniciado para o próximo teste.", $time);

        // -------------------------------
        // Teste 2: Leitura do slave
        // -------------------------------
        address = 7'b0101010;
        slave_data_to_send = 8'b11101010;
        rw = 1;              // Leitura
        enable = 1;

        $display("[%0t ns] master requisitando leitura do slave (endereço=%b). slave enviará %b.",
                 $time, address, slave_data_to_send);

        #10;
        enable = 0;

        // Aguarda leitura completar
        #500;

        if (master_data_out == slave_data_to_send)
            $display("[%0t ns] Leitura concluída: master recebeu corretamente o dado %b.",
                     $time, master_data_out);
        else
            $display("[%0t ns] ERRO: master recebeu %b, esperado %b.",
                     $time, master_data_out, slave_data_to_send);

        // -------------------------------
        // Finaliza Simulação
        // -------------------------------
        $display("[%0t ns] ==== Fim da Simulação ====", $time);
        $finish;
    end

endmodule
