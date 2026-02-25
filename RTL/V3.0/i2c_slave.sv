/*
I2C SLAVE CONTROLLER – Version 3.0

Revision Notes:
 - IDLE state added to the FSM to ensure proper bus initialization and START detection handling.
 - always_ff blocks corrected to prevent multiple drivers controlling the same variable.
 - Each registered signal is now driven by a single always_ff block, ensuring synthesizable and deterministic behavior.
*/


module i2c_slave_controller #(
    parameter int ADDR_WIDTH = 7,                         // I2C address width (7 bits default)
    parameter int DATA_WIDTH = 8,                         // Data width (8 bits default)
    parameter logic [ADDR_WIDTH-1:0] SLAVE_ADDR = 7'b0101010 // Slave address
)(
    inout  logic sda,                                     // I2C data line
    input  logic scl,                                     // I2C clock line
    input  logic rst,                                     // Asynchronous reset (active high)
	
    output logic [DATA_WIDTH-1:0] data_received,          // Data received from master (write operation)
    input  logic [DATA_WIDTH-1:0] data_to_send            // Data to transmit to master (read operation)
);


    // FSM state definition
    
    typedef enum logic [2:0] {
        IDLE,          // Waiting for START condition
        READ_ADDR,     // Receiving address + R/W bit
        SEND_ACK,      // Sending ACK after address match
        READ_DATA,     // Receiving data from master
        SEND_ACK2,     // Sending ACK after data reception
        WRITE_DATA     // Transmitting data to master
    } state_t;

    state_t state;     // Current FSM state

   
    // Internal registers

    logic [ADDR_WIDTH:0] address_reg;   // Stores received address + R/W bit
  	logic [3:0] counter;                // Bit counter (address and data)

    logic sda_out;                      // SDA output value
    logic sda_drive_en;                 // SDA drive enable (tri-state control)

    
    // Open-drain SDA control
    
    assign sda = (sda_drive_en) ? sda_out : 1'bz;


    // START/STOP detection logic

    logic start_event;                  // START condition detected
    logic stop_event;                   // STOP condition detected


    // START condition detection
    // START occurs when SDA falls while SCL is high

    always_ff @(negedge sda or posedge rst) begin
        if (rst)
            start_event <= 1'b1;   
        if (stop_event == 1)
      	    start_event <= 0;
        if (scl == 1)
            start_event <= 1;
        else
            start_event <= 0;
    end


    // STOP condition detection
    // STOP occurs when SDA rises while SCL is high

    always_ff @(posedge sda or posedge rst) begin
        if (scl == 1)
            stop_event <= 1;
        else 
      	    stop_event <= 0;
        if (start_event == 1)
            stop_event <= 0;
    end


    // Main FSM
    // All state transitions and data sampling occur on SCL rising edge

    always_ff @(posedge scl or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            counter       <= '0;
            address_reg   <= '0;
            data_received <= '0;
        end
        else begin
            case (state)

                // Waiting for START condition
                IDLE: begin
                    if (start_event) begin
                        state       <= READ_ADDR;
                      	counter     <= ADDR_WIDTH;
                      	address_reg <= '0;
                    end
                end


                // Receiving address + R/W bit (MSB first)
                READ_ADDR: begin
                    address_reg[counter] <= sda;

                    if (counter == 0)
                        state <= SEND_ACK;
                    else
                        counter <= counter - 1;
                end


                // Address match verification and ACK generation
                SEND_ACK: begin
                    if (address_reg[ADDR_WIDTH:1] == SLAVE_ADDR) begin
                        counter <= DATA_WIDTH-1;

                        // R/W bit: 0 = master writes, 1 = master reads
                        if (address_reg[0] == 1'b0)
                            state <= READ_DATA;   // Master writing to slave
                        else
                            state <= WRITE_DATA;  // Master reading from slave
                    end
                    else begin
                        state <= IDLE; // Address mismatch
                    end
                end


                // Receiving data from master
                READ_DATA: begin
                    data_received[counter] <= sda;

                    if (counter == 0)
                        state <= SEND_ACK2;
                    else
                        counter <= counter - 1;
                end


                // ACK after data reception
                SEND_ACK2: begin
                    state <= IDLE;
                end


                // Transmitting data to master
                WRITE_DATA: begin
                    if (counter == 0)
                        state <= IDLE;
                    else
                        counter <= counter - 1;

                    // Repeated START support
                    if (start_event) begin
                        state   <= READ_ADDR;
                        counter <= ADDR_WIDTH;
                    end
                end

            endcase
        end
    end


    // SDA drive control
    // Data changes occur on SCL falling edge (I2C timing requirement)

    always_ff @(negedge scl or posedge rst) begin
        if (rst) begin
            sda_drive_en <= 1'b0;
            sda_out      <= 1'b1;
        end
        else begin
            case (state)

                // Release SDA during reception states
                IDLE,
                READ_ADDR,
                READ_DATA: begin
                    sda_drive_en <= 1'b0;
                end


                // ACK after address match
                SEND_ACK: begin
                    if (address_reg[ADDR_WIDTH:1] == SLAVE_ADDR) begin
                        sda_out      <= 1'b0;
                        sda_drive_en <= 1'b1;
                    end
                    else begin
                        sda_drive_en <= 1'b0;
                    end
                end


                // ACK after data reception
                SEND_ACK2: begin
                    sda_out      <= 1'b0;
                    sda_drive_en <= 1'b1;
                end


                // Data transmission to master
                WRITE_DATA: begin
                    sda_out      <= data_to_send[counter];
                    sda_drive_en <= 1'b1;
                end

            endcase
        end
    end

endmodule