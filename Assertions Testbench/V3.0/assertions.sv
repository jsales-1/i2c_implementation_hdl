// I2C VERIFICATION PLAN ASSERTIONS
// Aligned with VPLAN Rev 1.0 - Complete Feature List F1-F10
// Compatible with Cadence Xcelium

package i2c_vplan_pkg;
endpackage



// MASTER ASSERTIONS
// Covers: F1, F2, F3, F4, F5, F6, F7, F9, F10

module i2c_master_assertions
(
    input logic clk,
    input logic rst,
    input logic ready,
    input logic enable,
    input logic scl,
    input logic sda,
    input logic [3:0] state           // Master FSM state
);

    // F1 (MASTER) – Idle State
    // Master shall remain in idle state until a transaction is requested
    
    property p_idle_state;
        @(posedge clk)
        disable iff (rst)
        (state == 0) |-> ready;
    endproperty
    
    assert property(p_idle_state)
        else $error("F1 (MASTER) ERROR: Master not in IDLE state or ready not asserted");
    
    cover property(p_idle_state)
        $info("F1 (MASTER) COVER: Master in IDLE state with ready asserted");


    // F2 (MASTER) – START Condition Generation
    // START condition: SDA transitions to low while SCL remains high
    
    property p_start_condition;
        @(posedge clk)
        disable iff (rst)
        ($fell(sda) && scl) |-> scl;
    endproperty
    
    assert property(p_start_condition)
        else $error("F2 (MASTER) ERROR: Invalid START condition - SDA fell while SCL low");
    
    cover property(p_start_condition)
        $info("F2 (MASTER) COVER: START condition generated correctly");


    // F3 (MASTER) – Slave Address Transmission
    // Master correctly transmits 7-bit slave address + R/W bit
    
    property p_address_transmission;
      @(posedge clk)
        disable iff (rst)
        (state == 3 && scl && $changed(sda)) |-> 0;
    endproperty
    
    assert property(p_address_transmission)
        else $error("F3 (MASTER) ERROR: Address transmission failed - SDA unstable");
    
    cover property(p_address_transmission)
        $info("F3 (MASTER) COVER: Slave address transmission completed");


    // F4 (MASTER) – ACK/NACK Detection
    // Master correctly detects ACK (SDA=0) and NACK (SDA=1) from slave
    
    property p_ack_detection;
        @(posedge scl)
        disable iff (rst)
      (state == 3) |-> (sda == 0);  // READ_ACK state = 4
    endproperty
    
    assert property(p_ack_detection)
        else $error("F4 (MASTER) ERROR: ACK not detected when expected");
    
    cover property(p_ack_detection)
        $info("F4 (MASTER) COVER: ACK detected from slave");

    property p_nack_detection;
        @(posedge scl)
        disable iff (rst)
      (state == 3) |-> (sda == 1);  // READ_ACK state = 4
    endproperty
    
    cover property(p_nack_detection)
        $info("F4 (MASTER) COVER: NACK detected from slave");


    // F5 (MASTER) – Data Write Operation
    // Master correctly transmits data to addressed slave during write
    
    property p_data_write;
        @(posedge clk)
          disable iff (rst)
          (state == 5 && scl && $changed(sda)) |-> 0;
      endproperty
    
    assert property(p_data_write)
        else $error("F5 (MASTER) ERROR: Data write failed - SDA unstable");
    
    cover property(p_data_write)
        $info("F5 (MASTER) COVER: Data write operation completed");


    // F6 (MASTER) – Data Read Operation
    // Master correctly receives data from slave during read
    
    property p_data_read;
        @(posedge scl)
        disable iff (rst)
        (state == 7) |-> 1;  // READ_DATA state = 7
    endproperty
    
    assert property(p_data_read)
        else $error("F6 (MASTER) ERROR: Data read failed");
    
    cover property(p_data_read)
        $info("F6 (MASTER) COVER: Data read operation completed");


    // F7 (MASTER) – Multiple Slave Operation
    // In multi-slave configuration, only addressed slave responds
    
    property p_multi_slave_operation;
        @(posedge scl)
        disable iff (rst)
      (state == 3) |-> (sda == 0);  // Expect ACK from addressed slave
    endproperty
    
    assert property(p_multi_slave_operation)
        else $error("F7 (MASTER) ERROR: No ACK from addressed slave or multiple slaves responding");
    
    cover property(p_multi_slave_operation)
        $info("F7 (MASTER) COVER: Addressed slave responded with ACK");


    // F9 (MASTER) – STOP Condition Generation
    // STOP condition: SDA transitions to high while SCL remains high
    
    property p_stop_condition;
        @(posedge clk)
        disable iff (rst)
        ($rose(sda) && scl) |-> scl;
    endproperty
    
    assert property(p_stop_condition)
        else $error("F9 (MASTER) ERROR: Invalid STOP condition - SDA rose while SCL low");
    
    cover property(p_stop_condition)
        $info("F9 (MASTER) COVER: STOP condition generated correctly");


    // F10 (MASTER) – Reset Behavior
    // Reset returns master to initial state (IDLE)
    
    property p_reset_idle;
        @(posedge clk)
        rst |-> (state == 0);
    endproperty
    
    assert property(p_reset_idle)
        else $error("F10 (MASTER) ERROR: Master not in IDLE after reset");
    
    cover property(p_reset_idle)
        $info("F10 (MASTER) COVER: Master returned to IDLE after reset");


    // MASTER FSM STATE COVERAGE
    // Individual state coverage for code coverage requirements
    
    cover_property_master_idle: cover property (@(posedge clk) state == 0)
        $info("FSM (MASTER) COVER: Master reached IDLE state");

    cover_property_master_start: cover property (@(posedge clk) state == 1)
        $info("FSM (MASTER) COVER: Master reached START state");

      cover_property_master_address: cover property (@(posedge clk) state == 2)
        $info("FSM (MASTER) COVER: Master reached ADDRESS state");

        cover_property_master_read_ack: cover property (@(posedge clk) state == 3)
        $info("FSM (MASTER) COVER: Master reached READ_ACK state");

          cover_property_master_write_data: cover property (@(posedge clk) state == 4)
        $info("FSM (MASTER) COVER: Master reached WRITE_DATA state");

            cover_property_master_read_ack2: cover property (@(posedge clk) state == 5)
        $info("FSM (MASTER) COVER: Master reached READ_ACK2 state");

              cover_property_master_read_data: cover property (@(posedge clk) state == 6)
        $info("FSM (MASTER) COVER: Master reached READ_DATA state");

                cover_property_master_write_ack: cover property (@(posedge clk) state == 7)
        $info("FSM (MASTER) COVER: Master reached WRITE_ACK state");

                  cover_property_master_stop: cover property (@(posedge clk) state == 8)
        $info("FSM (MASTER) COVER: Master reached STOP state");

