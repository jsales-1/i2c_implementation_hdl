//==================================================
// 8. Test — cria o ambiente e inicia a sequência
//==================================================
class my_test extends uvm_test;

    `uvm_component_utils(my_test) 
    my_env env;
    my_sequence seq;
    
    function new(string name, uvm_component parent);
	super.new(name, parent);
    endfunction // new
    
    function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	env = my_env::type_id::create("env", this);
	seq = my_sequence::type_id::create("seq");
    endfunction // build_phase
    
    task run_phase(uvm_phase phase);
	phase.raise_objection(this);
	seq.start(env.agt.seqr);
	#20;
	phase.drop_objection(this);
    endtask // run_phase
endclass
