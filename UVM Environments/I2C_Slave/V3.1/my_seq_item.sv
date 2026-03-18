//==================================================
// 2. Transaction — represents an I2C master transaction for slave verification
//==================================================
class my_seq_item extends uvm_sequence_item;
    // I2C master transaction fields (stimulus for slave)
    rand bit [6:0] target_addr;      // Target slave address
    rand bit [7:0] write_data;        // Data to write (for write operations)
    rand bit       rw;                 // Operation: 0 = write, 1 = read
    rand bit       generate_stop;      // Generate STOP at end
    rand int       bit_delay;          // Variable delay between bits (for testing)
    
    // Observed fields (filled by monitor - slave responses)
    bit [7:0]      read_data;          // Data read from slave (for read operations)
    bit            addr_ack;           // Slave ACKed address
    bit            data_ack;           // Slave ACKed data (for writes)
    bit            start_detected;     // START condition detected
    bit            stop_detected;      // STOP condition detected
    
    // Constraints
    constraint default_values {
        soft target_addr inside {7'h50, 7'h51, 7'h52, 7'h68}; // Common I2C addresses
        soft generate_stop == 1;
        soft bit_delay == 0;
    }
    
    `uvm_object_utils_begin(my_seq_item)
        `uvm_field_int(target_addr, UVM_DEFAULT)
        `uvm_field_int(write_data, UVM_DEFAULT)
        `uvm_field_int(rw, UVM_DEFAULT)
        `uvm_field_int(generate_stop, UVM_DEFAULT)
        `uvm_field_int(bit_delay, UVM_DEFAULT)
        `uvm_field_int(read_data, UVM_DEFAULT)
        `uvm_field_int(addr_ack, UVM_DEFAULT)
        `uvm_field_int(data_ack, UVM_DEFAULT)
        `uvm_field_int(start_detected, UVM_DEFAULT)
        `uvm_field_int(stop_detected, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name = "my_seq_item");
        super.new(name);
    endfunction
    
    // Helper function to check if it's a write operation
    function bit is_write();
        return (rw == 0);
    endfunction
    
    // Helper function to check if it's a read operation
    function bit is_read();
        return (rw == 1);
    endfunction
    
    // Convert to string for debugging
    function string convert2string();
        string s;
        s = $sformatf("I2C Master Transaction: addr=0x%0h (%s)", 
                      target_addr, rw ? "READ" : "WRITE");
        
        if (is_write()) begin
            s = {s, $sformatf(", write_data=0x%0h", write_data)};
        end
        else begin
            s = {s, $sformatf(", read_data=0x%0h", read_data)};
        end
        
        s = {s, $sformatf(", addr_ack=%0d, data_ack=%0d", addr_ack, data_ack)};
        s = {s, $sformatf(", start=%0d, stop=%0d", start_detected, stop_detected)};
        
        return s;
    endfunction
    
endclass