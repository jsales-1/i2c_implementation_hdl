// 6. Agent — groups driver, monitor and sequencer for slave
class my_agent extends uvm_agent;
    `uvm_component_utils(my_agent)
    
    // Analysis port
    uvm_analysis_port #(my_seq_item) agent_ap;
    
    // Components
    my_driver drv;
    my_monitor mon;
    uvm_sequencer #(my_seq_item) seqr;
    
    // Configuration
    bit is_active = 1;  // 1 = active agent (has driver), 0 = passive agent (monitor only)
    string interface_name = "vif";
    bit enable_transaction_tracing = 1;
    int max_transactions = 0;  // 0 = unlimited
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction // new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration from config DB with void'() to avoid warnings
        get_agent_config();
        
        // Create analysis port
        agent_ap = new("agent_ap", this);
        
        // Create monitor (always present)
        mon = my_monitor::type_id::create("mon", this);
        
        // Configure monitor if needed
        configure_monitor();
        
        // Create sequencer and driver only if active
        if (is_active) begin
            seqr = uvm_sequencer #(my_seq_item)::type_id::create("seqr", this);
            drv = my_driver::type_id::create("drv", this);
            
            // Configure driver
            configure_driver();
            
            `uvm_info(get_type_name(), "Agent configured as ACTIVE", UVM_MEDIUM)
        end
        else begin
            `uvm_info(get_type_name(), "Agent configured as PASSIVE", UVM_MEDIUM)
        end
        
        `uvm_info(get_type_name(), $sformatf("Agent built with is_active=%0d, tracing=%0d", 
                  is_active, enable_transaction_tracing), UVM_HIGH)
    endfunction // build_phase
    
    // Get configuration from UVM config DB
    function void get_agent_config();
        void'(uvm_config_db #(bit)::get(this, "", "is_active", is_active));
        void'(uvm_config_db #(string)::get(this, "", "interface_name", interface_name));
        void'(uvm_config_db #(bit)::get(this, "", "enable_transaction_tracing", enable_transaction_tracing));
        void'(uvm_config_db #(int)::get(this, "", "max_transactions", max_transactions));
        
        `uvm_info(get_type_name(), $sformatf("Agent config: is_active=%0d, interface_name=%s, tracing=%0d, max_trans=%0d", 
                  is_active, interface_name, enable_transaction_tracing, max_transactions), UVM_LOW)
    endfunction
    
    // Configure monitor with agent settings
    function void configure_monitor();
        // Pass configuration to monitor via config DB
        uvm_config_db #(bit)::set(this, "mon", "enable_tracing", enable_transaction_tracing);
        `uvm_info(get_type_name(), "Monitor configured", UVM_HIGH)
    endfunction
    
    // Configure driver with agent settings
    function void configure_driver();
        // Pass configuration to driver via config DB
        uvm_config_db #(int)::set(this, "drv", "max_transactions", max_transactions);
        `uvm_info(get_type_name(), "Driver configured", UVM_HIGH)
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect monitor analysis port to agent analysis port
        mon.mon_ap.connect(agent_ap);
        
        // Connect driver and sequencer if active
        if (is_active) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
            `uvm_info(get_type_name(), "Driver connected to sequencer", UVM_HIGH)
        end
        
        `uvm_info(get_type_name(), "Agent connections completed", UVM_HIGH)
    endfunction
    
    // Run phase - optional startup tasks
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Agent run phase started", UVM_HIGH)
        
        // Monitor agent activity if tracing enabled
        if (enable_transaction_tracing) begin
            fork
                monitor_agent_activity();
            join_none
        end
        
        super.run_phase(phase);
    endtask
    
    // Monitor agent activity (for debugging) - VERSÃO CORRIGIDA
    task monitor_agent_activity();
        int transaction_count = 0;
        
        forever begin
            #100;
            
            // CORREÇÃO: Não usar get_seq_item_export() que não existe
            // Apenas mostrar que o monitor está ativo
            if (is_active) begin
                `uvm_info(get_type_name(), $sformatf("Agent active, transaction count = %0d", 
                          transaction_count), UVM_HIGH)
            end
            
            transaction_count++;
            if (max_transactions > 0 && transaction_count >= max_transactions) begin
                `uvm_info(get_type_name(), "Max transactions reached", UVM_LOW)
                break;
            end
        end
    endtask
    
    // Function to check if agent is active
    function bit is_active_agent();
        return is_active;
    endfunction
    
    // Function to get sequencer handle
    function uvm_sequencer #(my_seq_item) get_sequencer();
        return seqr;
    endfunction
    
    // Function to get monitor handle
    function my_monitor get_monitor();
        return mon;
    endfunction
    
    // Function to get driver handle
    function my_driver get_driver();
        return drv;
    endfunction
    
    // Report phase
    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Agent report: is_active=%0d, tracing=%0d", 
                  is_active, enable_transaction_tracing), UVM_MEDIUM)
    endfunction
    
endclass // my_agent

// Extended agent with factory override example
class my_extended_agent extends my_agent;
    `uvm_component_utils(my_extended_agent)
    
    // Additional component for extended functionality
    uvm_analysis_port #(my_seq_item) extended_ap;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create additional analysis port
        extended_ap = new("extended_ap", this);
        
        `uvm_info(get_type_name(), "Extended agent build phase completed", UVM_LOW)
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect to extended port as well
        mon.mon_ap.connect(extended_ap);
        
        `uvm_info(get_type_name(), "Extended agent connections completed", UVM_LOW)
    endfunction
endclass