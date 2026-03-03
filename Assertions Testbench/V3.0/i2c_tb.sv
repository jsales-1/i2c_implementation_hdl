// Testbench for I2C Single-Slave Communication
module i2c_single_slave_tb;

    
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
    logic [7:0] slave_data_to_send;   // Data slave will send on read
    logic [7:0] slave_data_received;  // Data slave received on write

    
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

    
    // Single Slave Instantiation with fixed address
    i2c_slave_controller #(.SLAVE_ADDR(7'b0101010)) slave (
        .rst(rst), 
        .sda(sda), 
        .scl(scl),
        .data_received(slave_data_received),
        .data_to_send(slave_data_to_send)
    );

    // ENUMERATED TYPE DEFINITIONS FOR FSM STATES
    
    // Master States (based on i2c_master_controller)
    typedef enum logic [3:0] {
        MASTER_IDLE      = 4'd0,  // Idle state
        MASTER_START     = 4'd1,  // Generate START condition
        MASTER_ADDRESS   = 4'd2,  // Transmit address + R/W bit
        MASTER_READ_ACK  = 4'd3,  // Read ACK/NACK after address
        MASTER_WRITE_DATA = 4'd4, // Write data to slave
        MASTER_READ_ACK2 = 4'd5,  // Read ACK/NACK after data write
        MASTER_READ_DATA = 4'd6,  // Read data from slave
        MASTER_WRITE_ACK = 4'd7,  // Write ACK after data read
        MASTER_STOP      = 4'd8   // Generate STOP condition
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
        
    logic [7:0] slave_rec_cg;   // Copy of slave received data
    logic [7:0] slave_send_cg;  // Copy of slave data to send
    
    // Update covergroup variables on each change
    always @(slave_data_received) slave_rec_cg = slave_data_received;
    always @(slave_data_to_send) slave_send_cg = slave_data_to_send;
    
    // SLAVE STATE SIGNALS FOR COVERAGE
        
    logic [2:0] slave_state_cg;  // Copy of slave state
    
    // Update state signals for covergroup
    always @(slave.state) slave_state_cg = slave_state_t'(slave.state);
    
    // COVERGROUPS DEFINITION
        
    // Covergroup for Master Coverage Collection
    covergroup i2c_master_cg (string name) @(posedge clk);
        option.per_instance = 1;  // Separate coverage per instance
        option.name = name;       // Instance name
        
        // FSM coverage for master
        master_state: coverpoint master.state {
            bins idle = {MASTER_IDLE};
            bins start = {MASTER_START};
            bins address = {MASTER_ADDRESS};
            bins read_ack = {MASTER_READ_ACK};
            bins write_data = {MASTER_WRITE_DATA};
            bins read_ack2 = {MASTER_READ_ACK2};
            bins read_data = {MASTER_READ_DATA};
            bins write_ack = {MASTER_WRITE_ACK};
            bins stop = {MASTER_STOP};
            bins illegal_states = default;  // Catch any illegal states
        }
        
        // Operation type coverage (read/write)
        operation: coverpoint rw {
            bins write = {0};  // Write operation
            bins read  = {1};  // Read operation
        }
        
        // Slave address coverage
        slave_addr: coverpoint address {
            bins slave_addr = {7'b0101010};  // Valid slave address
            bins other_addr = default;       // Other addresses
        }
        
        // Written data coverage
        write_data: coverpoint master_data_in {
            bins zero    = {8'h00};       // All zeros
            bins ones    = {8'hFF};       // All ones
            bins pattern[] = {8'hA5, 8'h3C, 8'h77, 8'h55};  // Specific patterns
            bins others  = default;       // Other values
        }
        
        // Read data coverage
        read_data: coverpoint master_data_out {
            bins zero    = {8'h00};       // All zeros
            bins ones    = {8'hFF};       // All ones
            bins pattern[] = {8'hF0, 8'h55, 8'h99, 8'hAA};  // Specific patterns
            bins others  = default;       // Other values
        }
        
        // Cross coverage: operation × slave address
        cross_op_slave: cross operation, slave_addr;
        
        // Cross coverage: master state × operation
        cross_state_op: cross master_state, operation;
        
    endgroup
    
    // Covergroup for Slave Coverage Collection
    covergroup i2c_slave_cg (string name, 
                             ref logic [7:0] rec, 
                             ref logic [7:0] send,
                             ref logic [2:0] state_signal) @(posedge clk);
        option.per_instance = 1;  // Separate coverage per instance
        option.name = name;       // Instance name
        
        // Slave FSM coverage
        slave_state: coverpoint state_signal {
            bins idle = {SLAVE_IDLE};
            bins read_addr = {SLAVE_READ_ADDR};
            bins send_ack = {SLAVE_SEND_ACK};
            bins read_data = {SLAVE_READ_DATA};
            bins send_ack2 = {SLAVE_SEND_ACK2};
            bins write_data = {SLAVE_WRITE_DATA};
            bins illegal_states = default;  // Catch any illegal states
        }
        
        // Received data coverage (write operation)
        data_received: coverpoint rec {
            bins zero    = {8'h00};       // All zeros
            bins ones    = {8'hFF};       // All ones
            bins pattern[] = {8'hA5, 8'h3C, 8'h77, 8'h55};  // Specific patterns
            bins others  = default;       // Other values
        }
        
        // Sent data coverage (read operation)
        data_sent: coverpoint send {
            bins zero    = {8'h00};       // All zeros
            bins ones    = {8'hFF};       // All ones
            bins pattern[] = {8'hF0, 8'h55, 8'h99, 8'hAA};  // Specific patterns
            bins others  = default;       // Other values
        }
        
        // Cross coverage: received data × sent data
        cross_data: cross data_received, data_sent;
        
        // Cross coverage: slave state × received data
        cross_state_data: cross slave_state, data_received;
        
    endgroup
    
    // COVERGROUPS INSTANTIATION
        
    i2c_master_cg master_cg = new("master_cg");
    i2c_slave_cg slave_cg = new("slave_cg", slave_rec_cg, slave_send_cg, slave_state_cg);
    
    // Clock Generation
    initial begin
        clk = 0;
        forever #1 clk = ~clk;  // 2ns period (500MHz)
    end
    
    // =========================================================
    // ASSERTIONS MONITOR - ORGANIZED OUTPUT
    // =========================================================
    
    // Variáveis para contar assertions
    int master_assert_count, slave_assert_count;
    int master_assert_pass, slave_assert_pass;
    int master_assert_fail, slave_assert_fail;
    
    // Tarefa para imprimir cabeçalho organizado
    task print_assert_header(string title);
        $display("\n%s", title);
        $display("=================================================================");
    endtask
    
    // Tarefa para imprimir resultado de assertion master
    task print_master_assert(string name, string desc, bit result);
        if (result) begin
            $display("PASS: [MASTER] %-30s - %s", name, desc);
            master_assert_pass++;
        end else begin
            $display("FAIL: [MASTER] %-30s - %s", name, desc);
            master_assert_fail++;
        end
        master_assert_count++;
    endtask
    
    // Tarefa para imprimir resultado de assertion slave
    task print_slave_assert(string name, string desc, bit result);
        if (result) begin
            $display("PASS: [SLAVE ] %-30s - %s", name, desc);
            slave_assert_pass++;
        end else begin
            $display("FAIL: [SLAVE ] %-30s - %s", name, desc);
            slave_assert_fail++;
        end
        slave_assert_count++;
    endtask
    
    // Tarefa para imprimir resumo final
    task print_assert_summary();
        $display("\n");
        $display("=================================================================");
        $display("                    ASSERTIONS SUMMARY                          ");
        $display("=================================================================");
        
        $display("\nMASTER ASSERTIONS:");
        $display("  Total:  %0d", master_assert_count);
        $display("  Passed: %0d", master_assert_pass);
        $display("  Failed: %0d", master_assert_fail);
        if (master_assert_count > 0)
            $display("  Coverage: %0.2f%%", (master_assert_pass * 100.0 / master_assert_count));
        else
            $display("  Coverage: N/A (no assertions)");
        
        $display("\nSLAVE ASSERTIONS:");
        $display("  Total:  %0d", slave_assert_count);
        $display("  Passed: %0d", slave_assert_pass);
        $display("  Failed: %0d", slave_assert_fail);
        if (slave_assert_count > 0)
            $display("  Coverage: %0.2f%%", (slave_assert_pass * 100.0 / slave_assert_count));
        else
            $display("  Coverage: N/A (no assertions)");
        
        $display("\nOVERALL:");
        $display("  Total Assertions:  %0d", master_assert_count + slave_assert_count);
        $display("  Total Passed:      %0d", master_assert_pass + slave_assert_pass);
        $display("  Total Failed:      %0d", master_assert_fail + slave_assert_fail);
        if (master_assert_count + slave_assert_count > 0)
            $display("  Overall Coverage:  %0.2f%%", 
                    ((master_assert_pass + slave_assert_pass) * 100.0 / 
                     (master_assert_count + slave_assert_count)));
        else
            $display("  Overall Coverage:  N/A (no assertions)");
        
        $display("\n=================================================================");
        
        if (master_assert_fail > 0 || slave_assert_fail > 0) begin
            $display("\n  WARNING: Some assertions failed! Check the FAIL entries above.\n");
        end else if (master_assert_count + slave_assert_count > 0) begin
            $display("\n ALL ASSERTIONS PASSED!\n");
        end else begin
            $display("\nℹ  No assertions were executed.\n");
        end
    endtask
    
    // Test Sequence
    initial begin

        // VCD file generation for waveform viewing
        $dumpfile("waveform.vcd");
        $dumpvars(0, i2c_single_slave_tb);

        // Initial reset and disable
        rst = 1;
        enable = 0;
        rw = 0;
        address = 0;
        master_data_in = 0;
        slave_data_to_send = 0;

        $display("\n");
        $display("=================================================================");
        $display("           I2C SINGLE-SLAVE TESTBENCH SIMULATION                ");
        $display("=================================================================");
        $display("Start time: %t", $realtime);
        $display("Slave Address: 0x2A (7'b0101010)");
        $display("");

        // Release reset after 20ns
        #20 rst = 0;
        $display("Reset released at %t", $realtime);
        
        // Inicializar contadores
        master_assert_count = 0;
        slave_assert_count = 0;
        master_assert_pass = 0;
        slave_assert_pass = 0;
        master_assert_fail = 0;
        slave_assert_fail = 0;
        
        // ====================================================
        // TEST CASE 1: WRITE TO SLAVE - MULTIPLE PATTERNS
        // ====================================================
        print_assert_header("TEST CASE 1: WRITE OPERATIONS TO SLAVE");
        address = 7'b0101010;  // Slave address
        
        // Write 0xA5
        $display("\n--- Writing 0xA5 to slave ---");
        master_data_in = 8'hA5;
        rw = 0;  // Write operation
        enable = 1; #10 enable = 0;  // Pulse enable
        #400;  // Wait for transaction to complete

        print_slave_assert("Write 0xA5", 
                          $sformatf("Received: 0x%h (expected 0xA5)", slave_data_received),
                          slave_data_received == 8'hA5);
        
        // Write 0x3C
        $display("\n--- Writing 0x3C to slave ---");
        master_data_in = 8'h3C;
        enable = 1; #10 enable = 0;  // Pulse enable
        #400;  // Wait for transaction to complete

        print_slave_assert("Write 0x3C", 
                          $sformatf("Received: 0x%h (expected 0x3C)", slave_data_received),
                          slave_data_received == 8'h3C);
        
        // Write 0x00
        $display("\n--- Writing 0x00 to slave ---");
        master_data_in = 8'h00;
        enable = 1; #10 enable = 0;  // Pulse enable
        #400;  // Wait for transaction to complete

        print_slave_assert("Write 0x00", 
                          $sformatf("Received: 0x%h (expected 0x00)", slave_data_received),
                          slave_data_received == 8'h00);
        
        // Write 0xFF
        $display("\n--- Writing 0xFF to slave ---");
        master_data_in = 8'hFF;
        enable = 1; #10 enable = 0;  // Pulse enable
        #400;  // Wait for transaction to complete

        print_slave_assert("Write 0xFF", 
                          $sformatf("Received: 0x%h (expected 0xFF)", slave_data_received),
                          slave_data_received == 8'hFF);
        
        // Write 0x55
        $display("\n--- Writing 0x55 to slave ---");
        master_data_in = 8'h55;
        enable = 1; #10 enable = 0;  // Pulse enable
        #400;  // Wait for transaction to complete

        print_slave_assert("Write 0x55", 
                          $sformatf("Received: 0x%h (expected 0x55)", slave_data_received),
                          slave_data_received == 8'h55);
        
        // ====================================================
        // TEST CASE 2: READ FROM SLAVE - MULTIPLE PATTERNS
        // ====================================================
        print_assert_header("TEST CASE 2: READ OPERATIONS FROM SLAVE");
        address = 7'b0101010;  // Slave address
        
        // Read with data 0xF0
        $display("\n--- Reading from slave (expected 0xF0) ---");
        slave_data_to_send = 8'hF0;
        rw = 1;  // Read operation
        enable = 1; #10 enable = 0;  // Pulse enable
        #600;  // Wait for transaction to complete

        print_master_assert("Read 0xF0", 
                           $sformatf("Master read: 0x%h (expected 0xF0)", master_data_out),
                           master_data_out == 8'hF0);
        
        // Read with data 0x55
        $display("\n--- Reading from slave (expected 0x55) ---");
        slave_data_to_send = 8'h55;
        enable = 1; #10 enable = 0;  // Pulse enable
        #600;  // Wait for transaction to complete

        print_master_assert("Read 0x55", 
                           $sformatf("Master read: 0x%h (expected 0x55)", master_data_out),
                           master_data_out == 8'h55);
        
        // Read with data 0xAA
        $display("\n--- Reading from slave (expected 0xAA) ---");
        slave_data_to_send = 8'hAA;
        enable = 1; #10 enable = 0;  // Pulse enable
        #600;  // Wait for transaction to complete

        print_master_assert("Read 0xAA", 
                           $sformatf("Master read: 0x%h (expected 0xAA)", master_data_out),
                           master_data_out == 8'hAA);
        
        // Read with data 0x12
        $display("\n--- Reading from slave (expected 0x12) ---");
        slave_data_to_send = 8'h12;
        enable = 1; #10 enable = 0;  // Pulse enable
        #600;  // Wait for transaction to complete

        print_master_assert("Read 0x12", 
                           $sformatf("Master read: 0x%h (expected 0x12)", master_data_out),
                           master_data_out == 8'h12);
        
        // ====================================================
        // TEST CASE 3: UNRECOGNIZED ADDRESS - NO SLAVE RESPONDS
        // ====================================================
        print_assert_header("TEST CASE 3: UNRECOGNIZED ADDRESS");
        
        // First, set known data in slave
        $display("\nSetting slave known data (0x55)...");
        address = 7'b0101010;
        master_data_in = 8'h55;
        rw = 0;
        enable = 1; #10 enable = 0;
        #400;
        print_slave_assert("Set initial data", 
                          $sformatf("Slave set to: 0x%h", slave_data_received),
                          slave_data_received == 8'h55);
        
        // Try write to different address
        $display("\n--- Write to unrecognized address 0x00 ---");
        address = 7'b0000000;
        master_data_in = 8'hAA;
        rw = 0;
        enable = 1; #10 enable = 0;
        #300;
        
        print_slave_assert("Unrecognized addr write", 
                          $sformatf("Slave data unchanged: 0x%h (expected 0x55)", slave_data_received),
                          slave_data_received == 8'h55);
        
        // Try read from different address
        $display("\n--- Read from unrecognized address 0x7F ---");
        address = 7'b1111111;
        slave_data_to_send = 8'hBB;  // This should not be sent
        rw = 1;
        enable = 1; #10 enable = 0;
        #300;
        
        $display("Master data out: 0x%h (should be unknown/X)", master_data_out);
        print_slave_assert("Unrecognized addr read", 
                          $sformatf("Slave data still: 0x%h", slave_data_received),
                          slave_data_received == 8'h55);
        
        // ====================================================
        // TEST CASE 4: MIXED OPERATIONS
        // ====================================================
        print_assert_header("TEST CASE 4: MIXED OPERATIONS");
        address = 7'b0101010;
        
        // Write then read
        $display("\n--- Write 0x77, then read back ---");
        
        // Write 0x77
        master_data_in = 8'h77;
        rw = 0; enable = 1; #10 enable = 0; #400;
        print_slave_assert("Write 0x77", 
                          $sformatf("Slave received: 0x%h", slave_data_received),
                          slave_data_received == 8'h77);
        
        // Read back (slave should send what it has)
        slave_data_to_send = slave_data_received;  // Send back received data
        rw = 1; enable = 1; #10 enable = 0; #600;
        print_master_assert("Read back 0x77", 
                           $sformatf("Master read: 0x%h (expected 0x77)", master_data_out),
                           master_data_out == 8'h77);
        
        // ====================================================
        // TEST CASE 5: CONSECUTIVE READS
        // ====================================================
        print_assert_header("TEST CASE 5: CONSECUTIVE READS");
        address = 7'b0101010;
        
        // Set slave data
        slave_data_to_send = 8'h99;
        $display("\nSlave data set to: 0x99");
        
        // First read
        rw = 1; enable = 1; #10 enable = 0; #600;
        print_master_assert("Read 1 - 0x99", 
                           $sformatf("Master read: 0x%h", master_data_out),
                           master_data_out == 8'h99);
        
        // Second read with same data
        enable = 1; #10 enable = 0; #600;
        print_master_assert("Read 2 - 0x99", 
                           $sformatf("Master read: 0x%h", master_data_out),
                           master_data_out == 8'h99);
        
        // Change slave data
        slave_data_to_send = 8'h66;
        $display("\nSlave data changed to: 0x66");
        
        // Third read
        enable = 1; #10 enable = 0; #600;
        print_master_assert("Read 3 - 0x66", 
                           $sformatf("Master read: 0x%h", master_data_out),
                           master_data_out == 8'h66);
        
        // ====================================================
        // TEST CASE 6: CONSECUTIVE WRITES
        // ====================================================
        print_assert_header("TEST CASE 6: CONSECUTIVE WRITES");
        address = 7'b0101010;
        
        // Write 0x11
        master_data_in = 8'h11;
        rw = 0; enable = 1; #10 enable = 0; #400;
        print_slave_assert("Write 1 - 0x11", 
                          $sformatf("Slave received: 0x%h", slave_data_received),
                          slave_data_received == 8'h11);
        
        // Write 0x22
        master_data_in = 8'h22;
        enable = 1; #10 enable = 0; #400;
        print_slave_assert("Write 2 - 0x22", 
                          $sformatf("Slave received: 0x%h", slave_data_received),
                          slave_data_received == 8'h22);
        
        // Write 0x33
        master_data_in = 8'h33;
        enable = 1; #10 enable = 0; #400;
        print_slave_assert("Write 3 - 0x33", 
                          $sformatf("Slave received: 0x%h", slave_data_received),
                          slave_data_received == 8'h33);

        $display("\n");
        $display("=================================================================");
        $display("                    SIMULATION COMPLETE                         ");
        $display("=================================================================");
        $display("End time: %t", $realtime);
        
        // Display coverage results
        $display("\n");
        $display("=================================================================");
        $display("                    COVERAGE RESULTS                             ");
        $display("=================================================================");
        $display("Master Coverage:  %0.2f%%", master_cg.get_inst_coverage());
        $display("Slave Coverage:   %0.2f%%", slave_cg.get_inst_coverage());
        $display("=================================================================");
        
        // Chamar resumo das assertions
        print_assert_summary();
        
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
            .data_to_send(data_to_send),
            .SLAVE_ADDR(SLAVE_ADDR),
            .address_reg(address_reg)
        );

endmodule