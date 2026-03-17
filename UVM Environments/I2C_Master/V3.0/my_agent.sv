// 6. Agent — groups driver, monitor and sequencer

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
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction // new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration from config DB
        get_agent_config();
        
        // Create analysis port
        agent_ap = new("agent_ap", this);
        
        // Create monitor (always present)
        mon = my_monitor::type_id::create("mon", this);
        
        // Create sequencer and driver only if active
        if (is_active) begin
            seqr = uvm_sequencer #(my_seq_item)::type_id::create("seqr", this);
            drv = my_driver::type_id::create("drv", this);
            `uvm_info(get_type_name(), "Agent configured as ACTIVE", UVM_MEDIUM)
        end
        else begin
            `uvm_info(get_type_name(), "Agent configured as PASSIVE", UVM_MEDIUM)
        end
        
        `uvm_info(get_type_name(), $sformatf("Agent built with is_active=%0d", is_active), UVM_HIGH)
    endfunction // build_phase
    
    // Get configuration from UVM config DB
    function void get_agent_config();
        // CORREÇÃO: Adicionado void'() para evitar warnings de function called as task
        void'(uvm_config_db #(bit)::get(this, "", "is_active", is_active));
        void'(uvm_config_db #(string)::get(this, "", "interface_name", interface_name));
        
        `uvm_info(get_type_name(), $sformatf("Agent config: is_active=%0d, interface_name=%s", 
                  is_active, interface_name), UVM_LOW)
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
        // Agent-level run tasks could go here
        super.run_phase(phase);
    endtask
    
    // Function to check if agent is active
    function bit is_active_agent();
        return is_active;
    endfunction
    
    // Report phase
    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Agent report: is_active=%0d", is_active), UVM_MEDIUM)
    endfunction
    
endclass // my_agent