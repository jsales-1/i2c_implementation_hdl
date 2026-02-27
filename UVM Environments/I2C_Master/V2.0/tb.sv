//==================================================
// 9. Top-level testbench (instantiates DUT and interface)
//==================================================
module tb;

    // ------------------------------------------
    // UVM macros include
    // ------------------------------------------
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // i2c_if.sv is already included in testbench.sv, so we don't include it here again
    
    `include "my_seq_item.sv"
    `include "my_sequence.sv"
    `include "my_driver.sv"
    `include "my_monitor.sv"
    `include "my_agent.sv"
    `include "my_scoreboard.sv"
    `include "my_env.sv"
    `include "my_test.sv"

    // Clock and reset
    logic clk;
    logic rst;
    
    // String for test name (declared at module level, not inside initial)
    string test_name;
    
    // I2C interface instance
    i2c_if i2c_if_inst (
        .clk(clk)
    );
    
    // Pull-up resistors for I2C bus (required for I2C)
    pullup (i2c_if_inst.i2c_sda);
    pullup (i2c_if_inst.i2c_scl);
    
    // DUT - I2C Master Controller
    i2c_master_controller #(
        .ADDR_WIDTH(7),
        .DATA_WIDTH(8),
        .CLOCK_DIV(4)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .address(i2c_if_inst.address),
        .data_in(i2c_if_inst.data_in),
        .enable(i2c_if_inst.enable),
        .rw(i2c_if_inst.rw),
        .data_out(i2c_if_inst.data_out),
        .ready(i2c_if_inst.ready),
        .i2c_sda(i2c_if_inst.i2c_sda),
        .i2c_scl(i2c_if_inst.i2c_scl)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock
    end
    
    // Reset generation
    initial begin
        rst = 1;
        #100;
        rst = 0;
        `uvm_info("TB", "Reset released", UVM_LOW)
    end
    
    // I2C Slave Model - ativado para responder às transações do master
    initial begin
        // Pequeno delay para garantir que o DUT já está resetado
        #150;
        `uvm_info("TB", "Starting I2C Slave Model", UVM_LOW)
        fork
            i2c_if_inst.i2c_slave_model();
        join_none
    end
    
    // I2C Bus Monitor (opcional, para debug)
    initial begin
        // Pequeno delay para iniciar após o reset
        #150;
        fork
            i2c_if_inst.monitor_i2c_bus();
        join_none
    end
    
    // VCD dump for waveform debugging
    initial begin
        $dumpfile("i2c_test.vcd");
        $dumpvars(0, tb);
        `uvm_info("TB", "VCD dump enabled", UVM_LOW)
    end
    
    // UVM test initialization
    initial begin
        // Set interface in config DB
        uvm_config_db #(virtual i2c_if)::set(null, "*", "vif", i2c_if_inst);
        
        // Run test with default test name if none provided
        if ($value$plusargs("UVM_TESTNAME=%s", test_name)) begin
            `uvm_info("TB", $sformatf("Running test: %s", test_name), UVM_LOW)
            run_test(test_name);
        end
        else begin
            `uvm_info("TB", "No test specified, running default my_test", UVM_LOW)
            run_test("my_test");
        end
    end
    
    // Monitor test completion
    final begin
        `uvm_info("TB", "Simulation completed", UVM_LOW)
    end

endmodule