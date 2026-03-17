//==================================================
// 5. Monitor — observes I2C bus and slave responses
//==================================================
class my_monitor extends uvm_monitor;
    `uvm_component_utils(my_monitor)
    
    virtual i2c_if vif;
    
    uvm_analysis_port #(my_seq_item) mon_ap;
    
    // Modo de teste
    bit test_mode = 0;
    
    // Queue estática para comunicação driver-monitor
    static my_seq_item driver_monitor_queue[$];
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction // new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db #(virtual i2c_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Interface not found!")
        end
        
        // Verificar se estamos em modo de teste
        void'(uvm_config_db #(bit)::get(this, "", "test_mode", test_mode));
    endfunction // build_phase
    
    // Task para driver adicionar item à fila - AGORA NÃO ESTÁTICA
    function void add_driver_item(my_seq_item item);
        my_seq_item item_clone;
        $cast(item_clone, item.clone());
        driver_monitor_queue.push_back(item_clone);
        `uvm_info("my_monitor", $sformatf("Item added to queue. Queue size: %0d", 
                  driver_monitor_queue.size()), UVM_HIGH)
    endfunction
        // Adicionar este método na classe my_monitor (após add_driver_item)
    function int get_queue_size();
        return driver_monitor_queue.size();
    endfunction
    task run_phase(uvm_phase phase);
        if (test_mode) begin
            `uvm_info(get_type_name(), "Running in TEST MODE - generating simulated transactions", UVM_LOW)
            fork
                generate_simulated_transactions();
            join_none
        end
        else begin
            fork
                monitor_i2c_bus();
                monitor_slave_signals();
            join
        end
    endtask // run_phase
    
    // Gerar transações simuladas para teste do ambiente
    task generate_simulated_transactions();
        my_seq_item simulated_item;
        int transaction_count = 0;
        int max_transactions = 10;
        
        `uvm_info(get_type_name(), "Starting simulated transaction generation", UVM_LOW)
        
        // Pequeno delay para sincronização inicial
        #50;
        
        // Gerar transações até atingir o máximo
        while (transaction_count < max_transactions) begin
            // Aguarda até ter um item do driver (com timeout)
            fork
                begin
                    wait (driver_monitor_queue.size() > 0);
                end
                begin
                    #1000; // Timeout de segurança
                    `uvm_error(get_type_name(), "Timeout waiting for driver item")
                end
            join_any;
            disable fork;
            
            // Se tem item na fila, processa
            if (driver_monitor_queue.size() > 0) begin
                // Pega o próximo item da fila (FIFO)
                simulated_item = driver_monitor_queue.pop_front();
                
                // Garantir que os flags estão corretos
                simulated_item.start_detected = 1;
                simulated_item.stop_detected = 1;
                
                `uvm_info(get_type_name(), $sformatf("SIMULATED: Generated transaction %0d: %s", 
                          transaction_count, simulated_item.convert2string()), UVM_MEDIUM)
                
                // Enviar para o scoreboard
                mon_ap.write(simulated_item);
                transaction_count++;
            end
        end
        
        `uvm_info(get_type_name(), $sformatf("SIMULATED: Generated %0d transactions", 
                  transaction_count), UVM_LOW)
    endtask
    
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