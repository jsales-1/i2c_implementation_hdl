//==================================================
// 2. Transaction — represents an I2C transfer
//==================================================
class my_seq_item extends uvm_sequence_item;
    // I2C transaction fields
    rand bit [6:0] address;        // 7-bit I2C slave address
    rand bit [7:0] data_in;         // Data to write (for write operations)
    rand bit       rw;               // Operation: 0 = write, 1 = read
    rand bit       generate_nack;    // Generate NACK instead of ACK (for testing)
    rand int       delay_before_ack; // Variable delay before ACK (for testing)
    
    // Observed fields (filled by monitor)
    bit [7:0]      data_out;         // Data read (for read operations)
    bit            ack_received;      // ACK received after address/byte
    bit            bus_busy;          // I2C bus state
    bit            start_detected;    // START condition detected
    bit            stop_detected;     // STOP condition detected
    
    // Control fields for sequence/driver
    rand int       num_bytes;         // Number of bytes to transfer
    rand bit [7:0] write_data[];      // Array of data for multi-byte writes
    rand bit [7:0] read_data[];       // Array for multi-byte reads (expected)
    
    //==========================================
    // Constrained Random - Rich constraints
    //==========================================
    
    // Valid I2C addresses (mix of valid and invalid for testing)
    constraint valid_addresses {
        soft address inside {
            7'h50, 7'h51, 7'h68, 7'h69,  // Valid addresses
            7'h30, 7'h31, 7'h32          // Invalid addresses (for NACK testing)
        };
    }
    
    // Address distribution (70% valid, 30% invalid)
    constraint address_distribution {
        address dist {
            [7'h50:7'h51] := 35,  // Valid addresses
            [7'h68:7'h69] := 35,  // Valid addresses
            [7'h30:7'h32] := 30   // Invalid addresses
        };
    }
    
    // Read/Write distribution (60% write, 40% read)
    constraint rw_distribution {
        rw dist {
            0 := 60,  // Write
            1 := 40   // Read
        };
    }
    
    // Multi-byte transfer constraints
    constraint multi_byte_config {
        soft num_bytes == 1;
        num_bytes inside {[1:8]};
        
        // Weighted distribution for number of bytes
        num_bytes dist {
            1 := 70,    // Single byte most common
            [2:4] := 25, // 2-4 bytes medium
            [5:8] := 5   // 5-8 bytes rare
        };
        
        // Dynamic array sizes
        write_data.size() == num_bytes;
        read_data.size() == num_bytes;
    }
    
    // Data constraints
    constraint data_values {
        // Data can be any 8-bit value, but bias toward boundary values
        data_in dist {
            [0:15] := 10,     // Low values
            [128:143] := 10,  // Mid values  
            [240:255] := 10,  // High values
            [16:127] := 40,   // Rest of range
            [144:239] := 30
        };
        
        // For multi-byte writes
        foreach (write_data[i]) {
            write_data[i] dist {
                [0:15] := 10,
                [128:143] := 10,
                [240:255] := 10,
                [16:127] := 40,
                [144:239] := 30
            };
        }
    }
    
    // NACK injection constraint (5% of transactions)
    constraint nack_injection {
        generate_nack dist {
            0 := 95,
            1 := 5
        };
    }
    
    // Delay before ACK (for timing tests)
    constraint ack_delay {
        soft delay_before_ack == 0;
        delay_before_ack inside {[0:5]};
        delay_before_ack dist {
            0 := 80,
            [1:2] := 15,
            [3:5] := 5
        };
    }
    
    //==========================================
    // UVM Macros
    //==========================================
    `uvm_object_utils_begin(my_seq_item)
        `uvm_field_int(address, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(data_in, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(rw, UVM_DEFAULT)
        `uvm_field_int(generate_nack, UVM_DEFAULT)
        `uvm_field_int(delay_before_ack, UVM_DEFAULT)
        `uvm_field_int(data_out, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(ack_received, UVM_DEFAULT)
        `uvm_field_int(bus_busy, UVM_DEFAULT)
        `uvm_field_int(start_detected, UVM_DEFAULT)
        `uvm_field_int(stop_detected, UVM_DEFAULT)
        `uvm_field_int(num_bytes, UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int(write_data, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int(read_data, UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end
    
    //==========================================
    // Constructor
    //==========================================
    function new(string name = "my_seq_item");
        super.new(name);
    endfunction
    
    //==========================================
    // Helper functions
    //==========================================
    function bit is_write();
        return (rw == 0);
    endfunction
    
    function bit is_read();
        return (rw == 1);
    endfunction
    
    //==========================================
    // Convert to string for debugging
    //==========================================
    function string convert2string();
        string s;
        s = $sformatf("I2C Transaction: addr=0x%0h (%s)", 
                      address, 
                      rw ? "READ" : "WRITE");
        if (is_write()) begin
            s = {s, $sformatf(", data_in=0x%0h", data_in)};
            if (num_bytes > 1) begin
                s = {s, $sformatf(", multi-byte(%0d): ", num_bytes)};
                foreach(write_data[i])
                    s = {s, $sformatf("0x%0h ", write_data[i])};
            end
        end else begin
            s = {s, $sformatf(", data_out=0x%0h", data_out)};
            if (num_bytes > 1) begin
                s = {s, $sformatf(", multi-byte(%0d): ", num_bytes)};
                foreach(read_data[i])
                    s = {s, $sformatf("0x%0h ", read_data[i])};
            end
        end
        s = {s, $sformatf(", ack=%0d, nack=%0d", ack_received, generate_nack)};
        return s;
    endfunction
    
    //==========================================
    // Post-randomize to setup multi-byte data
    //==========================================
    function void post_randomize();
        if (num_bytes > 1) begin
            if (is_write() && write_data.size() == 0) begin
                write_data = new[num_bytes];
                foreach(write_data[i])
                    write_data[i] = $urandom_range(0, 255);
            end
            if (is_read() && read_data.size() == 0) begin
                read_data = new[num_bytes];
                foreach(read_data[i])
                    read_data[i] = $urandom_range(0, 255);
            end
        end
    endfunction
    
endclass