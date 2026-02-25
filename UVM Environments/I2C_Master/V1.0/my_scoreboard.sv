class my_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(my_scoreboard)

    // ------------------------------------------
    // Scoreboard components
    // ------------------------------------------
    my_seq_item item;
    
    // ------------------------------------------
    // Analysis export implementation
    // ------------------------------------------
    `uvm_analysis_imp_decl(_simple)
    uvm_analysis_imp_simple #(my_seq_item, my_scoreboard) agent_aep;

    // ------------------------------------------
    // FIFO declaration
    // ------------------------------------------
    protected uvm_tlm_analysis_fifo #(my_seq_item) item_fifo;

    // ------------------------------------------
    // Report Counters
    // ------------------------------------------
    int compared_pass;
    int compared_fail;

    // ------------------------------------------
    // Constructor
    // ------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
        compared_pass = 0;
        compared_fail = 0;
    endfunction : new
    // ------------------------------------------
    // UVM phases
    // ------------------------------------------
    // ------------------------------------------
    // Run phase
    // ------------------------------------------
    task run_phase(uvm_phase phase);
        // todo
    endtask : run_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent_aep  = new("agent_aep" , this);

        item_fifo = new("item_fifo" ,this);

        item = my_seq_item::type_id::create("item");

    endfunction : build_phase

    // function void report_phase(uvm_phase phase);
    //     string pass_fail_msg;
    //     string seed_string;
    //     begin
    //         if (!compared_pass && !compared_fail ) `uvm_warning(get_type_name(), "No comparisons between RTL and reference model were done.")
    //         else begin
    //             void'($value$plusargs("ntb_random_seed=%s", seed_string));

    //             pass_fail_msg = "\n----------------------- Final Report ------------------------------------\n";
    //             pass_fail_msg = {pass_fail_msg,$sformatf("Testcase: %s\n",uvm_root::get().top_levels[0].get_type_name())};
    //             pass_fail_msg = {pass_fail_msg,$sformatf("Seed: %s\n",seed_string)};
    //             pass_fail_msg = {pass_fail_msg,$sformatf("compared_pass: %0d\n",compared_pass)};
    //             pass_fail_msg = {pass_fail_msg,$sformatf("compared_fail: %0d\n",compared_fail)};
    //             if (!compared_fail) pass_fail_msg = {pass_fail_msg,"Simulation: PASSED"};
    //             else pass_fail_msg = {pass_fail_msg,"Simulation: FAILED"};
    //         end
    //         pass_fail_msg = {pass_fail_msg,"\n-------------------------------------------------------------------------\n\n"};

    //         `uvm_info(get_type_name(),$sformatf("%0s",pass_fail_msg),UVM_LOW)
    //     end
    // endfunction : report_phase
    // ------------------------------------------
    // Write methods
    // ------------------------------------------
    function void write_simple(my_seq_item item);
        my_seq_item item_clone;
        $cast(item_clone,item);
        
        item_fifo.write(item_clone);
    endfunction : write_simple

endclass :  my_scoreboard
