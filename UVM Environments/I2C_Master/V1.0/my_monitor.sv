//==================================================
// 5. Monitor — observa sinais e cria transações
//==================================================
class my_monitor extends uvm_monitor;
    `uvm_component_utils(my_monitor)
    
    virtual simple_if vif;

    my_seq_item item;
    
    uvm_analysis_port #(my_seq_item) mon_ap;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction // new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db #(virtual simple_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Interface nao encontrada!")
        end
        
        item = my_seq_item::type_id::create("item");
    endfunction // build_phase
    
    task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
	        #1;
            item.data_in = vif.data_in;
            item.data_out = vif.data_out;
            item.enable = vif.enable;
            item.print();
            mon_ap.write(item);
        end
    endtask // run_phase
    
endclass
