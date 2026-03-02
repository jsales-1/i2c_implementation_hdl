// 4. Driver — sends I2C master transactions to slave DUT
class my_driver extends uvm_driver #(my_seq_item);
    `uvm_component_utils(my_driver)
    
    virtual i2c_if vif;
    
    // Modo de teste (quando não há DUT real)
    bit test_mode = 0;  // 0 = modo normal, 1 = modo simulado
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction // new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual i2c_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Interface not found!")
        end
        
        // Verificar se estamos em modo de teste
        void'(uvm_config_db #(bit)::get(this, "", "test_mode", test_mode));
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
    
    // Drive a complete I2C master transaction to test the slave
    task drive_transaction(my_seq_item item);
        bit ack;
        
        `uvm_info(get_type_name(), $sformatf("Driving I2C master transaction to addr 0x%0h, rw=%0d", 
                  item.target_addr, item.rw), UVM_MEDIUM)
        
        if (test_mode) begin
            // MODO DE TESTE: Simular respostas sem DUT real
            drive_transaction_simulated(item);
        end
        else begin
            // MODO NORMAL: Driver real com DUT
            drive_transaction_real(item);
        end
    endtask
    
    // Modo real (com DUT)
    task drive_transaction_real(my_seq_item item);
        bit ack;
        
        // Generate START condition
        drive_start();
        
        // Send address + R/W bit
        drive_address(item.target_addr, item.rw);
        
        // Check for ACK from slave
        check_ack(ack);
        item.addr_ack = ack;
        
        if (!ack) begin
            `uvm_warning(get_type_name(), $sformatf("No ACK received for address 0x%0h", item.target_addr))
            drive_stop();
            return;
        end
        
        // Handle data phase based on operation
        if (item.is_write()) begin
            // Insert any programmed delay
            if (item.bit_delay > 0) begin
                repeat(item.bit_delay) @(negedge vif.scl);
            end
            
            // Drive data byte
            drive_byte(item.write_data);
            
            // Check ACK from slave
            check_ack(ack);
            item.data_ack = ack;
            
            if (!ack) begin
                `uvm_warning(get_type_name(), $sformatf("No ACK for write data 0x%0h", item.write_data))
            end
        end
        else begin
            // Insert any programmed delay
            if (item.bit_delay > 0) begin
                repeat(item.bit_delay) @(negedge vif.scl);
            end
            
            // Read data byte from slave
            read_byte(item.read_data);
            
            // Send NACK (master indicates end of read)
            send_nack();
        end
        
        // Generate STOP if requested
        if (item.generate_stop) begin
            drive_stop();
        end
        
        `uvm_info(get_type_name(), "I2C transaction completed", UVM_HIGH)
    endtask
    
    // Modo simulado (sem DUT) - para testar o ambiente UVM
    task drive_transaction_simulated(my_seq_item item);
        `uvm_info(get_type_name(), "SIMULATED MODE: Driving simulated transaction", UVM_MEDIUM)
        
        // Simular START
        #10;
        
        // Simular ACK para endereço correto
        if (item.target_addr == 7'h50) begin
            item.addr_ack = 1;
            `uvm_info(get_type_name(), $sformatf("SIMULATED: Address 0x%0h ACKed", item.target_addr), UVM_MEDIUM)
        end
        else begin
            item.addr_ack = 0;
            `uvm_info(get_type_name(), $sformatf("SIMULATED: Address 0x%0h NACKed", item.target_addr), UVM_MEDIUM)
            item.generate_stop = 1;
        end
        
        // Simular data phase
        if (item.is_write() && item.addr_ack) begin
            item.data_ack = 1;
            `uvm_info(get_type_name(), $sformatf("SIMULATED: Write data 0x%0h ACKed", item.write_data), UVM_MEDIUM)
        end
        else if (item.is_read() && item.addr_ack) begin
            item.read_data = 8'hA5;  // Dado simulado
            `uvm_info(get_type_name(), $sformatf("SIMULATED: Read data 0x%0h", item.read_data), UVM_MEDIUM)
        end
        
        // Simular STOP
        if (item.generate_stop) begin
            #10;
            `uvm_info(get_type_name(), "SIMULATED: STOP generated", UVM_MEDIUM)
        end
        
        `uvm_info(get_type_name(), "SIMULATED: Transaction completed", UVM_HIGH)
    endtask
    
    // Generate START condition
    task drive_start();
        `uvm_info(get_type_name(), "Driving START condition", UVM_HIGH)
        
        // Ensure SDA and SCL are high (released)
        vif.sda_drive_en = 1;
        vif.sda_out_tb = 1;
        vif.scl_drive_en = 1;
        vif.scl_out_tb = 1;
        @(negedge vif.scl);
        
        // START: SDA goes low while SCL is high
        vif.sda_out_tb = 0;
        @(negedge vif.scl);
    endtask
    
    // Generate STOP condition
    task drive_stop();
        `uvm_info(get_type_name(), "Driving STOP condition", UVM_HIGH)
        
        // Ensure SDA is low
        vif.sda_drive_en = 1;
        vif.sda_out_tb = 0;
        @(negedge vif.scl);
        
        // STOP: SDA goes high while SCL is high
        vif.scl_out_tb = 1;
        @(posedge vif.scl);
        vif.sda_out_tb = 1;
        @(negedge vif.scl);
        
        // Release bus
        vif.sda_drive_en = 0;
    endtask
    
    // Drive address + R/W bit
    task drive_address(bit [6:0] addr, bit rw);
        `uvm_info(get_type_name(), $sformatf("Driving address 0x%0h, rw=%0d", addr, rw), UVM_HIGH)
        
        vif.sda_drive_en = 1;
        
        // Drive 7 address bits (MSB first)
        for (int i = 6; i >= 0; i--) begin
            vif.sda_out_tb = addr[i];
            @(negedge vif.scl);
        end
        
        // Drive R/W bit
        vif.sda_out_tb = rw;
        @(negedge vif.scl);
    endtask
    
    // Drive a single data byte
    task drive_byte(bit [7:0] data);
        `uvm_info(get_type_name(), $sformatf("Driving data byte 0x%0h", data), UVM_HIGH)
        
        vif.sda_drive_en = 1;
        
        // Drive 8 data bits (MSB first)
        for (int i = 7; i >= 0; i--) begin
            vif.sda_out_tb = data[i];
            @(negedge vif.scl);
        end
    endtask
    
    // Check for ACK from slave
    task check_ack(output bit ack);
        `uvm_info(get_type_name(), "Checking ACK", UVM_HIGH)
        
        // Release SDA for slave to drive ACK
        vif.sda_drive_en = 0;
        
        // Sample ACK on rising edge of SCL
        @(posedge vif.scl);
        ack = (vif.sda == 0);  // ACK is low
        @(negedge vif.scl);
        
        `uvm_info(get_type_name(), $sformatf("ACK %sreceived", ack ? "" : "not "), UVM_HIGH)
    endtask
    
    // Read a single data byte from slave
    task read_byte(output bit [7:0] data);
        data = 0;
        
        `uvm_info(get_type_name(), "Reading data byte from slave", UVM_HIGH)
        
        // Release SDA for slave to drive
        vif.sda_drive_en = 0;
        
        // Sample 8 data bits on rising edge of SCL
        for (int i = 7; i >= 0; i--) begin
            @(posedge vif.scl);
            data[i] = vif.sda;
            @(negedge vif.scl);
        end
        
        `uvm_info(get_type_name(), $sformatf("Read data byte 0x%0h", data), UVM_HIGH)
    endtask
    
    // Send NACK to slave (for last byte of read)
    task send_nack();
        `uvm_info(get_type_name(), "Sending NACK to slave", UVM_HIGH)
        
        vif.sda_drive_en = 1;
        vif.sda_out_tb = 1;  // NACK is high
        @(negedge vif.scl);
    endtask
    
endclass