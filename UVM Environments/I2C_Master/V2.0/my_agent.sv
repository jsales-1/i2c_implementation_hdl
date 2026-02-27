//================================================== 
// 6. Agent — groups driver, monitor and sequencer
//================================================== 
class my_agent extends uvm_agent; 
    `uvm_component_utils(my_agent)
    
    uvm_analysis_port #(my_seq_item) agent_ap;
    
    my_driver drv;
    my_monitor mon;
    uvm_sequencer #(my_seq_item) seqr;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction // new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent_ap = new("agent_ap", this);
        drv = my_driver::type_id::create("drv", this);
        mon = my_monitor::type_id::create("mon", this);
        seqr = uvm_sequencer #(my_seq_item)::type_id::create("seqr", this);
    endfunction // build_phase
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Connect monitor analysis port to agent analysis port
        agent_ap = mon.mon_ap;
        // Connect driver and sequencer
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
    
endclass // my_agent