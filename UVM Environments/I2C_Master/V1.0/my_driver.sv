//==================================================
// 4. Driver — envia transações para o DUT via interface
//==================================================
class my_driver extends uvm_driver #(my_seq_item);
    `uvm_component_utils(my_driver)
    
    virtual simple_if vif;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction // new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual simple_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Interface nao encontrada!")
        end
    endfunction
    
    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            @(posedge vif.clk);
            vif.enable = req.enable;
            vif.data_in = req.data_in;
            // req.print();
            seq_item_port.item_done();
        end
    endtask
endclass
