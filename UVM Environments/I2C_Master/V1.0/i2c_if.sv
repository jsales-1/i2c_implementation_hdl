//==================================================
// 1. I2C Interface (DUT ↔ testbench connection)
//==================================================
interface i2c_if(input logic clk);
    // Control/interface signals with DUT
    logic                   rst;           // Synchronous reset (active high)
    logic [6:0]             address;       // I2C device address (7 bits)
    logic [7:0]             data_in;       // Data to be written
    logic                   enable;        // Enable transaction
    logic                   rw;            // Operation (0 = write, 1 = read)
    logic [7:0]             data_out;      // Read data (read operation)
    logic                   ready;         // Ready for new operation
    
    // I2C bus (bidirectional - needs tristate in testbench too)
    wire                    i2c_sda;       // I2C data line
    wire                    i2c_scl;       // I2C clock line
    
    // For testbench control (driving bidirectional signals)
    logic                   sda_drive_en;  // Enables SDA driver in TB
    logic                   sda_out_tb;    // Value to drive on SDA by TB
    logic                   scl_drive_en;  // Enables SCL driver in TB
    logic                   scl_out_tb;    // Value to drive on SCL by TB
    
    // Bidirectional signals connection with driver control
    // DUT drives when sda_drive_en = 0, TB drives when sda_drive_en = 1
    assign i2c_sda = (sda_drive_en) ? sda_out_tb : 1'bz;
    assign i2c_scl = (scl_drive_en) ? scl_out_tb : 1'bz;
    
    // Initialization
    initial begin
        rst = 1;
        address = 7'h00;
        data_in = 8'h00;
        enable = 0;
        rw = 0;
        sda_drive_en = 0;
        sda_out_tb = 1;
        scl_drive_en = 0;
        scl_out_tb = 1;
        
        // Release reset after some cycles
        #100;
        rst = 0;
    end
    
    // Task to simulate an I2C slave (useful for basic tests)
    task automatic i2c_slave_model();
        logic [6:0] received_addr;
        logic       received_rw;
        logic [7:0] memory[256];  // Simple memory to simulate slave
        logic [7:0] read_data;
        int i;
        
        // Initialize memory with some values
        for(i=0; i<256; i++) memory[i] = i;
        
        forever begin
            @(posedge i2c_scl);
            
            // Detect START (SDA goes 1->0 while SCL=1)
            // Since detection is complex, let's simplify: when enable=1
            if(enable) begin
                // Slave mode: will receive address
                received_addr = 0;
                for(i=6; i>=0; i--) begin
                    @(posedge i2c_scl);
                    received_addr[i] = i2c_sda;
                end
                
                // R/W bit
                @(posedge i2c_scl);
                received_rw = i2c_sda;
                
                // Slave ACK
                @(negedge i2c_scl);
                sda_drive_en = 1;
                sda_out_tb = 0;  // ACK
                @(posedge i2c_scl);
                @(negedge i2c_scl);
                sda_drive_en = 0;
                
                if(received_rw == 0) begin
                    // WRITE: receive data
                    for(i=7; i>=0; i--) begin
                        @(posedge i2c_scl);
                        memory[received_addr][i] = i2c_sda;
                    end
                    
                    // Slave ACK
                    @(negedge i2c_scl);
                    sda_drive_en = 1;
                    sda_out_tb = 0;  // ACK
                    @(posedge i2c_scl);
                    @(negedge i2c_scl);
                    sda_drive_en = 0;
                end
                else begin
                    // READ: send data
                    read_data = memory[received_addr];
                    for(i=7; i>=0; i--) begin
                        @(negedge i2c_scl);
                        sda_drive_en = 1;
                        sda_out_tb = read_data[i];
                        @(posedge i2c_scl);
                    end
                    @(negedge i2c_scl);
                    sda_drive_en = 0;
                    
                    // Wait for master ACK/NACK
                    @(posedge i2c_scl);
                    if(i2c_sda == 0) begin
                        // Master ACK, could continue, but we'll stop
                    end
                end
            end
        end
    endtask
    
    // Task to monitor the I2C bus
    task automatic monitor_i2c_bus();
        logic sda_last, scl_last;
        logic start_detected, stop_detected;
        
        sda_last = i2c_sda;
        scl_last = i2c_scl;
        
        forever begin
            #1;
            // START detection: SDA falling while SCL high
            if(scl_last == 1 && i2c_scl == 1 && sda_last == 1 && i2c_sda == 0) begin
                $display("[%0t] I2C START condition detected", $time);
            end
            // STOP detection: SDA rising while SCL high
            if(scl_last == 1 && i2c_scl == 1 && sda_last == 0 && i2c_sda == 1) begin
                $display("[%0t] I2C STOP condition detected", $time);
            end
            
            sda_last = i2c_sda;
            scl_last = i2c_scl;
        end
    endtask
    
endinterface 