//==================================================
// 2. Transaction — representa uma "transferência" de dados
//==================================================
class my_seq_item extends uvm_sequence_item;
    rand bit [7:0] data_in;
    rand bit 	   enable;
    bit [7:0] 	   data_out;
    
    `uvm_object_utils_begin(my_seq_item)
	`uvm_field_int(data_in, UVM_DEFAULT)
	`uvm_field_int(enable, UVM_DEFAULT)
	`uvm_field_int(data_out, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name = "my_seq_item");
	super.new(name);
    endfunction

endclass
