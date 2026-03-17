//==================================================
// 8. Test — creates environment and starts sequence
//==================================================

//==================================================
// Base Test with Factory & Configuration support
//==================================================
class my_test extends uvm_test;

    `uvm_component_utils(my_test) 
    
    my_env env;
    
    // Configuration objects
    my_seq_item item_config;
    
    // Test configuration
    int num_transactions = 10;
    bit [6:0] test_address = 7'h50;
    string test_type = "basic";
    string sequence_name = "my_sequence";
    
    // Factory override control
    bit use_factory_overrides = 0;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction // new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get test configuration from command line
        void'($value$plusargs("NUM_TRANS=%0d", num_transactions));
        void'($value$plusargs("ADDRESS=0x%h", test_address));
        void'($value$plusargs("TEST_TYPE=%s", test_type));
        void'($value$plusargs("SEQUENCE_NAME=%s", sequence_name));
        void'($value$plusargs("USE_OVERRIDES=%0d", use_factory_overrides));
        
        // Create configuration object
        item_config = my_seq_item::type_id::create("item_config");
        configure_item();
        
        // Set configuration in config DB
        uvm_config_db #(my_seq_item)::set(this, "*", "item_config", item_config);
        
        //==========================================
        // FACTORY OVERRIDE EXAMPLES
        //==========================================
        if (use_factory_overrides) begin
            apply_factory_overrides();
        end
        
        // Create environment
        env = my_env::type_id::create("env", this);
        
        `uvm_info(get_type_name(), $sformatf("Test configuration: type=%s, num_trans=%0d, addr=0x%0h, overrides=%0d", 
                  test_type, num_transactions, test_address, use_factory_overrides), UVM_LOW)
    endfunction // build_phase
    
    // Configure the item with test-specific settings
    virtual function void configure_item();
        // This can be overridden in child tests
        `uvm_info(get_type_name(), "Configuring sequence item defaults", UVM_HIGH)
    endfunction
    
    // Apply factory overrides
    virtual function void apply_factory_overrides();
        `uvm_info(get_type_name(), "Applying factory overrides", UVM_LOW)
        
        // Example 1: Override sequence type
        // This would replace my_sequence with write_sequence wherever created
        // set_type_override_by_type(my_sequence::get_type(), write_sequence::get_type());
        
        // Example 2: Override specific instance
        // set_inst_override_by_type("env.agt.seqr.*.my_sequence", 
        //                            my_sequence::get_type(), 
        //                            write_sequence::get_type());
        
        // Example 3: Override transaction item
        // set_type_override_by_type(my_seq_item::get_type(), extended_seq_item::get_type());
        
        `uvm_info(get_type_name(), "Factory overrides applied", UVM_LOW)
    endfunction
    
    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Starting I2C test simulation", UVM_LOW)
        print_test_info();
    endfunction
    
    virtual function void print_test_info();
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
        `uvm_info(get_type_name(), "I2C Test Information:", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Test Type: %s", test_type), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Transactions: %0d", num_transactions), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Target Address: 0x%0h", test_address), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Sequence: %s", sequence_name), UVM_LOW)
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
    endfunction
    
    task run_phase(uvm_phase phase);
        uvm_sequence #(my_seq_item) seq;
        
        phase.raise_objection(this);
        
        // Create sequence using factory
        seq = create_sequence(sequence_name);
        
        if (seq == null) begin
            `uvm_fatal(get_type_name(), $sformatf("Failed to create sequence: %s", sequence_name))
        end
        
        // Configure sequence before starting
        configure_sequence(seq);
        
        `uvm_info(get_type_name(), $sformatf("Starting sequence: %s", sequence_name), UVM_LOW)
        
        // Start the sequence
        seq.start(env.agt.seqr);
        
        #20;  // Allow time for final transactions to complete
        phase.drop_objection(this);
    endtask // run_phase
    
    // Factory method to create sequences
    virtual function uvm_sequence #(my_seq_item) create_sequence(string name);
        uvm_sequence #(my_seq_item) seq;
        
        // Use factory to create sequence by name
        if (!$cast(seq, uvm_factory::get().create_object_by_name(name, 
                                            get_full_name(), 
                                            name))) begin
            `uvm_error(get_type_name(), $sformatf("Failed to create sequence: %s", name))
            return null;
        end
        
        return seq;
    endfunction
    
    // Configure sequence with test parameters
    virtual function void configure_sequence(uvm_sequence #(my_seq_item) seq);
        string seq_type = seq.get_type_name();
        
        `uvm_info(get_type_name(), $sformatf("Configuring sequence of type: %s", seq_type), UVM_HIGH)
        
        // Configure based on sequence type
        if (seq_type == "my_sequence") begin
            my_sequence m_seq;
            if ($cast(m_seq, seq)) begin
                m_seq.num_transactions = num_transactions;
                m_seq.target_address = test_address;
            end
        end
        else if (seq_type == "write_sequence") begin
            write_sequence w_seq;
            if ($cast(w_seq, seq)) begin
                w_seq.num_writes = num_transactions;
                w_seq.target_address = test_address;
            end
        end
        else if (seq_type == "read_sequence") begin
            read_sequence r_seq;
            if ($cast(r_seq, seq)) begin
                r_seq.num_reads = num_transactions;
                r_seq.target_address = test_address;
            end
        end
        else if (seq_type == "multi_byte_sequence") begin
            multi_byte_sequence m_seq;
            if ($cast(m_seq, seq)) begin
                m_seq.num_transfers = num_transactions;
                m_seq.target_address = test_address;
            end
        end
        else if (seq_type == "error_sequence") begin
            error_sequence e_seq;
            if ($cast(e_seq, seq)) begin
                e_seq.num_errors = num_transactions;
            end
        end
        else if (seq_type == "stress_sequence") begin
            stress_sequence s_seq;
            if ($cast(s_seq, seq)) begin
                s_seq.num_transactions = num_transactions;
            end
        end
    endfunction
    
    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "I2C test completed", UVM_LOW)
    endfunction
    
