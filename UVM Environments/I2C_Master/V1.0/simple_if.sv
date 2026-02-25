//==================================================
// Interface (ligação DUT ↔ testbench)
//==================================================
interface i2c_if #( 
    parameter int ADDR_WIDTH = 7,
    parameter int DATA_WIDTH = 8
)(
    input logic clk
);

    // ---------------------------
    // Sinais de controle
    // ---------------------------
    logic rst;
    logic enable;
    logic rw;

    // ---------------------------
    // Dados
    // ---------------------------
    logic [ADDR_WIDTH-1:0] address;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;

    // ---------------------------
    // Status
    // ---------------------------
    logic ready;

    // ---------------------------
    // Barramento I2C (open-drain)
    // ---------------------------
    tri i2c_sda;
    tri i2c_scl;

    // ---------------------------
    // Inicialização padrão
    // ---------------------------
    initial begin
        rst     = 1'b1;
        enable  = 1'b0;
        rw      = 1'b0;
        address = '0;
        data_in = '0;
    end

endinterface
