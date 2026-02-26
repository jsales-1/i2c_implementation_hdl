//==================================================
// 4. Driver — sends transactions to DUT via interface
//==================================================
class my_driver extends uvm_driver #(my_seq_item);
    `uvm_component_utils(my_driver)
    
    virtual i2c_if vif;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction // new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual i2c_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Interface not found!")
        end
    endfunction
    
    // Main driver task
    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info(get_type_name(), $sformatf("Starting transaction: %s", req.convert2string()), UVM_HIGH)
            drive_transaction(req);
            seq_item_port.item_done();
            `uvm_info(get_type_name(), $sformatf("Completed transaction: %s", req.convert2string()), UVM_HIGH)
        end
    endtask
    
    // Drive a single I2C transaction
    task drive_transaction(my_seq_item item);
        // Wait for DUT to be ready
        @(posedge vif.clk);
        while (!vif.ready) @(posedge vif.clk);
        
        // Apply stimulus to DUT
        vif.address = item.address;
        vif.data_in = item.data_in;
        vif.rw = item.rw;
        vif.enable = 1;
        
        `uvm_info(get_type_name(), $sformatf("Driving: addr=0x%0h, rw=%0d, data=0x%0h", 
                  item.address, item.rw, item.data_in), UVM_MEDIUM)  // Fixed: UVM_MEDIUM not UVV_MEDIUM
        
        // Wait for transaction to complete
        @(posedge vif.clk);
        while (!vif.ready) @(posedge vif.clk);
        
        // Capture read data if applicable
        if (item.is_read()) begin
            item.data_out = vif.data_out;
            `uvm_info(get_type_name(), $sformatf("Read data: 0x%0h", vif.data_out), UVM_MEDIUM)
        end
        
        // De-assert enable
        vif.enable = 0;
        
        // For multi-byte transfers, handle remaining bytes
        if (item.num_bytes > 1) begin
            drive_multi_byte_transfer(item);
        end
        
    endtask
    
    // Handle multi-byte transfers
    task drive_multi_byte_transfer(my_seq_item item);
        `uvm_info(get_type_name(), $sformatf("Starting multi-byte transfer (%0d bytes)", 
                  item.num_bytes), UVM_MEDIUM)
        
        if (item.is_write()) begin
            // Multi-byte write
            for (int i = 0; i < item.num_bytes; i++) begin
                // Wait for ready
                while (!vif.ready) @(posedge vif.clk);
                
                // Drive next data byte
                vif.data_in = item.write_data[i];
                vif.enable = 1;
                
                `uvm_info(get_type_name(), $sformatf("Writing byte %0d: 0x%0h", 
                          i, item.write_data[i]), UVM_HIGH)
                
                // Wait for completion
                @(posedge vif.clk);
                while (!vif.ready) @(posedge vif.clk);
                
                vif.enable = 0;
            end
        end
        else begin
            // Multi-byte read
            for (int i = 0; i < item.num_bytes; i++) begin
                // Wait for ready
                while (!vif.ready) @(posedge vif.clk);
                
                // Enable read (keep rw=1)
                vif.enable = 1;
                
                // Wait for completion
                @(posedge vif.clk);
                while (!vif.ready) @(posedge vif.clk);
                
                // Capture read data
                item.read_data[i] = vif.data_out;
                
                `uvm_info(get_type_name(), $sformatf("Reading byte %0d: 0x%0h", 
                          i, vif.data_out), UVM_HIGH)
                
                vif.enable = 0;
            end
        end
    endtask
    
endclass