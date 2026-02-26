//==================================================
// 5. Monitor — observes signals and creates transactions
//==================================================
class my_monitor extends uvm_monitor;
    `uvm_component_utils(my_monitor)
    
    virtual i2c_if vif;
    
    my_seq_item item;
    
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
        
        item = my_seq_item::type_id::create("item");
    endfunction // build_phase
    
    task run_phase(uvm_phase phase);
        fork
            monitor_dut_signals();
            monitor_i2c_bus();
        join
    endtask // run_phase
    
    // Monitor DUT control signals
    task monitor_dut_signals();
        my_seq_item captured_item;
        logic enable_last;
        
        enable_last = vif.enable;
        
        forever begin
            @(posedge vif.clk);
            
            // Detect new transaction start (enable rising edge)
            if (vif.enable && !enable_last) begin
                captured_item = my_seq_item::type_id::create("captured_item");
                
                // Capture transaction start info
                captured_item.address = vif.address;
                captured_item.rw = vif.rw;
                captured_item.data_in = vif.data_in;
                captured_item.start_detected = 1;
                
                `uvm_info(get_type_name(), $sformatf("Transaction started: addr=0x%0h, rw=%0d, data=0x%0h", 
                          vif.address, vif.rw, vif.data_in), UVM_MEDIUM)
                
                // Wait for transaction to complete
                wait_for_transaction_complete(captured_item);
                
                // Send to analysis port
                `uvm_info(get_type_name(), $sformatf("Transaction complete: %s", 
                          captured_item.convert2string()), UVM_MEDIUM)
                mon_ap.write(captured_item);
            end
            
            enable_last = vif.enable;
        end
    endtask
    
    // Wait for transaction to complete and capture results
    task wait_for_transaction_complete(my_seq_item item);
        // Wait for ready to go high indicating completion
        @(posedge vif.clk);
        while (!vif.ready) @(posedge vif.clk);
        
        // Capture read data if applicable
        if (item.is_read()) begin
            item.data_out = vif.data_out;
        end
        
        // Capture final status
        item.stop_detected = 1;
        
        // Small delay to ensure all signals are stable
        #1;
    endtask
    
    // Monitor I2C bus directly (for protocol checking)
    task monitor_i2c_bus();
        logic sda_last, scl_last;
        logic [6:0] captured_addr;
        logic [7:0] captured_data;
        int bit_count;
        bit in_transfer;
        
        sda_last = vif.i2c_sda;
        scl_last = vif.i2c_scl;
        
        forever begin
            @(posedge vif.i2c_scl);
            
            // Detect START condition (SDA falling while SCL high)
            if (scl_last == 1 && vif.i2c_scl == 1 && sda_last == 1 && vif.i2c_sda == 0) begin
                `uvm_info(get_type_name(), $sformatf("[I2C BUS] START condition detected"), UVM_HIGH)
                in_transfer = 1;
                bit_count = 0;
                captured_addr = 0;
            end
            
            // Detect STOP condition (SDA rising while SCL high)
            else if (scl_last == 1 && vif.i2c_scl == 1 && sda_last == 0 && vif.i2c_sda == 1) begin
                `uvm_info(get_type_name(), $sformatf("[I2C BUS] STOP condition detected"), UVM_HIGH)
                in_transfer = 0;
            end
            
            // Sample data on rising edge of SCL during transfer
            else if (in_transfer) begin
                if (bit_count < 8) begin
                    // Capturing address or data
                    if (bit_count < 7) begin
                        captured_addr[6-bit_count] = vif.i2c_sda;
                    end
                    else if (bit_count == 7) begin
                        // Last address bit is R/W
                        `uvm_info(get_type_name(), $sformatf("[I2C BUS] Address 0x%0h, RW=%0d", 
                                  captured_addr, vif.i2c_sda), UVM_HIGH)
                    end
                end
            end
            
            sda_last = vif.i2c_sda;
            scl_last = vif.i2c_scl;
        end
    endtask
    
endclass