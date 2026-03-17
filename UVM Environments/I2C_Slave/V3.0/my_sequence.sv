//==================================================
// 3. Sequence — generates I2C master transactions for slave verification
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
            start_item(item);
            if (!item.randomize() with {
                target_addr == target_address;
                rw dist {0 := write_ratio, 1 := (100 - write_ratio)};
                generate_stop == 1;
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
                target_addr == target_address;
                rw == 0;  // Write operation
                generate_stop == 1;
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
                target_addr == target_address;
                rw == 1;  // Read operation
                generate_stop == 1;
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
    rand bit [6:0] target_address = 7'h50;
    
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
            if (!item.randomize() with {
                target_addr == target_address;
                rw dist {0 := 50, 1 := 50};
                generate_stop == 1;
            }) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
        
        // Inject error conditions (addresses that should NACK)
        repeat (num_errors) begin
            start_item(item);
            if (!item.randomize() with {
                target_addr dist {
                    7'h50 := 20,      // Known address (should ACK)
                    7'h51 := 20,      // Known address (should ACK)
                    7'h30 := 30,      // Unknown address (should NACK)
                    7'h31 := 30       // Unknown address (should NACK)
                };
                rw dist {0 := 50, 1 := 50};
                generate_stop == 1;
            }) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
        
        // Send some normal transactions after errors
        repeat (3) begin
            start_item(item);
            if (!item.randomize() with {
                target_addr == target_address;
                rw dist {0 := 50, 1 := 50};
                generate_stop == 1;
            }) begin
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
    rand bit [6:0] target_address = 7'h50;
    
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
            if (!item.randomize() with {
                // Random addresses (mix of valid and invalid)
                target_addr dist {
                    target_address := 50,      // Primary target
                    7'h51 := 20,                // Secondary target
                    7'h68 := 15,                // Another valid address
                    [7'h10:7'h1F] := 15         // Invalid range (should NACK)
                };
                
                // Mix of operations
                rw dist {0 := 60, 1 := 40};
                
                // Random write data
                write_data dist {
                    [0:15]    := 10,
                    [128:143] := 10,
                    [240:255] := 10,
                    [16:127]  := 40,
                    [144:239] := 30
                };
                
                // STOP generation
                generate_stop dist {
                    1 := 95,   // Most end with STOP
                    0 := 5     // Some might not (for testing)
                };
                
                // Random bit delays
                bit_delay dist {
                    0 := 80,
                    [1:2] := 15,
                    [3:5] := 5
                };
            }) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
        
        `uvm_info(get_type_name(), "Stress test completed", UVM_LOW)
    endtask
endclass

//==================================================
// VIRTUAL SEQUENCER FOR SLAVE
//==================================================
class my_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(my_virtual_sequencer)
    
    // Handle to actual sequencer
    uvm_sequencer #(my_seq_item) i2c_sequencer;
    
    // Configuration
    bit [6:0] slave_address = 7'h50;
    int test_timeout = 1000;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_config_db #(bit [6:0])::get(this, "", "slave_address", slave_address));
        void'(uvm_config_db #(int)::get(this, "", "test_timeout", test_timeout));
    endfunction
endclass

//==================================================
// VIRTUAL SEQUENCES FOR SLAVE
//==================================================

// Base virtual sequence
class my_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(my_virtual_sequence)
    
    my_virtual_sequencer v_seqr;
    
    // Handles to sequences
    write_sequence      write_seq;
    read_sequence       read_seq;
    error_sequence      error_seq;
    stress_sequence     stress_seq;
    
    // Configuration
    rand int repeat_count = 1;
    
    constraint default_config {
        soft repeat_count inside {[1:5]};
    }
    
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
        error_seq = error_sequence::type_id::create("error_seq");
        stress_seq = stress_sequence::type_id::create("stress_seq");
        
        // Configure sequences with slave address
        write_seq.target_address = v_seqr.slave_address;
        read_seq.target_address = v_seqr.slave_address;
        error_seq.target_address = v_seqr.slave_address;
        stress_seq.target_address = v_seqr.slave_address;
    endtask
endclass

// Comprehensive test virtual sequence
class comprehensive_test_vseq extends my_virtual_sequence;
    `uvm_object_utils(comprehensive_test_vseq)
    
    function new(string name = "comprehensive_test_vseq");
        super.new(name);
    endfunction
    
    task body();
        `uvm_info(get_type_name(), "Starting comprehensive slave test", UVM_LOW)
        
        // Test 1: Basic writes to verify slave can store data
        `uvm_info(get_type_name(), "Phase 1: Basic writes", UVM_LOW)
        write_seq.num_writes = 5;
        repeat (repeat_count) write_seq.start(v_seqr.i2c_sequencer);
        
        // Test 2: Basic reads to verify slave can retrieve data
        `uvm_info(get_type_name(), "Phase 2: Basic reads", UVM_LOW)
        read_seq.num_reads = 5;
        repeat (repeat_count) read_seq.start(v_seqr.i2c_sequencer);
        
        // Test 3: Mixed operations
        `uvm_info(get_type_name(), "Phase 3: Mixed operations", UVM_LOW)
        repeat (repeat_count * 2) begin
            my_sequence mixed_seq;
            mixed_seq = my_sequence::type_id::create("mixed_seq");
            mixed_seq.target_address = v_seqr.slave_address;
            mixed_seq.num_transactions = 5;
            mixed_seq.start(v_seqr.i2c_sequencer);
        end
        
        // Test 4: Error injection (addresses that should NACK)
        `uvm_info(get_type_name(), "Phase 4: Error injection", UVM_LOW)
        error_seq.num_errors = 3;
        repeat (repeat_count) error_seq.start(v_seqr.i2c_sequencer);
        
        `uvm_info(get_type_name(), "Comprehensive slave test completed", UVM_LOW)
    endtask
endclass

// Write stress test virtual sequence
class write_stress_vseq extends my_virtual_sequence;
    `uvm_object_utils(write_stress_vseq)
    
    function new(string name = "write_stress_vseq");
        super.new(name);
    endfunction
    
    task body();
        `uvm_info(get_type_name(), "Starting write stress test", UVM_LOW)
        
        // Multiple write sequences to fill slave memory
        repeat (5) begin
            write_seq.num_writes = 20;
            write_seq.start(v_seqr.i2c_sequencer);
        end
        
        `uvm_info(get_type_name(), "Write stress test completed", UVM_LOW)
    endtask
endclass

// Read stress test virtual sequence
class read_stress_vseq extends my_virtual_sequence;
    `uvm_object_utils(read_stress_vseq)
    
    function new(string name = "read_stress_vseq");
        super.new(name);
    endfunction
    
    task body();
        `uvm_info(get_type_name(), "Starting read stress test", UVM_LOW)
        
        // Multiple read sequences to verify memory
        repeat (5) begin
            read_seq.num_reads = 20;
            read_seq.start(v_seqr.i2c_sequencer);
        end
        
        `uvm_info(get_type_name(), "Read stress test completed", UVM_LOW)
    endtask
endclass

// Protocol test virtual sequence (without STOP)
class protocol_test_vseq extends my_virtual_sequence;
    `uvm_object_utils(protocol_test_vseq)
    
    my_seq_item item;
    
    function new(string name = "protocol_test_vseq");
        super.new(name);
    endfunction
    
    task body();
        `uvm_info(get_type_name(), "Starting protocol test (no STOP)", UVM_LOW)
        
        // Create custom items without STOP
        repeat (5) begin
            item = my_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with {
                target_addr == v_seqr.slave_address;
                rw dist {0 := 50, 1 := 50};
                generate_stop == 0;  // No STOP
            }) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
        
        `uvm_info(get_type_name(), "Protocol test completed", UVM_LOW)
    endtask
endclass