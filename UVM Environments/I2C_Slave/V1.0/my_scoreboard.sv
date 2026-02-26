//==================================================
// 7. Scoreboard — verifies I2C slave responses
//==================================================
class my_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(my_scoreboard)

    // ------------------------------------------
    // Scoreboard components
    // ------------------------------------------
    my_seq_item expected_item;
    my_seq_item actual_item;
    my_seq_item fifo_item;  // Item temporário para o FIFO
    
    // ------------------------------------------
    // Analysis export implementation
    // ------------------------------------------
    `uvm_analysis_imp_decl(_simple)
    uvm_analysis_imp_simple #(my_seq_item, my_scoreboard) agent_aep;

    // ------------------------------------------
    // FIFO declaration - usando o tipo correto
    // ------------------------------------------
    uvm_tlm_analysis_fifo #(my_seq_item) item_fifo;

    // ------------------------------------------
    // Reference model for I2C slave
    // ------------------------------------------
    typedef struct {
        bit [6:0] address;
        bit [7:0] memory[256];
    } i2c_slave_model_t;
    
    i2c_slave_model_t slave_model;
    bit [7:0] expected_read_data;

    // ------------------------------------------
    // Report Counters
    // ------------------------------------------
    int compared_pass;
    int compared_fail;
    int write_count;
    int read_count;
    int addr_ack_errors;
    int data_ack_errors;
    int data_mismatch_errors;
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
        addr_ack_errors = 0;
        data_ack_errors = 0;
        data_mismatch_errors = 0;
        protocol_errors = 0;
    endfunction : new

    // ------------------------------------------
    // Build phase
    // ------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent_aep = new("agent_aep", this);
        item_fifo = new("item_fifo", this);
        
        expected_item = my_seq_item::type_id::create("expected_item", this);
        actual_item = my_seq_item::type_id::create("actual_item", this);
        
        // Initialize reference model
        slave_model.address = 7'h50;
        for (int j = 0; j < 256; j++) begin
            slave_model.memory[j] = j;
        end
    endfunction : build_phase

    // ------------------------------------------
    // Run phase - process items from FIFO
    // ------------------------------------------
    task run_phase(uvm_phase phase);
        forever begin
            // Cria um novo item para receber do FIFO
            fifo_item = my_seq_item::type_id::create("fifo_item");
            
            // Pega o item do FIFO
            item_fifo.get(fifo_item);
            
            `uvm_info(get_type_name(), $sformatf("Scoreboard processing: %s", 
                      fifo_item.convert2string()), UVM_MEDIUM)
            
            // Copia para actual_item e verifica
            actual_item.copy(fifo_item);
            check_transaction(actual_item);
        end
    endtask : run_phase

    // ------------------------------------------
    // Check a single transaction
    // ------------------------------------------
    function void check_transaction(my_seq_item item);
        `uvm_info(get_type_name(), $sformatf("Checking transaction: addr=0x%0h, rw=%0d", 
                  item.target_addr, item.rw), UVM_HIGH)
        
        // Check address ACK
        if (item.target_addr == slave_model.address) begin
            if (!item.addr_ack) begin
                `uvm_error(get_type_name(), $sformatf("Slave did not ACK its own address 0x%0h", 
                          item.target_addr))
                addr_ack_errors++;
                compared_fail++;
                return;
            end
        end
        else begin
            if (item.addr_ack) begin
                `uvm_error(get_type_name(), $sformatf("Slave ACKed wrong address 0x%0h", 
                          item.target_addr))
                addr_ack_errors++;
                compared_fail++;
                return;
            end
            else begin
                // Correct behavior - no ACK for wrong address
                compared_pass++;
                return;
            end
        end
        
        // Verify based on operation type
        if (item.is_write()) begin
            write_count++;
            check_write_transaction(item);
        end
        else begin
            read_count++;
            check_read_transaction(item);
        end
        
        // Check STOP detection
        if (item.generate_stop && !item.stop_detected) begin
            `uvm_warning(get_type_name(), "STOP not detected by slave")
            protocol_errors++;
        end
    endfunction : check_transaction

    // ------------------------------------------
    // Check write transaction
    // ------------------------------------------
    function void check_write_transaction(my_seq_item item);
        `uvm_info(get_type_name(), $sformatf("Checking write transaction: data=0x%0h", 
                  item.write_data), UVM_HIGH)
        
        // Check data ACK
        if (!item.data_ack) begin
            `uvm_error(get_type_name(), $sformatf("Slave did not ACK write data 0x%0h", 
                      item.write_data))
            data_ack_errors++;
            compared_fail++;
        end
        else begin
            // Update reference model
            slave_model.memory[0] = item.write_data;
            compared_pass++;
        end
    endfunction : check_write_transaction

    // ------------------------------------------
    // Check read transaction
    // ------------------------------------------
    function void check_read_transaction(my_seq_item item);
        `uvm_info(get_type_name(), $sformatf("Checking read transaction: data=0x%0h", 
                  item.read_data), UVM_HIGH)
        
        // Get expected value from reference model
        expected_read_data = slave_model.memory[0];
        
        if (item.read_data !== expected_read_data) begin
            `uvm_error(get_type_name(), $sformatf("Read mismatch: expected=0x%0h, actual=0x%0h", 
                      expected_read_data, item.read_data))
            data_mismatch_errors++;
            compared_fail++;
        end
        else begin
            compared_pass++;
        end
    endfunction : check_read_transaction

    // ------------------------------------------
    // Report phase
    // ------------------------------------------
    function void report_phase(uvm_phase phase);
        string report_msg;
        
        report_msg = "\n----------------------- I2C Slave Scoreboard Report ------------------------------------\n";
        report_msg = {report_msg, $sformatf("Total transactions checked: %0d\n", compared_pass + compared_fail)};
        report_msg = {report_msg, $sformatf("  PASSED: %0d\n", compared_pass)};
        report_msg = {report_msg, $sformatf("  FAILED: %0d\n", compared_fail)};
        report_msg = {report_msg, $sformatf("Write operations: %0d\n", write_count)};
        report_msg = {report_msg, $sformatf("Read operations: %0d\n", read_count)};
        report_msg = {report_msg, $sformatf("\nError Counts:\n")};
        report_msg = {report_msg, $sformatf("  Address ACK errors: %0d\n", addr_ack_errors)};
        report_msg = {report_msg, $sformatf("  Data ACK errors: %0d\n", data_ack_errors)};
        report_msg = {report_msg, $sformatf("  Data mismatch errors: %0d\n", data_mismatch_errors)};
        report_msg = {report_msg, $sformatf("  Protocol errors: %0d\n", protocol_errors)};
        
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