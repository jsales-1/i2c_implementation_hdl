//==================================================
// 7. Scoreboard — verifies I2C slave responses with Golden Model
//==================================================
class my_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(my_scoreboard)

    // ------------------------------------------
    // Golden Model for I2C Slave
    // ------------------------------------------
    class i2c_slave_golden;
        bit [6:0] slave_address;
        bit [7:0] memory[256];  // Internal memory of slave
        bit [7:0] last_write_data;
        bit [7:0] next_read_data;
        bit       addr_ack_expected;
        bit       data_ack_expected;
        int       byte_count;
        bit       test_mode;  // Added for simulated mode
        
        function new(bit [6:0] addr = 7'h50);
            this.slave_address = addr;
            this.addr_ack_expected = 1;
            this.data_ack_expected = 1;
            this.byte_count = 0;
            this.test_mode = 0;  // Default to real mode
            
            // Initialize memory with known values
            for (int i = 0; i < 256; i++) begin
                memory[i] = 8'hA5;  // Default value for test mode
            end
        endfunction
        
        // Predict slave behavior for a given transaction
        function void predict(my_seq_item item);
            bit match;
            
            // Check if address matches this slave
            match = (item.target_addr == slave_address);
            
            // Predict address ACK
            this.addr_ack_expected = match;
            
            if (match) begin
                if (item.is_write()) begin
                    // For write operations, slave should ACK and store data
                    this.data_ack_expected = 1;
                    this.last_write_data = item.write_data;
                    memory[byte_count] = item.write_data;
                    byte_count++;
                    
                    // In test mode, set next_read_data to the written data
                    if (test_mode) begin
                        this.next_read_data = item.write_data;
                    end
                end
                else begin
                    // For read operations, slave should provide data
                    if (test_mode) begin
                        // In test mode, return last written data or default
                        if (byte_count > 0) begin
                            this.next_read_data = last_write_data;
                        end else begin
                            this.next_read_data = 8'hA5;
                        end
                    end else begin
                        // Real mode - use memory
                        this.next_read_data = memory[byte_count];
                    end
                end
            end
        endfunction
        
        // Get expected read data - FIXED: Now properly defined as a function
        function bit [7:0] get_expected_read_data();
            return next_read_data;
        endfunction
        
        // Set test mode
        function void set_test_mode(bit mode);
            this.test_mode = mode;
        endfunction
    endclass
    
    // ------------------------------------------
    // Scoreboard components
    // ------------------------------------------
    my_seq_item expected_item;
    my_seq_item actual_item;
    my_seq_item fifo_item;
    i2c_slave_golden golden_model;
    
    // ------------------------------------------
    // Analysis export implementation
    // ------------------------------------------
    `uvm_analysis_imp_decl(_simple)
    uvm_analysis_imp_simple #(my_seq_item, my_scoreboard) agent_aep;

    // ------------------------------------------
    // FIFO declaration
    // ------------------------------------------
    uvm_tlm_analysis_fifo #(my_seq_item) item_fifo;

    // ------------------------------------------
    // Configuration
    // ------------------------------------------
    bit [6:0] slave_address = 7'h50;
    string    golden_model_type = "default";
    bit       test_mode = 1;  // Added to match driver/monitor

    // ------------------------------------------
    // Report Counters
    // ------------------------------------------
    int compared_pass;
    int compared_fail;
    int write_count;
    int read_count;
    int addr_ack_mismatch;
    int data_ack_mismatch;
    int data_mismatch;
    int unexpected_addr_ack;

    // ------------------------------------------
    // Constructor
    // ------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
        compared_pass = 0;
        compared_fail = 0;
        write_count = 0;
        read_count = 0;
        addr_ack_mismatch = 0;
        data_ack_mismatch = 0;
        data_mismatch = 0;
        unexpected_addr_ack = 0;
    endfunction : new

    // ------------------------------------------
    // Build phase
    // ------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration from config DB
        void'(uvm_config_db #(bit [6:0])::get(this, "", "slave_address", slave_address));
        void'(uvm_config_db #(string)::get(this, "", "golden_model_type", golden_model_type));
        void'(uvm_config_db #(bit)::get(this, "", "test_mode", test_mode));
        
        agent_aep = new("agent_aep", this);
        item_fifo = new("item_fifo", this);
        
        expected_item = my_seq_item::type_id::create("expected_item", this);
        actual_item = my_seq_item::type_id::create("actual_item", this);
        
        // Create Golden Model
        golden_model = new(slave_address);
        golden_model.set_test_mode(test_mode);  // Set test mode
        
        `uvm_info(get_type_name(), $sformatf("Scoreboard built with slave_addr=0x%0h, test_mode=%0d", 
                  slave_address, test_mode), UVM_LOW)
    endfunction : build_phase

    // ------------------------------------------
    // Run phase - process items from FIFO
    // ------------------------------------------
    task run_phase(uvm_phase phase);
        forever begin
            fifo_item = my_seq_item::type_id::create("fifo_item");
            item_fifo.get(fifo_item);
            
            `uvm_info(get_type_name(), $sformatf("Scoreboard processing: %s", 
                      fifo_item.convert2string()), UVM_MEDIUM)
            
            actual_item.copy(fifo_item);
            check_transaction(actual_item);
        end
    endtask : run_phase

    // ------------------------------------------
    // Check a single transaction against Golden Model
    // ------------------------------------------
    function void check_transaction(my_seq_item item);
        bit compare_result = 1;
        
        `uvm_info(get_type_name(), $sformatf("Checking transaction: addr=0x%0h, rw=%0d", 
                  item.target_addr, item.rw), UVM_HIGH)
        
        // Use Golden Model to predict expected behavior
        golden_model.predict(item);
        
        // Update counters
        if (item.is_write()) write_count++;
        else read_count++;
        
        // Check address ACK against Golden Model
        if (item.addr_ack != golden_model.addr_ack_expected) begin
            if (item.addr_ack && !golden_model.addr_ack_expected) begin
                `uvm_error(get_type_name(), $sformatf("Slave ACKed wrong address 0x%0h", 
                          item.target_addr))
                unexpected_addr_ack++;
            end
            else begin
                `uvm_error(get_type_name(), $sformatf("Address ACK mismatch: expected=%0d, actual=%0d for addr=0x%0h", 
                          golden_model.addr_ack_expected, item.addr_ack, item.target_addr))
                addr_ack_mismatch++;
            end
            compare_result = 0;
        end
        
        // For write operations, check data ACK
        if (item.is_write() && item.addr_ack) begin
            if (item.data_ack != golden_model.data_ack_expected) begin
                `uvm_error(get_type_name(), $sformatf("Data ACK mismatch: expected=%0d, actual=%0d", 
                          golden_model.data_ack_expected, item.data_ack))
                data_ack_mismatch++;
                compare_result = 0;
            end
        end
        
        // For read operations, check read data
        if (item.is_read() && item.addr_ack) begin
            bit [7:0] expected_data = golden_model.get_expected_read_data();  // Now this works
            if (item.read_data !== expected_data) begin
                `uvm_error(get_type_name(), $sformatf("Read data mismatch: expected=0x%0h, actual=0x%0h", 
                          expected_data, item.read_data))
                data_mismatch++;
                compare_result = 0;
            end else begin
                `uvm_info(get_type_name(), $sformatf("Read data match: expected=0x%0h, actual=0x%0h", 
                          expected_data, item.read_data), UVM_MEDIUM)
            end
        end
        
        // Update pass/fail counters
        if (compare_result) begin
            compared_pass++;
            `uvm_info(get_type_name(), $sformatf("Transaction PASSED: %s", 
                      item.convert2string()), UVM_MEDIUM)
        end
        else begin
            compared_fail++;
            `uvm_error(get_type_name(), $sformatf("Transaction FAILED: %s", 
                       item.convert2string()))
        end
    endfunction

    // ------------------------------------------
    // Report phase
    // ------------------------------------------
    function void report_phase(uvm_phase phase);
        string report_msg;
        
        report_msg = "\n----------------------- I2C Slave Scoreboard Report ------------------------------------\n";
        report_msg = {report_msg, $sformatf("Slave Address: 0x%0h\n", slave_address)};
        report_msg = {report_msg, $sformatf("Golden Model: %s\n", golden_model_type)};
        report_msg = {report_msg, $sformatf("Test Mode: %0d\n", test_mode)};
        report_msg = {report_msg, $sformatf("Total transactions checked: %0d\n", compared_pass + compared_fail)};
        report_msg = {report_msg, $sformatf("  PASSED: %0d\n", compared_pass)};
        report_msg = {report_msg, $sformatf("  FAILED: %0d\n", compared_fail)};
        report_msg = {report_msg, $sformatf("Write operations: %0d\n", write_count)};
        report_msg = {report_msg, $sformatf("Read operations: %0d\n", read_count)};
        report_msg = {report_msg, $sformatf("\nError Counts:\n")};
        report_msg = {report_msg, $sformatf("  Address ACK mismatches: %0d\n", addr_ack_mismatch)};
        report_msg = {report_msg, $sformatf("  Unexpected Address ACKs: %0d\n", unexpected_addr_ack)};
        report_msg = {report_msg, $sformatf("  Data ACK mismatches: %0d\n", data_ack_mismatch)};
        report_msg = {report_msg, $sformatf("  Data mismatches: %0d\n", data_mismatch)};
        
        if (compared_fail == 0)
            report_msg = {report_msg, "\nI2C Slave Verification: PASSED"};
        else
            report_msg = {report_msg, "\nI2C Slave Verification: FAILED"};
        
        report_msg = {report_msg, "\n-------------------------------------------------------------------------\n"};
        
        `uvm_info(get_type_name(), report_msg, UVM_LOW)
    endfunction : report_phase

    // ------------------------------------------
    // Write method - receives items from monitor
    // ------------------------------------------
    function void write_simple(my_seq_item item);
        my_seq_item item_clone;
        $cast(item_clone, item.clone());
        `uvm_info(get_type_name(), $sformatf("Received item: %s", item.convert2string()), UVM_HIGH)
        item_fifo.write(item_clone);
    endfunction : write_simple

endclass : my_scoreboard