endclass

//==================================================
// Extended Test with Factory Override Example
//==================================================
class override_test extends my_test;
    `uvm_component_utils(override_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        test_type = "override";
    endfunction
    
    virtual function void apply_factory_overrides();
        super.apply_factory_overrides();
        
        `uvm_info(get_type_name(), "Applying specific factory overrides for override_test", UVM_LOW)
        
        // Override all my_sequence instances with write_sequence
        set_type_override_by_type(my_sequence::get_type(), write_sequence::get_type());
        
        `uvm_info(get_type_name(), "All my_sequence instances will now be write_sequence", UVM_LOW)
    endfunction
endclass

//==================================================
// Specialized test classes with configurations
//==================================================

// Write test with configuration
class write_test extends my_test;
    `uvm_component_utils(write_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        test_type = "write";
        sequence_name = "write_sequence";
    endfunction
    
    virtual function void configure_item();
        super.configure_item();
        `uvm_info(get_type_name(), "Configuring for write test", UVM_LOW)
        // Additional write-specific configuration could go here
    endfunction
endclass

// Read test
class read_test extends my_test;
    `uvm_component_utils(read_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        test_type = "read";
        sequence_name = "read_sequence";
    endfunction
endclass

// Multi-byte test
class multi_byte_test extends my_test;
    `uvm_component_utils(multi_byte_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        test_type = "multi";
        sequence_name = "multi_byte_sequence";
    endfunction
endclass

// Error test
class error_test extends my_test;
    `uvm_component_utils(error_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        test_type = "error";
        sequence_name = "error_sequence";
    endfunction
endclass

// Stress test
class stress_test extends my_test;
    `uvm_component_utils(stress_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        test_type = "stress";
        sequence_name = "stress_sequence";
    endfunction
endclass

//==================================================
// Configuration-based test
//==================================================
class config_test extends my_test;
    `uvm_component_utils(config_test)
    
    // Additional configuration
    int write_ratio = 75;
    bit enable_nack = 0;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        test_type = "config";
    endfunction
    
    function void build_phase(uvm_phase phase);
        // Get additional config from command line
        void'($value$plusargs("WRITE_RATIO=%0d", write_ratio));
        void'($value$plusargs("ENABLE_NACK=%0d", enable_nack));
        
        super.build_phase(phase);
        
        `uvm_info(get_type_name(), $sformatf("Additional config: write_ratio=%0d, enable_nack=%0d", 
                  write_ratio, enable_nack), UVM_LOW)
    endfunction
    
    virtual function void configure_sequence(uvm_sequence #(my_seq_item) seq);
        super.configure_sequence(seq);
        
        // Apply additional configuration to sequence
        if (seq.get_type_name() == "my_sequence") begin
            my_sequence m_seq;
            if ($cast(m_seq, seq)) begin
                m_seq.write_ratio = write_ratio;
            end
        end
    endfunction
endclass

//==================================================
// Virtual sequencer test
//==================================================
class virtual_sequencer_test extends my_test;
    `uvm_component_utils(virtual_sequencer_test)
    
    my_virtual_sequencer v_seqr;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        test_type = "virtual";
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create virtual sequencer
        v_seqr = my_virtual_sequencer::type_id::create("v_seqr", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect virtual sequencer to actual sequencer
        v_seqr.i2c_sequencer = env.agt.seqr;
    endfunction
    
    task run_phase(uvm_phase phase);
        comprehensive_test_vseq vseq;
        
        phase.raise_objection(this);
        
        // Create virtual sequence
        vseq = comprehensive_test_vseq::type_id::create("vseq");
        
        `uvm_info(get_type_name(), "Starting virtual sequence", UVM_LOW)
        
        // Start virtual sequence on virtual sequencer
        vseq.start(v_seqr);
        
        phase.drop_objection(this);
    endtask
endclass