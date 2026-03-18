`timescale 1ns / 10ps

module i2c_multi_slave_tb;

    // ============================
    // Master
    // ============================
    reg clk;
    reg rst;
    reg [6:0] address;
    reg [7:0] master_data_in;
    reg enable;
    reg rw;
    wire [7:0] master_data_out;
    wire ready;

    // ============================
    // Slaves
    // ============================
    wire [7:0] slave0_data_received;
    reg [7:0] slave0_data_to_send;
    
    wire [7:0] slave1_data_received;
    reg [7:0] slave1_data_to_send;

    // ============================
    // Barramento I2C
    // ============================
    tri sda;
    tri scl;

    pullup (sda);
    pullup (scl);

    // ============================
    // Master
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
    // Slaves
    // ============================
    i2c_slave_controller slave0 (
        .rst(rst), 
        .sda(sda), 
        .scl(scl),
        .data_received(slave0_data_received),
        .data_to_send(slave0_data_to_send)
    );

    i2c_slave_controller_h32 slave1 (
        .rst(rst), 
        .sda(sda), 
        .scl(scl),
        .data_received(slave1_data_received),
        .data_to_send(slave1_data_to_send)
    );
	
    // Incluir SDF Annotate para Slave0
    `ifdef SDF_TEST
    initial
    begin
        $sdf_annotate("slave_delays.sdf", i2c_multi_slave_tb.slave0, "sdf.log", "MAXIMUM");
    end
    `endif

    // Incluir SDF Annotate para Slave1
    `ifdef SDF_TEST1
    initial
    begin
        $sdf_annotate("slave_delays.sdf", i2c_multi_slave_tb.slave1, "sdf2.log", "MAXIMUM");
    end
    `endif

    // Incluir SDF Annotate para Master
    `ifdef SDF_TEST2
    initial
    begin
        $sdf_annotate("master_delays.sdf", i2c_multi_slave_tb.master, "sdf3.log", "MAXIMUM");
    end
    `endif

    // ============================
    // Clock
    // ============================
    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    // ============================
    // Testes
    // ============================
    integer i;
    
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, i2c_multi_slave_tb);

        // Inicialização
        rst = 1;
        enable = 0;
        rw = 0;
        address = 0;
        master_data_in = 0;

        slave0_data_to_send = 0;
        slave1_data_to_send = 0;

        #20 rst = 0;
        #100;

        $display("========================================");
        $display("INICIANDO TESTES COM MULTIPLOS SLAVES");
        $display("========================================");
        $display("Slave 0 Address: 7'b0101010 (0x2A)");
        $display("Slave 1 Address: 7'b0110010 (0x32)");
        $display("========================================\n");

        // ============================================================
        // TESTE 1: 2 WRITES NO SLAVE 0
        // ============================================================
        $display("--- TESTE 1: 2 WRITES NO SLAVE 0 (0x2A) ---");
        
        // Write 1 no Slave 0
        address = 7'b0101010;  // Endereço do Slave 0 (0x2A)
        master_data_in = 8'hA5;
        rw = 0;
        enable = 1; #10 enable = 0;
        #400;
        
        if (slave0_data_received == 8'hA5)
            $display("  OK WRITE 1: Slave0 recebeu %h", slave0_data_received);
        else
            $display("  ERRO WRITE 1: Slave0 recebeu %h (esperado A5)", slave0_data_received);
        
        #100;
        
        // Write 2 no Slave 0
        master_data_in = 8'h3C;
        enable = 1; #10 enable = 0;
        #400;
        
        if (slave0_data_received == 8'h3C)
            $display("  OK WRITE 2: Slave0 recebeu %h", slave0_data_received);
        else
            $display("  ERRO WRITE 2: Slave0 recebeu %h (esperado 3C)", slave0_data_received);
        
        #200;

        // ============================================================
        // TESTE 2: 2 WRITES NO SLAVE 1
        // ============================================================
        $display("\n--- TESTE 2: 2 WRITES NO SLAVE 1 (0x32) ---");
        
        // Write 1 no Slave 1
        address = 7'b0110010;  // Endereço do Slave 1 (0x32)
        master_data_in = 8'hB6;
        rw = 0;
        enable = 1; #10 enable = 0;
        #400;
        
        if (slave1_data_received == 8'hB6)
            $display("  OK WRITE 1: Slave1 recebeu %h", slave1_data_received);
        else
            $display("  ERRO WRITE 1: Slave1 recebeu %h (esperado B6)", slave1_data_received);
        
        #100;
        
        // Write 2 no Slave 1
        master_data_in = 8'hD7;
        enable = 1; #10 enable = 0;
        #400;
        
        if (slave1_data_received == 8'hD7)
            $display("  OK WRITE 2: Slave1 recebeu %h", slave1_data_received);
        else
            $display("  ERRO WRITE 2: Slave1 recebeu %h (esperado D7)", slave1_data_received);
        
        #200;

        // ============================================================
        // TESTE 3: 2 READS NO SLAVE 0
        // ============================================================
        $display("\n--- TESTE 3: 2 READS NO SLAVE 0 (0x2A) ---");
        
        // Preparar dados para leitura do Slave 0
        slave0_data_to_send = 8'hF0;
        
        // Read 1 do Slave 0
        address = 7'b0101010;
        rw = 1;
        enable = 1; #10 enable = 0;
        #600;
        
        if (master_data_out == 8'hF0)
            $display("  OK READ 1: Master leu %h do Slave0", master_data_out);
        else
            $display("  ERRO READ 1: Master leu %h do Slave0 (esperado F0)", master_data_out);
        
        #100;
        
        // Preparar novo dado para leitura do Slave 0
        slave0_data_to_send = 8'h1A;
        
        // Read 2 do Slave 0
        enable = 1; #10 enable = 0;
        #600;
        
        if (master_data_out == 8'h1A)
            $display("  OK READ 2: Master leu %h do Slave0", master_data_out);
        else
            $display("  ERRO READ 2: Master leu %h do Slave0 (esperado 1A)", master_data_out);
        
        #200;

        // ============================================================
        // TESTE 4: 2 READS NO SLAVE 1
        // ============================================================
        $display("\n--- TESTE 4: 2 READS NO SLAVE 1 (0x32) ---");
        
        // Preparar dados para leitura do Slave 1
        slave1_data_to_send = 8'h4E;
        
        // Read 1 do Slave 1
        address = 7'b0110010;
        rw = 1;
        enable = 1; #10 enable = 0;
        #600;
        
        if (master_data_out == 8'h4E)
            $display("  OK READ 1: Master leu %h do Slave1", master_data_out);
        else
            $display("  ERRO READ 1: Master leu %h do Slave1 (esperado 4E)", master_data_out);
        
        #100;
        
        // Preparar novo dado para leitura do Slave 1
        slave1_data_to_send = 8'h93;
        
        // Read 2 do Slave 1
        enable = 1; #10 enable = 0;
        #600;
        
        if (master_data_out == 8'h93)
            $display("  OK READ 2: Master leu %h do Slave1", master_data_out);
        else
            $display("  ERRO READ 2: Master leu %h do Slave1 (esperado 93)", master_data_out);
        
        #200;

        $display("==== FIM DA SIMULACAO ====");
        
        $finish;
    end

endmodule
