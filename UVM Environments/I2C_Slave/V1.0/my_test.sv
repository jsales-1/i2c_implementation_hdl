//==================================================
// 8. Test — creates environment and starts sequence
//==================================================
class my_test extends uvm_test;

    `uvm_component_utils(my_test) 
    
    my_env env;
    my_sequence seq;
    
    // Test configuration
    int num_transactions = 10;
    bit [6:0] test_address = 7'h50;
    string test_type = "basic";  // basic, write, read, error, stress
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction // new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = my_env::type_id::create("env", this);
        
        // Get test configuration from command line
        void'($value$plusargs("NUM_TRANS=%0d", num_transactions));
        void'($value$plusargs("ADDRESS=0x%h", test_address));
        void'($value$plusargs("TEST_TYPE=%s", test_type));
        
        `uvm_info(get_type_name(), $sformatf("Test configuration: type=%s, num_trans=%0d, addr=0x%0h", 
                  test_type, num_transactions, test_address), UVM_LOW)
    endfunction // build_phase
    
    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Starting I2C slave test simulation", UVM_LOW)
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        case (test_type)
            "write": begin
                write_sequence write_seq;
                write_seq = write_sequence::type_id::create("write_seq");
                write_seq.num_writes = num_transactions;
                write_seq.target_address = test_address;
                `uvm_info(get_type_name(), "Starting write-only sequence", UVM_LOW)
                write_seq.start(env.agt.seqr);
            end
            
            "read": begin
                read_sequence read_seq;
                read_seq = read_sequence::type_id::create("read_seq");
                read_seq.num_reads = num_transactions;
                read_seq.target_address = test_address;
                `uvm_info(get_type_name(), "Starting read-only sequence", UVM_LOW)
                read_seq.start(env.agt.seqr);
            end
            
            "error": begin
                error_sequence error_seq;
                error_seq = error_sequence::type_id::create("error_seq");
                error_seq.num_errors = num_transactions;
                error_seq.target_address = test_address;
                `uvm_info(get_type_name(), "Starting error injection sequence", UVM_LOW)
                error_seq.start(env.agt.seqr);
            end
            
            "stress": begin
                stress_sequence stress_seq;
                stress_seq = stress_sequence::type_id::create("stress_seq");
                stress_seq.num_transactions = num_transactions;
                stress_seq.target_address = test_address;
                `uvm_info(get_type_name(), "Starting stress test sequence", UVM_LOW)
                stress_seq.start(env.agt.seqr);
            end
            
            default: begin  // basic
                seq = my_sequence::type_id::create("seq");
                seq.num_transactions = num_transactions;
                seq.target_address = test_address;
                `uvm_info(get_type_name(), "Starting basic mixed sequence", UVM_LOW)
                seq.start(env.agt.seqr);
            end
        endcase
        
        #20;
        phase.drop_objection(this);
    endtask // run_phase
    
    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "I2C slave test completed", UVM_LOW)
    endfunction
    
endclass

// Specialized test classes
class write_test extends my_test;
    `uvm_component_utils(write_test)
    function new(string name, uvm_component parent);
        super.new(name, parent);
        test_type = "write";
    endfunction
endclass

class read_test extends my_test;
    `uvm_component_utils(read_test)
    function new(string name, uvm_component parent);
        super.new(name, parent);
        test_type = "read";
    endfunction
endclass

class error_test extends my_test;
    `uvm_component_utils(error_test)
    function new(string name, uvm_component parent);
        super.new(name, parent);
        test_type = "error";
    endfunction
endclass

class stress_test extends my_test;
    `uvm_component_utils(stress_test)
    function new(string name, uvm_component parent);
        super.new(name, parent);
        test_type = "stress";
    endfunction
endclass