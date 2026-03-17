//==================================================
// 3. Sequence — generates I2C transaction items
//==================================================

//==================================================
// Base Sequence with factory overrides support
//==================================================
class my_sequence extends uvm_sequence #(my_seq_item);
    `uvm_object_utils(my_sequence)

    my_seq_item item;
    
    // Configuration for sequence
    rand int num_transactions = 10;
    rand bit [6:0] target_address = 7'h50;
    rand int write_ratio = 50;  // Percentage of write operations
    
    constraint default_config {
        soft num_transactions inside {[5:20]};
        soft write_ratio inside {[0:100]};
    }
    
    function new(string name = "my_sequence");
        super.new(name);
    endfunction // new
    
    task pre_start();
        item = my_seq_item::type_id::create("item");
        `uvm_info(get_type_name(), $sformatf("Sequence starting with %0d transactions", 
                  num_transactions), UVM_LOW)
    endtask : pre_start
    
    task body();
        repeat (num_transactions) begin
            // Randomize and send a single transaction
            start_item(item);
            if (!item.randomize() with {
                address == target_address;
                rw dist {0 := write_ratio, 1 := (100 - write_ratio)};
            }) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
    endtask
    
endclass

//==================================================
// Write-only sequence
//==================================================
class write_sequence extends uvm_sequence #(my_seq_item);
    `uvm_object_utils(write_sequence)

    my_seq_item item;
    rand int num_writes = 10;
    rand bit [6:0] target_address = 7'h50;
    
    constraint default_config {
        num_writes inside {[5:20]};
    }
    
    function new(string name = "write_sequence");
        super.new(name);
    endfunction
    
    task body();
        repeat (num_writes) begin
            start_item(item);
            if (!item.randomize() with {
                address == target_address;
                rw == 0;  // Write operation
            }) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
    endtask
endclass

//==================================================
// Read-only sequence
//==================================================
class read_sequence extends uvm_sequence #(my_seq_item);
    `uvm_object_utils(read_sequence)

    my_seq_item item;
    rand int num_reads = 10;
    rand bit [6:0] target_address = 7'h50;
    
    constraint default_config {
        num_reads inside {[5:20]};
    }
    
    function new(string name = "read_sequence");
        super.new(name);
    endfunction
    
    task body();
        repeat (num_reads) begin
            start_item(item);
            if (!item.randomize() with {
                address == target_address;
                rw == 1;  // Read operation
            }) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
    endtask
endclass

//==================================================
// Multi-byte transfer sequence
//==================================================
class multi_byte_sequence extends uvm_sequence #(my_seq_item);
    `uvm_object_utils(multi_byte_sequence)

    my_seq_item item;
    rand int num_transfers = 5;
    rand int max_bytes = 8;
    rand bit [6:0] target_address = 7'h50;
    
    constraint default_config {
        num_transfers inside {[3:10]};
        max_bytes inside {[2:8]};
    }
    
    function new(string name = "multi_byte_sequence");
        super.new(name);
    endfunction
    
    task body();
        repeat (num_transfers) begin
            start_item(item);
            if (!item.randomize() with {
                address == target_address;
                num_bytes inside {[2:max_bytes]};
                rw dist {0 := 50, 1 := 50};
            }) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
    endtask
endclass

//==================================================
// Error injection sequence (NACK testing)
//==================================================
class error_sequence extends uvm_sequence #(my_seq_item);
    `uvm_object_utils(error_sequence)

    my_seq_item item;
    rand int num_errors = 5;
    
    constraint default_config {
        num_errors inside {[3:10]};
    }
    
    function new(string name = "error_sequence");
        super.new(name);
    endfunction
    
    task body();
        // Send some normal transactions first
        repeat (3) begin
            start_item(item);
            if (!item.randomize()) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
        
        // Inject error conditions
        repeat (num_errors) begin
            start_item(item);
            if (!item.randomize() with {
                generate_nack == 1;  // Force NACK condition
                address dist {
                    7'h50 := 40,      // Known address
                    7'h51 := 40,      // Known address
                    7'h30 := 10,      // Unknown address (should NACK)
                    7'h31 := 10       // Unknown address (should NACK)
                };
            }) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
        
        // Send some normal transactions after errors
        repeat (3) begin
            start_item(item);
            if (!item.randomize()) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
    endtask
endclass

