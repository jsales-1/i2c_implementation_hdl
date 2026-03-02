// Testbench for I2C Multi-Slave Communication
module i2c_multi_slave_tb;

    
    // Master Interface Signals
    logic clk;
    logic rst;
    logic [6:0] address;       // Slave address
    logic [7:0] master_data_in; // Data to be written to slave
    logic enable;               // Start operation
    logic rw;                   // Read/Write control (0=write, 1=read)
    logic [7:0] master_data_out; // Data read from slave
    logic ready;                // Master ready signal

    
    // Slave Interface Signals
    logic [7:0] slave0_data_to_send;   // Data slave0 will send on read
    logic [7:0] slave0_data_received;  // Data slave0 received on write

    logic [7:0] slave1_data_to_send;   // Data slave1 will send on read
    logic [7:0] slave1_data_received;  // Data slave1 received on write

    logic [7:0] slave2_data_to_send;   // Data slave2 will send on read
    logic [7:0] slave2_data_received;  // Data slave2 received on write

    
    // I2C Bus Signals (tri-state)
    tri sda;  // Serial Data Line
    tri scl;  // Serial Clock Line

    // Pull-up resistors for I2C bus (open-drain requires pull-ups)
    pullup (sda);
    pullup (scl);

    
    // Master Instantiation
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

    
    // Slaves Instantiation with different addresses
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

        // ENUMERATED TYPE DEFINITIONS FOR FSM STATES
        
    // Master States (based on i2c_master_controller)
    typedef enum logic [3:0] {
        IDLE      = 4'd0,  // Idle state
        START     = 4'd1,  // Generate START condition
        WAIT_S    = 4'd2,  // Wait for SCL low after START
        ADDRESS   = 4'd3,  // Transmit address + R/W bit
        READ_ACK  = 4'd4,  // Read ACK/NACK after address
        WRITE_DATA = 4'd5, // Write data to slave
        READ_ACK2 = 4'd6,  // Read ACK/NACK after data write
        READ_DATA = 4'd7,  // Read data from slave
        WRITE_ACK = 4'd8,  // Write ACK after data read
        STOP      = 4'd9   // Generate STOP condition
    } master_state_t;
    
    // Slave States (based on i2c_slave_controller)
    typedef enum logic [2:0] {
        SLAVE_IDLE        = 3'd0,  // Idle state
        SLAVE_READ_ADDR   = 3'd1,  // Reading address from master
        SLAVE_SEND_ACK    = 3'd2,  // Sending ACK after address match
        SLAVE_READ_DATA   = 3'd3,  // Reading data from master (write operation)
        SLAVE_SEND_ACK2   = 3'd4,  // Sending ACK after data reception
        SLAVE_WRITE_DATA  = 3'd5   // Writing data to bus (read operation)
    } slave_state_t;
    
        // COVERGROUP VARIABLES (copies of signals for coverage)
        
    logic [7:0] slave0_rec_cg;   // Copy of slave0 received data
    logic [7:0] slave0_send_cg;  // Copy of slave0 data to send
    logic [7:0] slave1_rec_cg;   // Copy of slave1 received data
    logic [7:0] slave1_send_cg;  // Copy of slave1 data to send
    logic [7:0] slave2_rec_cg;   // Copy of slave2 received data
    logic [7:0] slave2_send_cg;  // Copy of slave2 data to send
    
    // Update covergroup variables on each change
    always @(slave0_data_received) slave0_rec_cg = slave0_data_received;
    always @(slave0_data_to_send) slave0_send_cg = slave0_data_to_send;
    always @(slave1_data_received) slave1_rec_cg = slave1_data_received;
    always @(slave1_data_to_send) slave1_send_cg = slave1_data_to_send;
    always @(slave2_data_received) slave2_rec_cg = slave2_data_received;
    always @(slave2_data_to_send) slave2_send_cg = slave2_data_to_send;
    
        // SLAVE STATE SIGNALS FOR COVERAGE
        
    logic [2:0] slave0_state_cg;  // Copy of slave0 state
    logic [2:0] slave1_state_cg;  // Copy of slave1 state
    logic [2:0] slave2_state_cg;  // Copy of slave2 state
    
    // Update state signals for covergroup
    always @(slave0.state) slave0_state_cg = slave0.state;
    always @(slave1.state) slave1_state_cg = slave1.state;
    always @(slave2.state) slave2_state_cg = slave2.state;
    
        // COVERGROUPS DEFINITION
        
    // Covergroup for Master Coverage Collection
    covergroup i2c_master_cg (string name) @(posedge clk);
        option.per_instance = 1;  // Separate coverage per instance
        option.name = name;       // Instance name
        
        // FSM coverage for master - using cast to correct type
        master_state: coverpoint master.state {
            bins idle = {master_state_t'(IDLE)};
            bins start = {master_state_t'(START)};
            bins wait_s = {master_state_t'(WAIT_S)};
            bins address = {master_state_t'(ADDRESS)};
            bins read_ack = {master_state_t'(READ_ACK)};
            bins write_data = {master_state_t'(WRITE_DATA)};
            bins read_ack2 = {master_state_t'(READ_ACK2)};
            bins read_data = {master_state_t'(READ_DATA)};
            bins write_ack = {master_state_t'(WRITE_ACK)};
            bins stop = {master_state_t'(STOP)};
            bins illegal_states = default;  // Catch any illegal states
        }
        
        // Operation type coverage (read/write)
        operation: coverpoint rw {
            bins write = {0};  // Write operation
            bins read  = {1};  // Read operation
        }
        
        // Slave addresses coverage
        slave_addr: coverpoint address {
            bins slave0 = {7'b0101010};  // Slave0 address
            bins slave1 = {7'b0110011};  // Slave1 address
            bins slave2 = {7'b0011101};  // Slave2 address
            bins others = default;       // Other addresses
        }
        
        // Written data coverage
        write_data: coverpoint master_data_in {
            bins zero    = {8'h00};       // All zeros
            bins ones    = {8'hFF};       // All ones
            bins pattern[] = {8'hA5, 8'h3C, 8'h77};  // Specific patterns
            bins others  = default;       // Other values
        }
        
        // Read data coverage
        read_data: coverpoint master_data_out {
            bins zero    = {8'h00};       // All zeros
            bins ones    = {8'hFF};       // All ones
            bins pattern[] = {8'hF0, 8'h55, 8'h99};  // Specific patterns
            bins others  = default;       // Other values
        }
        
        // Cross coverage: operation × slave address
        cross_op_slave: cross operation, slave_addr;
        
        // Cross coverage: master state × operation
        cross_state_op: cross master_state, operation;
        
    endgroup
    
    // Covergroup for Slave Coverage Collection
    covergroup i2c_slave_cg (string name, int slave_id, 
                             ref logic [7:0] rec, 
                             ref logic [7:0] send,
                             ref logic [2:0] state_signal) @(posedge clk);
        option.per_instance = 1;  // Separate coverage per instance
        option.name = name;       // Instance name
        
        // Slave identifier coverage
        id_cp: coverpoint slave_id;
        
        // Slave FSM coverage - using cast to correct type
        slave_state: coverpoint state_signal {
            bins idle = {slave_state_t'(SLAVE_IDLE)};
            bins read_addr = {slave_state_t'(SLAVE_READ_ADDR)};
            bins send_ack = {slave_state_t'(SLAVE_SEND_ACK)};
            bins read_data = {slave_state_t'(SLAVE_READ_DATA)};
            bins send_ack2 = {slave_state_t'(SLAVE_SEND_ACK2)};
            bins write_data = {slave_state_t'(SLAVE_WRITE_DATA)};
            bins illegal_states = default;  // Catch any illegal states
        }
        
        // Received data coverage (write operation)
        data_received: coverpoint rec {
            bins zero    = {8'h00};       // All zeros
            bins ones    = {8'hFF};       // All ones
            bins pattern[] = {8'hA5, 8'h3C, 8'h77};  // Specific patterns
            bins others  = default;       // Other values
        }
        
        // Sent data coverage (read operation)
        data_sent: coverpoint send {
            bins zero    = {8'h00};       // All zeros
            bins ones    = {8'hFF};       // All ones
            bins pattern[] = {8'hF0, 8'h55, 8'h99};  // Specific patterns
            bins others  = default;       // Other values
        }
        
        // Cross coverage: received data × sent data
        cross_data: cross data_received, data_sent;
        
        // Cross coverage: slave state × received data
        cross_state_data: cross slave_state, data_received;
        
    endgroup
    
        // COVERGROUPS INSTANTIATION
        
    i2c_master_cg master_cg = new("master_cg");
    i2c_slave_cg slave0_cg = new("slave0_cg", 0, slave0_rec_cg, slave0_send_cg, slave0_state_cg);
    i2c_slave_cg slave1_cg = new("slave1_cg", 1, slave1_rec_cg, slave1_send_cg, slave1_state_cg);
    i2c_slave_cg slave2_cg = new("slave2_cg", 2, slave2_rec_cg, slave2_send_cg, slave2_state_cg);
    
    // Clock Generation
    initial begin
        clk = 0;
        forever #1 clk = ~clk;  // 2ns period (500MHz)
    end
    
    // Test Sequence
    initial begin

        // VCD file generation for waveform viewing
        $dumpfile("waveform.vcd");
        $dumpvars(0, i2c_multi_slave_tb);

        // Initial reset and disable
        rst = 1;
        enable = 0;
        rw = 0;
        address = 0;
        master_data_in = 0;

        slave0_data_to_send = 0;
        slave1_data_to_send = 0;
        slave2_data_to_send = 0;

        // Release reset after 20ns
        #20 rst = 0;

        
        // TEST CASE 1: WRITE TO SLAVE 0
        // Write 0xA5 to slave with address 0b0101010
        address = 7'b0101010;
        master_data_in = 8'hA5;
        rw = 0;  // Write operation
        enable = 1; #10 enable = 0;  // Pulse enable
        #400;  // Wait for transaction to complete

        // Check result
        if (slave0_data_received == 8'hA5)
            $display("OK WRITE: Slave0 received %h", slave0_data_received);
        else
            $display("ERROR WRITE: Slave0 received %h", slave0_data_received);

        
        // TEST CASE 2: WRITE TO SLAVE 1
        // Write 0x3C to slave with address 0b0110011
        address = 7'b0110011;
        master_data_in = 8'h3C;
        rw = 0;  // Write operation
        enable = 1; #10 enable = 0;  // Pulse enable
        #400;  // Wait for transaction to complete

        // Check result
        if (slave1_data_received == 8'h3C)
            $display("OK WRITE: Slave1 received %h", slave1_data_received);
        else
            $display("ERROR WRITE: Slave1 received %h", slave1_data_received);

        
        // TEST CASE 3: WRITE TO SLAVE 2
        // Write 0x77 to slave with address 0b0011101
        address = 7'b0011101;
        master_data_in = 8'h77;
        rw = 0;  // Write operation
        enable = 1; #10 enable = 0;  // Pulse enable
        #400;  // Wait for transaction to complete

        // Check result
        if (slave2_data_received == 8'h77)
            $display("OK WRITE: Slave2 received %h", slave2_data_received);
        else
            $display("ERROR WRITE: Slave2 received %h", slave2_data_received);

        
        // TEST CASE 4: READ FROM SLAVE 0
        // Read from slave0, which will send 0xF0
        slave0_data_to_send = 8'hF0;
        address = 7'b0101010;
        rw = 1;  // Read operation
        enable = 1; #10 enable = 0;  // Pulse enable
        #600;  // Wait for transaction to complete (reads take longer)

        // Check result
        if (master_data_out == 8'hF0)
            $display("OK READ: Master read %h from Slave0", master_data_out);
        else
            $display("ERROR READ: Master read %h from Slave0", master_data_out);

        
        // TEST CASE 5: READ FROM SLAVE 1
        // Read from slave1, which will send 0x55
        slave1_data_to_send = 8'h55;
        address = 7'b0110011;
        rw = 1;  // Read operation
        enable = 1; #10 enable = 0;  // Pulse enable
        #600;  // Wait for transaction to complete

        // Check result
        if (master_data_out == 8'h55)
            $display("OK READ: Master read %h from Slave1", master_data_out);
        else
            $display("ERROR READ: Master read %h from Slave1", master_data_out);

        
        // TEST CASE 6: READ FROM SLAVE 2
        // Read from slave2, which will send 0x99
        slave2_data_to_send = 8'h99;
        address = 7'b0011101;
        rw = 1;  // Read operation
        enable = 1; #10 enable = 0;  // Pulse enable
        #600;  // Wait for transaction to complete

        // Check result
        if (master_data_out == 8'h99)
            $display("OK READ: Master read %h from Slave2", master_data_out);
        else
            $display("ERROR READ: Master read %h from Slave2", master_data_out);

        $display("==== END OF SIMULATION ====");
        
        // Display coverage results
        $display("Coverage Results:");
        $display("Master Coverage: %0.2f%%", master_cg.get_inst_coverage());
        $display("Slave0 Coverage: %0.2f%%", slave0_cg.get_inst_coverage());
        $display("Slave1 Coverage: %0.2f%%", slave1_cg.get_inst_coverage());
        $display("Slave2 Coverage: %0.2f%%", slave2_cg.get_inst_coverage());
        
        $finish;  // End simulation
    end
  
    // I2C Protocol Assertions Monitor
    // These checkers verify I2C protocol compliance

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
            .sda_drive_en(sda_drive_en),
            .slave_state(state),
            .data_received(data_received),
            .data_to_send(data_to_send)
        );

endmodule