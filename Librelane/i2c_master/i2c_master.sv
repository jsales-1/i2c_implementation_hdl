module i2c_master_controller #(
    parameter int ADDR_WIDTH = 7,   // I2C address width (7 bits default)
    parameter int DATA_WIDTH = 8,   // Data width (8 bits default)
    parameter int CLOCK_DIV  = 4    // Division factor to generate I2C clock
)(
    input  logic clk,                          // System clock
    input  logic rst,                          // Synchronous reset (active high)
    input  logic [ADDR_WIDTH-1:0] address,     // I2C device address
    input  logic [DATA_WIDTH-1:0] data_in,     // Data to be written
    input  logic enable,                       // Enable transaction
    input  logic rw,                           // Operation (0 = write, 1 = read)

    output logic [DATA_WIDTH-1:0] data_out,    // Read data (read operation)
    output logic ready,                        // Ready for new operation

    inout  logic i2c_sda,                      // I2C data line
    inout  logic i2c_scl                       // I2C clock line
);

    // -------------------------------
    // FSM state definition
    // -------------------------------
    typedef enum logic [3:0] {
        IDLE,
        START,
        WAIT,
        ADDRESS,
        READ_ACK,
        WRITE_DATA,
        READ_ACK2,
        READ_DATA,
        WRITE_ACK,
        STOP
    } state_t;

    // -------------------------------
    // Internal registers
    // -------------------------------
    state_t state;
    logic [ADDR_WIDTH:0] address_reg;        // Address + R/W bit
    logic [DATA_WIDTH-1:0] write_data_reg;   // Stored write data
    logic [$clog2(DATA_WIDTH+1)-1:0] counter;
    logic [$clog2(CLOCK_DIV+1)-1:0] clk_counter;
    logic sda_drive_en;
    logic sda_out;
    logic scl_enable;
    logic i2c_clk;

    // -------------------------------
    // Output signals
    // -------------------------------
    assign ready   = (!rst && state == IDLE);
    assign i2c_scl = (scl_enable == 0) ? 1'b1 : i2c_clk;
    assign i2c_sda = (sda_drive_en == 1) ? sda_out : 1'bz;

    // -------------------------------
    // I2C clock divider
    // -------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_counter <= 0;
            i2c_clk     <= 1'b1;
        end else if (clk_counter == (CLOCK_DIV/2)-1) begin
            clk_counter <= 0;
            i2c_clk     <= ~i2c_clk;
        end else begin
            clk_counter <= clk_counter + 1;
        end
    end

    // -------------------------------
    // SCL enable control
    // -------------------------------
    always_ff @(negedge i2c_clk or posedge rst) begin
        if (rst) begin
            scl_enable <= 0;
        end else begin
            if ((state == IDLE) || (state == START) || (state == STOP))
                scl_enable <= 0;
            else
                scl_enable <= 1;
        end
    end

    // -------------------------------
    // State machine (main FSM)
    // -------------------------------
    always_ff @(posedge i2c_clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            case (state)

                IDLE: begin
                    if (enable) begin
                        state <= START;
                        address_reg    <= {address, rw};
                        write_data_reg <= data_in;
                        data_out       <= '0;
                    end
                end

                START: begin
                    state   <= WAIT;
                end

                WAIT: begin
                    counter <= ADDR_WIDTH;
                    state   <= ADDRESS;
                end

                ADDRESS: begin
                    if (counter == 0)
                        state <= READ_ACK;
                    else
                        counter <= counter - 1;
                end

                READ_ACK: begin
                    if (i2c_sda == 0) begin
                        counter <= DATA_WIDTH-1;
                        if (address_reg[0] == 0)
                            state <= WRITE_DATA;
                        else
                            state <= READ_DATA;
                    end else
                        state <= STOP;
                end

                WRITE_DATA: begin
                    if (counter == 0)
                        state <= READ_ACK2;
                    else
                        counter <= counter - 1;
                end

                READ_ACK2: begin
                    if ((i2c_sda == 0) && (enable == 1))
                        state <= IDLE;
                    else
                        state <= STOP;
                end

                READ_DATA: begin
                    data_out[counter] <= i2c_sda;
                    if (counter == 0)
                        state <= WRITE_ACK;
                    else
                        counter <= counter - 1;
                end

                WRITE_ACK: begin
                    state <= STOP;
                end

                STOP: begin
                    state <= IDLE;
                end

            endcase
        end
    end

    // -------------------------------
    // SDA line control
    // -------------------------------
    always_ff @(negedge i2c_clk or posedge rst) begin
        if (rst) begin
            sda_drive_en <= 1;
            sda_out      <= 1;
        end else begin
            case (state)

                START: begin
                    sda_drive_en <= 1;
                    sda_out      <= 0; // START condition
                end

                WAIT: begin
                    sda_drive_en <= 1;
                    sda_out      <= 0; // START condition
                end

                ADDRESS: begin
                    sda_out <= address_reg[counter];
                end

                READ_ACK: begin
                    sda_drive_en <= 0; // Release SDA
                end

                WRITE_DATA: begin
                    sda_drive_en <= 1;
                    sda_out      <= write_data_reg[counter];
                end

                WRITE_ACK: begin
                    sda_drive_en <= 1;
                    sda_out      <= 0; // ACK
                end
              	READ_ACK2: begin
                    sda_drive_en <= 0;
                end

                READ_DATA: begin
                    sda_drive_en <= 0; // Release SDA
                end

                STOP: begin
                    sda_drive_en <= 1;
                    sda_out      <= 1; // STOP condition
                end
            endcase
        end
    end

endmodule
