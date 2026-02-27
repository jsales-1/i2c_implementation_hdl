//==================================================
// 3. Sequence — generates I2C transaction items
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
            if (!item.randomize() with {
                // Random addresses (mix of valid and invalid)
                address dist {
                    7'h50 := 30,
                    7'h51 := 30,
                    7'h68 := 20,
                    7'h69 := 10,
                    [7'h10:7'h1F] := 10  // Invalid range
                };
                
                // Mix of operations
                rw dist {0 := 60, 1 := 40};
                
                // Random multi-byte transfers
                num_bytes dist {
                    1 := 70,
                    [2:4] := 25,
                    [5:8] := 5
                };
                
                // Occasionally inject NACK
                generate_nack dist {
                    0 := 95,
                    1 := 5
                };
            }) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
        
        `uvm_info(get_type_name(), "Stress test completed", UVM_LOW)
    endtask
endclass