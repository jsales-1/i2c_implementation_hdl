//==================================================
// 3. Sequence — gera transações I2C válidas
//==================================================
class my_sequence extends uvm_sequence #(my_seq_item);
    `uvm_object_utils(my_sequence)

    my_seq_item item;

    function new(string name = "my_sequence");
        super.new(name);
    endfunction

    task body();

        `uvm_info(get_name(), "I2C Master Sequence starting...", UVM_LOW)

        repeat (10) begin

            item = my_seq_item::type_id::create("item");

            start_item(item);

            // Randomização controlada
            if (!item.randomize() with {

                address inside {[0:127]};     // endereço 7 bits válido
                rw inside {0,1};              // read ou write

                // Se for write, data deve ser válido
                if (rw == 0)
                    data inside {[0:255]};

            }) begin
                `uvm_error(get_name(), "Randomization failed")
            end

            `uvm_info(get_name(),
                $sformatf("Transaction: addr=0x%0h rw=%0d data=0x%0h",
                           item.address, item.rw, item.data),
                UVM_MEDIUM)

            finish_item(item);

        end

        `uvm_info(get_name(), "I2C Master Sequence finished.", UVM_LOW)

    endtask

endclass
