
module i2c_slave_controller #(
    parameter int ADDR_WIDTH = 7,                     // Address width (7 bits)
    parameter int DATA_WIDTH = 8,                     // Data width (8 bits)
    parameter logic [ADDR_WIDTH-1:0] SLAVE_ADDR = 7'b0101010 // Slave address
)(
    inout  logic sda,   // I2C data line
    inout  logic scl,   // I2C clock line    
    output logic [DATA_WIDTH-1:0] data_received,
    input  logic [DATA_WIDTH-1:0] data_to_send, // Fixed response data
    input  logic rst                             // Synchronous reset
);

    // -------------------------------
    // FSM states
    // -------------------------------
    typedef enum logic [2:0] {
        READ_ADDR  = 3'd0,
        SEND_ACK   = 3'd1,
        READ_DATA  = 3'd2,
        WRITE_DATA = 3'd3,
        SEND_ACK2  = 3'd4
    } state_t;

    // -------------------------------
    // Internal registers
    // -------------------------------
    state_t state;
    logic [ADDR_WIDTH:0] address_reg;   // Address + rw bit
    logic [$clog2(DATA_WIDTH+1)-1:0] counter;

    logic sda_out;
    logic start_detected;
    logic sda_drive_en;

    // -------------------------------
    // SDA bus connection
    // -------------------------------
    assign sda = (sda_drive_en == 1) ? sda_out : 1'bz;

    // -------------------------------
    // START condition detection
    // -------------------------------
    always_ff @(negedge sda or posedge rst) begin
        if (rst) begin
            address_reg    <= '0;
            start_detected <= 0;
            counter        <= ADDR_WIDTH;
        end else if ((start_detected == 0) && (scl == 1)) begin
            data_received  <= '0;
            start_detected <= 1;
            counter        <= ADDR_WIDTH;
        end
    end

    // -------------------------------
    // STOP condition detection
    // -------------------------------
    always_ff @(posedge sda or posedge rst) begin
        if (rst) begin
            state          <= READ_ADDR;
            start_detected <= 0;
            sda_drive_en   <= 0;
        end else if ((start_detected == 1) && (scl == 1)) begin
            state          <= READ_ADDR;
            start_detected <= 0;
            sda_drive_en   <= 0;
            address_reg    <= '0;
        end
    end

    // -------------------------------
    // FSM triggered on SCL rising edge
    // -------------------------------
    always_ff @(posedge scl or posedge rst) begin
        if (rst) begin
            state   <= READ_ADDR;
            counter <= ADDR_WIDTH;
        end else if (start_detected == 1) begin
            case (state)

                READ_ADDR: begin
                    address_reg[counter] <= sda;
                    if (counter == 0)
                        state <= SEND_ACK;
                    else
                        counter <= counter - 1;
                end

                SEND_ACK: begin
                    if (address_reg[ADDR_WIDTH:1] == SLAVE_ADDR) begin
                        counter <= DATA_WIDTH-1;
                        if (address_reg[0] == 0)
                            state <= READ_DATA;
                        else
                            state <= WRITE_DATA;
                    end
                end

                READ_DATA: begin
                    data_received[counter] <= sda;
                    if (counter == 0)
                        state <= SEND_ACK2;
                    else
                        counter <= counter - 1;
                end

                SEND_ACK2: begin
                    state <= READ_ADDR;
                end

                WRITE_DATA: begin
                    if (counter == 0)
                        state <= READ_ADDR;
                    else
                        counter <= counter - 1;
                end
            endcase
        end
    end

    // -------------------------------
    // SDA line control
    // -------------------------------
    always_ff @(negedge scl or posedge rst) begin
        if (rst) begin
            sda_drive_en <= 0;
            sda_out      <= 0;
        end else begin
            case (state)
                READ_ADDR:  sda_drive_en <= 0;

                SEND_ACK: begin
                    if (address_reg[ADDR_WIDTH:1] == SLAVE_ADDR) begin
                        sda_out      <= 0;   // ACK = 0
                        sda_drive_en <= 1;   // dirige a linha
                    end else begin
                        sda_drive_en <= 0;   // não reconhece endereço → NACK (Z)
                    end
                end


                READ_DATA:  sda_drive_en <= 0;

                WRITE_DATA: begin
                    sda_out      <= data_to_send[counter];
                    sda_drive_en <= 1;
                end

                SEND_ACK2: begin
                    sda_out      <= 0;
                    sda_drive_en <= 1;
                end
            endcase
        end
    end

endmodule
