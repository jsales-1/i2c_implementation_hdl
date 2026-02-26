//==================================================
// 1. I2C Interface (DUT ↔ testbench connection) - For Slave
//==================================================
interface i2c_if(input logic clk);
    // Control/interface signals with DUT (I2C Slave)
    logic                   rst;                    // Asynchronous reset (active high)
    logic [7:0]             data_received;          // Data received from master (write operation) 
    logic [7:0]             data_to_send;           // Data to transmit to master (read operation) 
    
    // I2C bus
    wire                    sda;                    // I2C data line
    wire                    scl;                    // I2C clock line
    
    // For testbench control (driving bidirectional signals as master)
    logic                   sda_drive_en;           // Enables SDA driver in TB (master mode)
    logic                   sda_out_tb;             // Value to drive on SDA by TB
    logic                   scl_drive_en;           // Enables SCL driver in TB (master mode)
    logic                   scl_out_tb;             // Value to drive on SCL by TB
    
    // Bidirectional signals connection with driver control
    // DUT (slave) drives when sda_drive_en = 0, TB (master) drives when sda_drive_en = 1
    assign sda = (sda_drive_en) ? sda_out_tb : 1'bz;
    assign scl = (scl_drive_en) ? scl_out_tb : 1'bz;
    
    // Initialization - APENAS para sinais dirigidos pelo TB
    initial begin
        rst = 1;
        data_to_send = 8'h00;  // OK - TB dirige este sinal
        sda_drive_en = 0;
        sda_out_tb = 1;
        scl_drive_en = 0;
        scl_out_tb = 1;
        
        // Release reset after some cycles
        #100;
        rst = 0;
    end
    
    // Task to simulate an I2C master (for testing the slave)
    task automatic i2c_master_model(input [6:0] dev_addr, input bit rw, 
                                    input [7:0] write_data, output bit [7:0] read_data,
                                    input bit gen_stop = 1);
        int i;
        
        // Generate START condition
        @(negedge scl);
        sda_drive_en = 1;
        sda_out_tb = 0;  // SDA low while SCL high = START
        @(posedge scl);
        @(negedge scl);
        
        // Send address (7 bits, MSB first)
        for(i=6; i>=0; i--) begin
            sda_out_tb = dev_addr[i];
            @(posedge scl);
            @(negedge scl);
        end
        
        // Send R/W bit
        sda_out_tb = rw;
        @(posedge scl);
        @(negedge scl);
        
        // Release SDA for slave ACK
        sda_drive_en = 0;
        @(posedge scl);
        // Check ACK (slave pulls SDA low)
        if (sda !== 0) begin
            $display("[%0t] I2C MASTER: No ACK from slave for address 0x%0h!", $time, dev_addr);
        end
        @(negedge scl);
        
        if (rw == 0) begin
            // Write operation: send data
            sda_drive_en = 1;
            
            for(i=7; i>=0; i--) begin
                sda_out_tb = write_data[i];
                @(posedge scl);
                @(negedge scl);
            end
            
            // Release SDA for slave ACK
            sda_drive_en = 0;
            @(posedge scl);
            if (sda !== 0) begin
                $display("[%0t] I2C MASTER: No ACK for data byte 0x%0h!", $time, write_data);
            end
            @(negedge scl);
        end
        else begin
            // Read operation: receive data
            sda_drive_en = 0;  // Release SDA for slave to drive
            read_data = 0;
            
            for(i=7; i>=0; i--) begin
                @(posedge scl);
                read_data[i] = sda;
                @(negedge scl);
            end
            
            // Send ACK
            sda_drive_en = 1;
            sda_out_tb = 0;  // ACK
            @(posedge scl);
            @(negedge scl);
            sda_drive_en = 0;
        end
        
        // Generate STOP condition if requested
        if (gen_stop) begin
            sda_drive_en = 1;
            sda_out_tb = 0;
            @(posedge scl);
            @(negedge scl);
            sda_out_tb = 1;  // SDA rising while SCL high = STOP
            @(posedge scl);
            @(negedge scl);
            sda_drive_en = 0;
        end
    endtask
    
    // Task to monitor the I2C bus
    task automatic monitor_i2c_bus();
        logic sda_last, scl_last;
        
        sda_last = sda;
        scl_last = scl;
        
        forever begin
            #1;
            // START detection: SDA falling while SCL high
            if(scl_last == 1 && scl == 1 && sda_last == 1 && sda == 0) begin
                $display("[%0t] I2C START condition detected", $time);
            end
            // STOP detection: SDA rising while SCL high
            if(scl_last == 1 && scl == 1 && sda_last == 0 && sda == 1) begin
                $display("[%0t] I2C STOP condition detected", $time);
            end
            
            sda_last = sda;
            scl_last = scl;
        end
    endtask
    
endinterface : i2c_if