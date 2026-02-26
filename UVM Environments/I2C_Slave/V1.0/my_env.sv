//==================================================
// 7. Environment — groups agent and scoreboard
//==================================================
class my_env extends uvm_env;
    `uvm_component_utils(my_env) 
    
    my_agent agt;
    my_scoreboard scb;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction // new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = my_agent::type_id::create("agt", this);
        scb = my_scoreboard::type_id::create("scb", this);
    endfunction // build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.agent_ap.connect(scb.agent_aep);
    endfunction
    
endclass