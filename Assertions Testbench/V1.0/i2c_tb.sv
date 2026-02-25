
module i2c_multi_slave_tb;

    
    // Master
    
    logic clk;
    logic rst;
    logic [6:0] address;
    logic [7:0] master_data_in;
    logic enable;
    logic rw;
    logic [7:0] master_data_out;
    logic ready;

    
    // Slaves
    
    logic [7:0] slave0_data_to_send;
    logic [7:0] slave0_data_received;

    logic [7:0] slave1_data_to_send;
    logic [7:0] slave1_data_received;

    logic [7:0] slave2_data_to_send;
    logic [7:0] slave2_data_received;

    
    // Barramento I2C
    
    tri sda;
    tri scl;

    pullup (sda);
    pullup (scl);

    
    // Master
    
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

    
    // Slaves
    
    i2c_slave_controller #(.SLAVE_ADDR(7'b0101010)) slave0 (
        .rst(rst), .sda(sda), .scl(scl),
        .data_received(slave0_data_received),
        .data_to_send(slave0_data_to_send)
    );

    i2c_slave_controller #(.SLAVE_ADDR(7'b0110011)) slave1 (
        .rst(rst), .sda(sda), .scl(scl),
        .data_received(slave1_data_received),
        .data_to_send(slave1_data_to_send)
    );

    i2c_slave_controller #(.SLAVE_ADDR(7'b0011101)) slave2 (
        .rst(rst), .sda(sda), .scl(scl),
        .data_received(slave2_data_received),
        .data_to_send(slave2_data_to_send)
    );

    
    // Clock
    
    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    
    // Testes
    
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
        slave2_data_to_send = 0;

        #20 rst = 0;

        
        // WRITE SLAVE 0
        
        address = 7'b0101010;
        master_data_in = 8'hA5;
        rw = 0;
        enable = 1; #10 enable = 0;
        #400;

        if (slave0_data_received == 8'hA5)
            $display("OK WRITE: Slave0 recebeu %h", slave0_data_received);
        else
            $display("ERRO WRITE: Slave0 recebeu %h", slave0_data_received);

        
        // WRITE SLAVE 1
        
        address = 7'b0110011;
        master_data_in = 8'h3C;
        rw = 0;
        enable = 1; #10 enable = 0;
        #400;

        if (slave1_data_received == 8'h3C)
            $display("OK WRITE: Slave1 recebeu %h", slave1_data_received);
        else
            $display("ERRO WRITE: Slave1 recebeu %h", slave1_data_received);

        
        // WRITE SLAVE 2
        
        address = 7'b0011101;
        master_data_in = 8'h77;
        rw = 0;
        enable = 1; #10 enable = 0;
        #400;

        if (slave2_data_received == 8'h77)
            $display("OK WRITE: Slave2 recebeu %h", slave2_data_received);
        else
            $display("ERRO WRITE: Slave2 recebeu %h", slave2_data_received);

        
        // READ SLAVE 0
        
        slave0_data_to_send = 8'hF0;
        address = 7'b0101010;
        rw = 1;
        enable = 1; #10 enable = 0;
        #600;

        if (master_data_out == 8'hF0)
            $display("OK READ: Master leu %h do Slave0", master_data_out);
        else
            $display("ERRO READ: Master leu %h do Slave0", master_data_out);

        
        // READ SLAVE 1
        
        slave1_data_to_send = 8'h55;
        address = 7'b0110011;
        rw = 1;
        enable = 1; #10 enable = 0;
        #600;

        if (master_data_out == 8'h55)
            $display("OK READ: Master leu %h do Slave1", master_data_out);
        else
            $display("ERRO READ: Master leu %h do Slave1", master_data_out);

        
        // READ SLAVE 2
        
        slave2_data_to_send = 8'h99;
        address = 7'b0011101;
        rw = 1;
        enable = 1; #10 enable = 0;
        #600;

        if (master_data_out == 8'h99)
            $display("OK READ: Master leu %h do Slave2", master_data_out);
        else
            $display("ERRO READ: Master leu %h do Slave2", master_data_out);

        $display("==== FIM DA SIMULACAO ====");
        $finish;
    end
  
// I2C Assertions Monitor

bind i2c_master_controller
    i2c_master_assertions master_chk (
        .clk(clk),
        .rst(rst),
        .ready(ready),
        .enable(enable),
        .scl(i2c_scl),
        .sda(i2c_sda),
        .state(state)
    );


bind i2c_slave_controller
    i2c_slave_assertions slave_chk (
        .rst(rst),
        .scl(scl),
        .sda(sda),
        .sda_drive_en(sda_drive_en)
    );

endmodule

