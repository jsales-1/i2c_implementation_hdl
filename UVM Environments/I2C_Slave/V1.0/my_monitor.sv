//==================================================
// 5. Monitor — observes I2C bus and slave responses
//==================================================
class my_monitor extends uvm_monitor;
    `uvm_component_utils(my_monitor)
    
    virtual i2c_if vif;
    
    uvm_analysis_port #(my_seq_item) mon_ap;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction // new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db #(virtual i2c_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Interface not found!")
        end
    endfunction // build_phase
    
    task run_phase(uvm_phase phase);
        fork
            monitor_i2c_bus();
            monitor_slave_signals();
        join
    endtask // run_phase
    
    // Main monitoring task - observes I2C bus and reconstructs transactions
    task monitor_i2c_bus();
        my_seq_item captured_item;
        logic [6:0] addr;
        logic rw_bit;
        logic [7:0] data_byte;
        bit in_transaction;
        bit is_write;
        logic sda_last, scl_last;
        int bit_count;
        
        sda_last = vif.sda;
        scl_last = vif.scl;
        
        forever begin
            @(vif.scl or vif.sda);
            
            // Check for START condition (SDA falling while SCL high)
            if (scl_last == 1 && vif.scl == 1 && sda_last == 1 && vif.sda == 0) begin
                `uvm_info(get_type_name(), "START condition detected", UVM_MEDIUM)
                
                // Start new transaction
                captured_item = my_seq_item::type_id::create("captured_item");
                captured_item.start_detected = 1;
                captured_item.generate_stop = 0;
                bit_count = 0;
                in_transaction = 1;
                addr = 0;
                
                // Capture address bits
                while (bit_count < 7) begin
                    @(posedge vif.scl);
                    addr[6-bit_count] = vif.sda;
                    bit_count++;
                end
                
                // Capture R/W bit
                @(posedge vif.scl);
                rw_bit = vif.sda;
                bit_count = 0;
                
                captured_item.target_addr = addr;
                captured_item.rw = rw_bit;
                is_write = (rw_bit == 0);
                
                `uvm_info(get_type_name(), $sformatf("Address captured: 0x%0h, %s", 
                          addr, is_write ? "WRITE" : "READ"), UVM_MEDIUM)
                
                // Check for ACK from slave (on next SCL after address)
                @(negedge vif.scl);
                @(posedge vif.scl);
                captured_item.addr_ack = (vif.sda == 0);
                
                `uvm_info(get_type_name(), $sformatf("Address ACK: %0d", 
                          captured_item.addr_ack), UVM_HIGH)
                
                @(negedge vif.scl);
            end
            
            // Check for STOP condition (SDA rising while SCL high)
            else if (scl_last == 1 && vif.scl == 1 && sda_last == 0 && vif.sda == 1) begin
                `uvm_info(get_type_name(), "STOP condition detected", UVM_MEDIUM)
                
                if (in_transaction) begin
                    captured_item.stop_detected = 1;
                    captured_item.generate_stop = 1;
                    
                    `uvm_info(get_type_name(), $sformatf("Transaction complete: %s", 
                              captured_item.convert2string()), UVM_MEDIUM)
                    
                    // Send to scoreboard
                    mon_ap.write(captured_item);
                    in_transaction = 0;
                end
            end
            
            // Monitor data during transaction
            else if (in_transaction && vif.scl == 1 && scl_last == 0) begin
                // Rising edge of SCL - sample data
                if (is_write) begin
                    // Master write: capture data from bus
                    data_byte = {data_byte[6:0], vif.sda};
                    bit_count++;
                    
                    if (bit_count == 8) begin
                        captured_item.write_data = data_byte;
                        `uvm_info(get_type_name(), $sformatf("Captured write data: 0x%0h", 
                                  data_byte), UVM_HIGH)
                        bit_count = 0;
                        
                        // After 8 bits, check ACK on next falling edge
                        @(negedge vif.scl);
                        @(posedge vif.scl);
                        captured_item.data_ack = (vif.sda == 0);
                        @(negedge vif.scl);
                    end
                end
                else begin
                    // Master read: capture data from slave
                    data_byte = {data_byte[6:0], vif.sda};
                    bit_count++;
                    
                    if (bit_count == 8) begin
                        captured_item.read_data = data_byte;
                        `uvm_info(get_type_name(), $sformatf("Captured read data: 0x%0h", 
                                  data_byte), UVM_HIGH)
                        bit_count = 0;
                    end
                end
            end
            
            sda_last = vif.sda;
            scl_last = vif.scl;
        end
    endtask
    
    // Monitor slave DUT signals directly
    task monitor_slave_signals();
        forever begin
            @(posedge vif.clk);
            // Monitor slave status
            `uvm_info(get_type_name(), $sformatf("Slave: data_received=0x%0h, data_to_send=0x%0h", 
                      vif.data_received, vif.data_to_send), UVM_HIGH)
        end
    endtask
    
endclass