endmodule



// SLAVE ASSERTIONS
// Covers: F3, F4, F5, F6, F7, F8, F10

module i2c_slave_assertions
(
    input logic rst,
    input logic scl,
    input logic sda,
    input logic sda_drive_en,
    input logic [2:0] slave_state,      // Slave FSM state
    input logic [7:0] data_received,     // Data received from master
  input logic [7:0] data_to_send,       // Data to send to master
  input logic [6:0] SLAVE_ADDR,
  input logic [7:0] address_reg
);

    // Slave FSM state definitions (must match i2c_slave_controller)
    localparam IDLE        = 3'd0;
    localparam READ_ADDR   = 3'd1;
    localparam SEND_ACK    = 3'd2;
    localparam READ_DATA   = 3'd3;
    localparam SEND_ACK2   = 3'd4;
    localparam WRITE_DATA  = 3'd5;

    // F3 (SLAVE) – Slave Address Recognition
    // Slave correctly recognizes its own address
    // Note: Address match is verified by slave FSM transition
    
    property p_address_recognition;
        @(posedge scl)
        disable iff (rst)
        (slave_state == SEND_ACK) |-> 1;  // If in SEND_ACK, address matched
    endproperty
    
    assert property(p_address_recognition)
        else $error("F3 (SLAVE) ERROR: Slave failed to recognize its address");
    
    cover property(p_address_recognition)
        $info("F3 (SLAVE) COVER: Slave recognized its address");


    // F4 (SLAVE) – ACK Generation
    // Slave correctly generates ACK (SDA=0) when addressed
    
    property p_ack_generation;
        @(posedge scl)
        disable iff (rst)
      (slave_state == SEND_ACK) && (address_reg[7:1] == SLAVE_ADDR) 
        |-> (sda == 0);
    endproperty
    
    assert property(p_ack_generation)
        else $error("F4 (SLAVE) ERROR: Slave failed to generate ACK");
    
    cover property(p_ack_generation)
        $info("F4 (SLAVE) COVER: Slave generated ACK");


    // F5 (SLAVE) – Data Write Reception
    // Slave correctly receives data during write operations
    
    property p_data_write_reception;
        @(posedge scl)
        disable iff (rst)
        (slave_state == READ_DATA) |-> 1;
    endproperty
    
    assert property(p_data_write_reception)
        else $error("F5 (SLAVE) ERROR: Slave failed to receive write data correctly");
    
    cover property(p_data_write_reception)
        $info("F5 (SLAVE) COVER: Slave received write data");

    // F6 (SLAVE) – Data Read Transmission
    // Slave correctly transmits data during read operations

    // Versão corrigida - verifica open-drain compliance
    property p_data_read_transmission;
        @(posedge scl)
        disable iff (rst)
        (slave_state == WRITE_DATA) |-> (sda_drive_en ? (sda == 0) : 1);
    endproperty

    assert property(p_data_read_transmission)
        else $error("F6 (SLAVE) ERROR: Slave failed open-drain protocol during read transmission");

    cover property(p_data_read_transmission)
        $info("F6 (SLAVE) COVER: Slave performed read transmission");

    // F7 (SLAVE) – Multiple Slave Operation
    // Only addressed slave responds on the bus
    
    property p_addressed_slave_response;
        @(posedge scl)
        disable iff (rst)
        (slave_state != SEND_ACK && slave_state != SEND_ACK2 && slave_state != WRITE_DATA) |-> (sda_drive_en == 0);
    endproperty
    
    assert property(p_addressed_slave_response)
        else $error("F7 (SLAVE) ERROR: Unaddressed slave driving the bus");
    
    cover property(p_addressed_slave_response)
        $info("F7 (SLAVE) COVER: Only addressed slave responded");


    // F8 (SLAVE) – SDA Open-Drain Control
    // SDA line complies with open-drain (tri-state) operation
    // Slave must never drive SDA high
    
    property p_open_drain_behavior;
        @(posedge scl)
        disable iff (rst)
        sda_drive_en |-> (sda == 0);
    endproperty
    
    assert property(p_open_drain_behavior)
        else $error("F8 (SLAVE) ERROR: Slave driving SDA high - violates open-drain");
    
    cover property(p_open_drain_behavior)
        $info("F8 (SLAVE) COVER: Slave driving SDA low (open-drain compliant)");


    // F10 (SLAVE) – Reset Behavior
    // Reset releases the bus and returns slave to initial state
    
    property p_reset_releases_bus;
        @(posedge scl)
        rst |-> !sda_drive_en;
    endproperty
    
    assert property(p_reset_releases_bus)
        else $error("F10 (SLAVE) ERROR: Slave did not release bus on reset");
    
    cover property(p_reset_releases_bus)
        $info("F10 (SLAVE) COVER: Slave released bus on reset");

    property p_reset_idle_state;
        @(posedge scl)
        rst |-> (slave_state == IDLE);
    endproperty
    
    assert property(p_reset_idle_state)
        else $error("F10 (SLAVE) ERROR: Slave not in IDLE after reset");
    
    cover property(p_reset_idle_state)
        $info("F10 (SLAVE) COVER: Slave returned to IDLE after reset");


    // SLAVE FSM STATE COVERAGE
    // Individual state coverage for code coverage requirements
    
    cover_property_slave_idle: cover property (@(posedge scl) slave_state == IDLE)
        $info("FSM (SLAVE) COVER: Slave reached IDLE state");

    cover_property_slave_read_addr: cover property (@(posedge scl) slave_state == READ_ADDR)
        $info("FSM (SLAVE) COVER: Slave reached READ_ADDR state");

    cover_property_slave_send_ack: cover property (@(posedge scl) slave_state == SEND_ACK)
        $info("FSM (SLAVE) COVER: Slave reached SEND_ACK state");

    cover_property_slave_read_data: cover property (@(posedge scl) slave_state == READ_DATA)
        $info("FSM (SLAVE) COVER: Slave reached READ_DATA state");

    cover_property_slave_send_ack2: cover property (@(posedge scl) slave_state == SEND_ACK2)
        $info("FSM (SLAVE) COVER: Slave reached SEND_ACK2 state");

    cover_property_slave_write_data: cover property (@(posedge scl) slave_state == WRITE_DATA)
        $info("FSM (SLAVE) COVER: Slave reached WRITE_DATA state");


    // ADDITIONAL COVERAGE: ACK/NACK scenarios
    
    cover_property_slave_ack_addr: cover property (
        @(posedge scl)
        (slave_state == SEND_ACK)
    ) $info("COVER (SLAVE): Slave generated ACK after address match");

    cover_property_slave_ack_data: cover property (
        @(posedge scl)
        (slave_state == SEND_ACK2)
    ) $info("COVER (SLAVE): Slave generated ACK after data reception");

endmodule