//==================================================
// Random stress sequence
//==================================================
class stress_sequence extends uvm_sequence #(my_seq_item);
    `uvm_object_utils(stress_sequence)

    my_seq_item item;
    rand int num_transactions = 100;
    
    constraint default_config {
        num_transactions inside {[50:200]};
    }
    
    function new(string name = "stress_sequence");
        super.new(name);
    endfunction
    
    task body();
        `uvm_info(get_type_name(), $sformatf("Starting stress test with %0d transactions", 
                  num_transactions), UVM_LOW)
        
        repeat (num_transactions) begin
            start_item(item);
            if (!item.randomize()) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
        
        `uvm_info(get_type_name(), "Stress test completed", UVM_LOW)
    endtask
endclass

//==================================================
// VIRTUAL SEQUENCER
//==================================================
class my_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(my_virtual_sequencer)
    
    // Handle to actual sequencer
    uvm_sequencer #(my_seq_item) i2c_sequencer;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass

//==================================================
// VIRTUAL SEQUENCES
//==================================================

// Base virtual sequence
class my_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(my_virtual_sequence)
    
    my_virtual_sequencer v_seqr;
    
    // Handles to sequences
    write_sequence      write_seq;
    read_sequence       read_seq;
    multi_byte_sequence multi_seq;
    error_sequence      error_seq;
    stress_sequence     stress_seq;
    
    function new(string name = "my_virtual_sequence");
        super.new(name);
    endfunction
    
    task pre_start();
        // Get virtual sequencer handle
        if (!$cast(v_seqr, m_sequencer)) begin
            `uvm_error(get_type_name(), "Failed to cast m_sequencer to my_virtual_sequencer")
        end
        
        // Create sequences
        write_seq = write_sequence::type_id::create("write_seq");
        read_seq = read_sequence::type_id::create("read_seq");
        multi_seq = multi_byte_sequence::type_id::create("multi_seq");
        error_seq = error_sequence::type_id::create("error_seq");
        stress_seq = stress_sequence::type_id::create("stress_seq");
    endtask
endclass

// Comprehensive test virtual sequence
class comprehensive_test_vseq extends my_virtual_sequence;
    `uvm_object_utils(comprehensive_test_vseq)
    
    function new(string name = "comprehensive_test_vseq");
        super.new(name);
    endfunction
    
    task body();
        `uvm_info(get_type_name(), "Starting comprehensive test", UVM_LOW)
        
        // Test 1: Basic writes
        `uvm_info(get_type_name(), "Phase 1: Basic writes", UVM_LOW)
        write_seq.num_writes = 5;
        write_seq.start(v_seqr.i2c_sequencer);
        
        // Test 2: Basic reads
        `uvm_info(get_type_name(), "Phase 2: Basic reads", UVM_LOW)
        read_seq.num_reads = 5;
        read_seq.start(v_seqr.i2c_sequencer);
        
        // Test 3: Mixed operations
        `uvm_info(get_type_name(), "Phase 3: Mixed operations", UVM_LOW)
        repeat (3) begin
            my_sequence mixed_seq;
            mixed_seq = my_sequence::type_id::create("mixed_seq");
            mixed_seq.num_transactions = 5;
            mixed_seq.start(v_seqr.i2c_sequencer);
        end
        
        // Test 4: Multi-byte transfers
        `uvm_info(get_type_name(), "Phase 4: Multi-byte transfers", UVM_LOW)
        multi_seq.num_transfers = 3;
        multi_seq.start(v_seqr.i2c_sequencer);
        
        `uvm_info(get_type_name(), "Comprehensive test completed", UVM_LOW)
    endtask
endclass

// Stress test virtual sequence
class stress_test_vseq extends my_virtual_sequence;
    `uvm_object_utils(stress_test_vseq)
    
    function new(string name = "stress_test_vseq");
        super.new(name);
    endfunction
    
    task body();
        `uvm_info(get_type_name(), "Starting stress test sequence", UVM_LOW)
        
        // Run multiple stress sequences in parallel conceptually
        // (through sequential execution on same sequencer)
        repeat (3) begin
            stress_seq.num_transactions = 30;
            stress_seq.start(v_seqr.i2c_sequencer);
        end
        
        `uvm_info(get_type_name(), "Stress test completed", UVM_LOW)
    endtask
endclass

// Error injection virtual sequence
class error_test_vseq extends my_virtual_sequence;
    `uvm_object_utils(error_test_vseq)
    
    function new(string name = "error_test_vseq");
        super.new(name);
    endfunction
    
    task body();
        `uvm_info(get_type_name(), "Starting error injection test", UVM_LOW)
        
        // Normal operations first
        write_seq.num_writes = 3;
        write_seq.start(v_seqr.i2c_sequencer);
        
        // Error injection
        error_seq.num_errors = 5;
        error_seq.start(v_seqr.i2c_sequencer);
        
        // Recovery
        read_seq.num_reads = 3;
        read_seq.start(v_seqr.i2c_sequencer);
        
        `uvm_info(get_type_name(), "Error injection test completed", UVM_LOW)
    endtask
endclass