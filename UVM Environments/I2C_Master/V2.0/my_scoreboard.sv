//==================================================
// 7. Scoreboard — verifies I2C transactions
//==================================================
class my_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(my_scoreboard)

    // ------------------------------------------
    // Scoreboard components
    // ------------------------------------------
    my_seq_item expected_item;
    my_seq_item actual_item;
    
    // ------------------------------------------
    // Analysis export implementation
    // ------------------------------------------
    `uvm_analysis_imp_decl(_simple)
    uvm_analysis_imp_simple #(my_seq_item, my_scoreboard) agent_aep;

    // ------------------------------------------
    // FIFO declaration
    // ------------------------------------------
    protected uvm_tlm_analysis_fifo #(my_seq_item) item_fifo;

    // ------------------------------------------
    // Reference model for I2C
    // ------------------------------------------
    typedef struct {
        bit [6:0] address;
        bit [7:0] memory[256];
    } i2c_slave_model_t;
    
    i2c_slave_model_t slaves[4];  // Support up to 4 slaves
    int num_slaves;

    // ------------------------------------------
    // Report Counters
    // ------------------------------------------
    int compared_pass;
    int compared_fail;
    int write_count;
    int read_count;
    int ack_errors;
    int protocol_errors;

    // ------------------------------------------
    // Constructor
    // ------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
        compared_pass = 0;
        compared_fail = 0;
        write_count = 0;
        read_count = 0;
        ack_errors = 0;
        protocol_errors = 0;
    endfunction : new

    // ------------------------------------------
    // Build phase
    // ------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent_aep = new("agent_aep", this);
        item_fifo = new("item_fifo", this);
        
        expected_item = my_seq_item::type_id::create("expected_item");
        actual_item = my_seq_item::type_id::create("actual_item");
        
        // Initialize reference model slaves
        initialize_slaves();
    endfunction : build_phase

    // ------------------------------------------
    // Initialize reference model
    // ------------------------------------------
    function void initialize_slaves();
        num_slaves = 4;
        // Slave 0: address 0x50
        slaves[0].address = 7'h50;
        // Slave 1: address 0x51  
        slaves[1].address = 7'h51;
        // Slave 2: address 0x68
        slaves[2].address = 7'h68;
        // Slave 3: address 0x69
        slaves[3].address = 7'h69;
        
        // Initialize memory with known values
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 256; j++) begin
                slaves[i].memory[j] = j + (i << 4);  // Different pattern per slave
            end
        end
    endfunction

    // ------------------------------------------
    // Run phase - process items from FIFO
    // ------------------------------------------
    task run_phase(uvm_phase phase);
        forever begin
            item_fifo.get(actual_item);
            `uvm_info(get_type_name(), $sformatf("Scoreboard processing: %s", 
                      actual_item.convert2string()), UVM_MEDIUM)
            check_transaction(actual_item);
        end
    endtask : run_phase

    // ------------------------------------------
    // Check a single transaction
    // ------------------------------------------
    function void check_transaction(my_seq_item item);
        bit compare_result;
        bit [7:0] expected_data;
        
        `uvm_info(get_type_name(), $sformatf("Checking transaction: addr=0x%0h, rw=%0d", 
                  item.address, item.rw), UVM_HIGH)
        
        // Check if address is valid
        if (!is_valid_address(item.address)) begin
            `uvm_warning(get_type_name(), $sformatf("Transaction to unknown address 0x%0h", 
                         item.address))
            protocol_errors++;
            compared_fail++;
            return;
        end
        
        // Verify based on operation type
        if (item.is_write()) begin
            write_count++;
            compare_result = check_write_transaction(item);
        end
        else begin
            read_count++;
            compare_result = check_read_transaction(item);
        end
        
        // Check ACK status
        if (!item.ack_received) begin
            `uvm_warning(get_type_name(), $sformatf("No ACK received for transaction: %s", 
                         item.convert2string()))
            ack_errors++;
        end
        
        // Update counters
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
    // Check if address exists in reference model
    // ------------------------------------------
    function bit is_valid_address(bit [6:0] addr);
        for (int i = 0; i < num_slaves; i++) begin
            if (slaves[i].address == addr) return 1;
        end
        return 0;
    endfunction

    // ------------------------------------------
    // Get slave index from address
    // ------------------------------------------
    function int get_slave_index(bit [6:0] addr);
        for (int i = 0; i < num_slaves; i++) begin
            if (slaves[i].address == addr) return i;
        end
        return -1;
    endfunction

    // ------------------------------------------
    // Check write transaction
    // ------------------------------------------
    function bit check_write_transaction(my_seq_item item);
        int slave_idx = get_slave_index(item.address);
        
        if (slave_idx < 0) return 0;
        
        // For single byte write
        if (item.num_bytes == 1) begin
            // Store in reference model
            slaves[slave_idx].memory[item.data_in[6:0]] = item.data_in;
            
            // Could also check against expected value if we had one
            return 1;
        end
        // For multi-byte write
        else begin
            foreach (item.write_data[i]) begin
                slaves[slave_idx].memory[i] = item.write_data[i];
            end
            return 1;
        end
    endfunction

    // ------------------------------------------
    // Check read transaction
    // ------------------------------------------
    function bit check_read_transaction(my_seq_item item);
        int slave_idx = get_slave_index(item.address);
        bit [7:0] expected;
        bit match = 1;
        
        if (slave_idx < 0) return 0;
        
        // For single byte read
        if (item.num_bytes == 1) begin
            // Get expected value from reference model
            // For I2C, we need to know which address was read
            // This is simplified - assumes sequential reads
            expected = slaves[slave_idx].memory[0];
            
            if (item.data_out !== expected) begin
                `uvm_error(get_type_name(), $sformatf("Read mismatch: expected=0x%0h, actual=0x%0h", 
                           expected, item.data_out))
                match = 0;
            end
        end
        // For multi-byte read
        else begin
            foreach (item.read_data[i]) begin
                expected = slaves[slave_idx].memory[i];
                if (item.read_data[i] !== expected) begin
                    `uvm_error(get_type_name(), $sformatf("Read mismatch at byte %0d: expected=0x%0h, actual=0x%0h", 
                               i, expected, item.read_data[i]))
                    match = 0;
                end
            end
        end
        
        return match;
    endfunction

    // ------------------------------------------
    // Report phase
    // ------------------------------------------
    function void report_phase(uvm_phase phase);
        string report_msg;
        
        report_msg = "\n----------------------- I2C Scoreboard Report ------------------------------------\n";
        report_msg = {report_msg, $sformatf("Total transactions checked: %0d\n", compared_pass + compared_fail)};
        report_msg = {report_msg, $sformatf("  PASSED: %0d\n", compared_pass)};
        report_msg = {report_msg, $sformatf("  FAILED: %0d\n", compared_fail)};
        report_msg = {report_msg, $sformatf("Write operations: %0d\n", write_count)};
        report_msg = {report_msg, $sformatf("Read operations: %0d\n", read_count)};
        report_msg = {report_msg, $sformatf("ACK errors: %0d\n", ack_errors)};
        report_msg = {report_msg, $sformatf("Protocol errors: %0d\n", protocol_errors)};
        
        if (compared_fail == 0 && ack_errors == 0 && protocol_errors == 0)
            report_msg = {report_msg, "I2C Verification: PASSED"};
        else
            report_msg = {report_msg, "I2C Verification: FAILED"};
        
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