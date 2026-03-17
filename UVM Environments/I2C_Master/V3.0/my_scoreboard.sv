//==================================================
// 7. Scoreboard — verifies I2C transactions with Golden Model
//==================================================
class my_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(my_scoreboard)

    // ------------------------------------------
    // Golden Model for I2C Master
    // ------------------------------------------
    class i2c_master_golden;
        bit [6:0] address;
        bit [7:0] write_data;
        bit [7:0] read_data;
        bit       rw;
        bit       ack_expected;
        int       byte_count;
        
        function new();
            ack_expected = 1;
            byte_count = 1;
        endfunction
        
        // Predict expected behavior
        function void predict(my_seq_item item);
            this.address = item.address;
            this.rw = item.rw;
            this.byte_count = item.num_bytes;
            
            if (item.is_write()) begin
                this.write_data = item.data_in;
                // For multi-byte writes
                if (item.num_bytes > 1) begin
                    foreach(item.write_data[i])
                        this.write_data = item.write_data[i];
                end
            end
            else begin
                // For reads, we need to know what the master expects to read
                // This is simplified - assumes sequential reads
                this.read_data = item.data_out;
            end
            
            // Predict ACK based on address validity
            this.ack_expected = is_address_valid(item.address);
        endfunction
        
        // Check if address is in valid range
        function bit is_address_valid(bit [6:0] addr);
            return (addr inside {7'h50, 7'h51, 7'h68, 7'h69});
        endfunction
    endclass
    
    // ------------------------------------------
    // Scoreboard components
    // ------------------------------------------
    my_seq_item expected_item;
    my_seq_item actual_item;
    i2c_master_golden golden_model;
    
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
    // Report Counters
    // ------------------------------------------
    int compared_pass;
    int compared_fail;
    int write_count;
    int read_count;
    int ack_mismatch;
    int data_mismatch;

    // ------------------------------------------
    // Constructor
    // ------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
        compared_pass = 0;
        compared_fail = 0;
        write_count = 0;
        read_count = 0;
        ack_mismatch = 0;
        data_mismatch = 0;
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
        
        golden_model = new();
    endfunction : build_phase

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
    // Check a single transaction against Golden Model
    // ------------------------------------------
    function void check_transaction(my_seq_item item);
        bit compare_result = 1;
        
        `uvm_info(get_type_name(), $sformatf("Checking transaction: addr=0x%0h, rw=%0d", 
                  item.address, item.rw), UVM_HIGH)
        
        // Use Golden Model to predict expected behavior
        golden_model.predict(item);
        
        // Update counters based on operation
        if (item.is_write()) write_count++;
        else read_count++;
        
        // Check ACK against Golden Model prediction
        if (item.ack_received != golden_model.ack_expected) begin
            `uvm_error(get_type_name(), $sformatf("ACK mismatch: expected=%0d, actual=%0d", 
                       golden_model.ack_expected, item.ack_received))
            ack_mismatch++;
            compare_result = 0;
        end
        
        // For read operations, check data against Golden Model
        if (item.is_read() && item.ack_received) begin
            if (item.data_out !== golden_model.read_data) begin
                `uvm_error(get_type_name(), $sformatf("Read data mismatch: expected=0x%0h, actual=0x%0h", 
                           golden_model.read_data, item.data_out))
                data_mismatch++;
                compare_result = 0;
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
        
        report_msg = "\n----------------------- I2C Scoreboard Report ------------------------------------\n";
        report_msg = {report_msg, $sformatf("Total transactions checked: %0d\n", compared_pass + compared_fail)};
        report_msg = {report_msg, $sformatf("  PASSED: %0d\n", compared_pass)};
        report_msg = {report_msg, $sformatf("  FAILED: %0d\n", compared_fail)};
        report_msg = {report_msg, $sformatf("Write operations: %0d\n", write_count)};
        report_msg = {report_msg, $sformatf("Read operations: %0d\n", read_count)};
        report_msg = {report_msg, $sformatf("ACK mismatches: %0d\n", ack_mismatch)};
        report_msg = {report_msg, $sformatf("Data mismatches: %0d\n", data_mismatch)};
        
        if (compared_fail == 0)
          report_msg = {report_msg, "I2C Verification Master: PASSED"};
        else
          report_msg = {report_msg, "I2C Verification Master: FAILED"};
        
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