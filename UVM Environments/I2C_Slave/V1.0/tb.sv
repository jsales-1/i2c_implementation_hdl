//==================================================
// 9. Top-level testbench (instantiates I2C slave DUT)
//==================================================
module tb;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

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
    
    // String for test name
    string test_name;
    
    // I2C interface instance
    i2c_if i2c_if_inst (
        .clk(clk)
    );
    
    // Pull-up resistors for I2C bus
    pullup (i2c_if_inst.sda);
    pullup (i2c_if_inst.scl);
    
    // DUT - I2C Slave Controller
    i2c_slave_controller #(
        .ADDR_WIDTH(7),
        .DATA_WIDTH(8),
        .SLAVE_ADDR(7'b0101010)  // 0x50 in binary (7'h50)
    ) DUT (
        .sda(i2c_if_inst.sda),
        .scl(i2c_if_inst.scl),
        .rst(rst),
        .data_received(i2c_if_inst.data_received),
        .data_to_send(i2c_if_inst.data_to_send)
    );
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Reset generation
    initial begin
        rst = 1;
        #100;
        rst = 0;
        `uvm_info("TB", "Reset released", UVM_LOW)
    end
    
    // Set data for slave to send during read operations
    initial begin
        #150;
        fork
            forever begin
                @(posedge clk);
                // Randomize data to send for reads
                i2c_if_inst.data_to_send = $urandom_range(0, 255);
            end
        join_none
    end
    
    // I2C Bus Monitor (debug)
    initial begin
        #150;
        fork
            i2c_if_inst.monitor_i2c_bus();
        join_none
    end
    
    // VCD dump
    initial begin
        $dumpfile("i2c_slave_test.vcd");
        $dumpvars(0, tb);
        `uvm_info("TB", "VCD dump enabled", UVM_LOW)
    end
    
    // UVM test initialization
    initial begin
        uvm_config_db #(virtual i2c_if)::set(null, "*", "vif", i2c_if_inst);
        
        if ($value$plusargs("UVM_TESTNAME=%s", test_name)) begin
            `uvm_info("TB", $sformatf("Running test: %s", test_name), UVM_LOW)
            run_test(test_name);
        end
        else begin
            `uvm_info("TB", "No test specified, running default my_test", UVM_LOW)
            run_test("my_test");
        end
    end
    
    final begin
        `uvm_info("TB", "Simulation completed", UVM_LOW)
    end

endmodule