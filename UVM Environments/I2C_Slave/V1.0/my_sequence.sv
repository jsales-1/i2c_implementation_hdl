//==================================================
// 3. Sequence — generates I2C master transactions for slave verification
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
                
                // STOP generation
                generate_stop dist {
                    1 := 95,   // Most end with STOP
                    0 := 5     // Some might not (for testing)
                };
            }) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
        
        `uvm_info(get_type_name(), "Stress test completed", UVM_LOW)
    endtask
endclass