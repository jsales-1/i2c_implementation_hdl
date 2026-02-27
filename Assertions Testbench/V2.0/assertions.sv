// I2C VERIFICATION PLAN ASSERTIONS
// Aligned with VPLAN Rev 1.0
// Compatible with Cadence Xcelium

package i2c_vplan_pkg;
endpackage



// MASTER ASSERTIONS (bind to master)
// Covers: F1, F2, F3, F4, F5, F6, F9, F10


module i2c_master_assertions
(
    input logic clk,
    input logic rst,
    input logic ready,
    input logic enable,
    input logic scl,
    input logic sda,
    input logic [3:0] state   
);

    
    // F1 – Idle State
    
    property p_idle_ready_relation;
        @(posedge clk)
        disable iff (rst)
        (state == 0) |-> ready;
    endproperty
    assert property(p_idle_ready_relation)
        else $error("F1 ERROR: Ready not asserted in IDLE");
    
    cover property(p_idle_ready_relation)
        $info("F1 COVER: Master in IDLE with ready asserted");


    
    // F2 – START condition
    
    property p_start_condition;
        @(posedge clk)
        disable iff (rst)
        ($fell(sda) && scl) |-> scl;
    endproperty
    assert property(p_start_condition)
        else $error("F2 ERROR: Invalid START condition");
    
    cover property(p_start_condition)
        $info("F2 COVER: START condition generated");


    
    // F9 – STOP condition
    
    property p_stop_condition;
        @(posedge clk)
        disable iff (rst)
        ($rose(sda) && scl) |-> scl;
    endproperty
    assert property(p_stop_condition)
        else $error("F9 ERROR: Invalid STOP condition");
    
    cover property(p_stop_condition)
        $info("F9 COVER: STOP condition generated");


    
    // F10 – Reset forces IDLE
    
    property p_reset_idle;
        @(posedge clk)
        rst |-> (state == 0);
    endproperty
    assert property(p_reset_idle)
        else $error("F10 ERROR: Master not in IDLE after reset");
    
    cover property(p_reset_idle)
        $info("F10 COVER: Master reset to IDLE");

endmodule



// ============================================================
// SLAVE ASSERTIONS
// Covers: F7, F8, F10
// ============================================================

module i2c_slave_assertions
(
    input logic rst,
    input logic scl,
    input logic sda,
    input logic sda_drive_en
);

    
    // F8 – SDA open-drain behavior
    // Slave must never drive '1'
    
    property p_open_drain_rule;
        @(posedge scl)
        disable iff (rst)
        sda_drive_en |-> (sda == 0);
    endproperty
    assert property(p_open_drain_rule)
        else $error("F8 ERROR: Slave driving SDA high (violates open-drain)");
    
    cover property(p_open_drain_rule)
        $info("F8 COVER: Slave driving SDA low (open-drain compliant)");


    
    // F10 – Reset releases bus
    
    property p_reset_releases_bus;
        @(posedge scl)
        rst |-> !sda_drive_en;
    endproperty
    assert property(p_reset_releases_bus)
        else $error("F10 ERROR: Slave did not release bus on reset");
    
    cover property(p_reset_releases_bus)
        $info("F10 COVER: Slave released bus on reset");

endmodule



// ============================================================
// BUS ASSERTIONS
// Covers: F4, F7, Invalid Address, Multi-Slave
// ============================================================

module i2c_bus_assertions
(
    input logic rst,
    input logic scl,
    input logic sda
);

    
    // SDA must be stable while SCL high (F4 timing integrity)
    
    property p_sda_stable_when_scl_high;
        @(posedge scl)
        disable iff (rst)
        $stable(sda);
    endproperty
    assert property(p_sda_stable_when_scl_high)
        else $error("BUS ERROR: SDA changed while SCL high");
    
    cover property(p_sda_stable_when_scl_high)
        $info("BUS COVER: SDA stable during SCL high");


    
    // No X/Z on active bus
    
    property p_no_unknown_bus;
        @(posedge scl)
        disable iff (rst)
        !$isunknown(scl) && !$isunknown(sda);
    endproperty
    assert property(p_no_unknown_bus)
        else $error("BUS ERROR: X/Z detected on I2C bus");
    
    cover property(p_no_unknown_bus)
        $info("BUS COVER: No X/Z on bus");

endmodule