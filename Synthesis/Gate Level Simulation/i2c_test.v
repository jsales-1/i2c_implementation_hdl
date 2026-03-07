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
        .rst(rst), .sda(sda), .scl(scl),
        .data_received(slave0_data_received),
        .data_to_send(slave0_data_to_send)
    );
	
	// Incluir SDF Annotate
	`ifdef SDF_TEST
	initial
	begin
	$sdf_annotate("slave_delays.sdf", i2c_teste.slave0,"sdf.log","MAXIMUM");
	end
	`endif

	// Incluir SDF Annotate
	`ifdef SDF_TEST1
	initial
	begin
	$sdf_annotate("master_delays.sdf", i2c_teste.master,"sdf2.log","MAXIMUM");
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
    initial begin

        $dumpfile("waveform.vcd");
        $dumpvars(0, i2c_multi_slave_tb);

        rst = 1;
        enable = 0;
        rw = 0;
        address = 0;
        master_data_in = 0;

        slave0_data_to_send = 0;

        #20 rst = 0;

        // ============================================================
        // WRITE SLAVE 0
        // ============================================================
        address = 7'b0101010;
        master_data_in = 8'hA5;
        rw = 0;
        enable = 1; #10 enable = 0;
        #400;

        if (slave0_data_received == 8'hA5)
            $display("OK WRITE: Slave0 recebeu %h", slave0_data_received);
        else
            $display("ERRO WRITE: Slave0 recebeu %h", slave0_data_received);

      

        // ============================================================
        // READ SLAVE 0
        // ============================================================
        slave0_data_to_send = 8'hF0;
        address = 7'b0101010;
        rw = 1;
        enable = 1; #10 enable = 0;
        #600;

        if (master_data_out == 8'hF0)
            $display("OK READ: Master leu %h do Slave0", master_data_out);
        else
            $display("ERRO READ: Master leu %h do Slave0", master_data_out);



        $display("==== FIM DA SIMULACAO ====");
        $finish;
    end

endmodule
