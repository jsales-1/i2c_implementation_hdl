//==================================================
// 9. Top-level testbench (instancia DUT e interface)
//==================================================
module tb;

    // ------------------------------------------
    // UVM macros include
    // ------------------------------------------
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

    // ------------------------------------------
    // Clock / Reset
    // ------------------------------------------
    logic clk;
    logic rst;

    always #5 clk = ~clk;

    // ------------------------------------------
    // Interface
    // ------------------------------------------
    i2c_if #(7,8) sif(.clk(clk));

    // ------------------------------------------
    // DUT - I2C Master
    // ------------------------------------------
    i2c_master_controller #(
        .ADDR_WIDTH(7),
        .DATA_WIDTH(8),
        .CLOCK_DIV(4)
    ) DUT (
        .clk       (sif.clk),
        .rst       (sif.rst),
        .address   (sif.address),
        .data_in   (sif.data_in),
        .enable    (sif.enable),
        .rw        (sif.rw),
        .data_out  (sif.data_out),
        .ready     (sif.ready),
        .i2c_sda   (sif.i2c_sda),
        .i2c_scl   (sif.i2c_scl)
    );

    // ------------------------------------------
    // UVM configuration
    // ------------------------------------------
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;

        uvm_config_db #(virtual i2c_if)::set(null, "*", "vif", sif);
        run_test("my_test");
    end

    // ------------------------------------------
    // Reset generation
    // ------------------------------------------
    initial begin
        clk = 0;
        sif.rst = 1;
        #20;
        sif.rst = 0;
    end

endmodule
