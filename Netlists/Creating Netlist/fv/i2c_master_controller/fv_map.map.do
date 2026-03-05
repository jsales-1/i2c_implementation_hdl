
//input ports
add mapped point clk clk -type PI PI
add mapped point rst rst -type PI PI
add mapped point address[6] address[6] -type PI PI
add mapped point address[5] address[5] -type PI PI
add mapped point address[4] address[4] -type PI PI
add mapped point address[3] address[3] -type PI PI
add mapped point address[2] address[2] -type PI PI
add mapped point address[1] address[1] -type PI PI
add mapped point address[0] address[0] -type PI PI
add mapped point data_in[7] data_in[7] -type PI PI
add mapped point data_in[6] data_in[6] -type PI PI
add mapped point data_in[5] data_in[5] -type PI PI
add mapped point data_in[4] data_in[4] -type PI PI
add mapped point data_in[3] data_in[3] -type PI PI
add mapped point data_in[2] data_in[2] -type PI PI
add mapped point data_in[1] data_in[1] -type PI PI
add mapped point data_in[0] data_in[0] -type PI PI
add mapped point enable enable -type PI PI
add mapped point rw rw -type PI PI

//output ports
add mapped point data_out[7] data_out[7] -type PO PO
add mapped point data_out[6] data_out[6] -type PO PO
add mapped point data_out[5] data_out[5] -type PO PO
add mapped point data_out[4] data_out[4] -type PO PO
add mapped point data_out[3] data_out[3] -type PO PO
add mapped point data_out[2] data_out[2] -type PO PO
add mapped point data_out[1] data_out[1] -type PO PO
add mapped point data_out[0] data_out[0] -type PO PO
add mapped point ready ready -type PO PO

//inout ports
add mapped point i2c_sda i2c_sda
add mapped point i2c_scl i2c_scl




//Sequential Pins
add mapped point counter[1]/q counter_reg[1]/Q -type DFF DFF
add mapped point sda_out/q sda_out_reg/Q -type DFF DFF
add mapped point counter[0]/q counter_reg[0]/Q -type DFF DFF
add mapped point counter[2]/q counter_reg[2]/Q -type DFF DFF
add mapped point sda_drive_en/q sda_drive_en_reg/Q -type DFF DFF
add mapped point state[3]/q state_reg[3]/Q -type DFF DFF
add mapped point state[0]/q state_reg[0]/Q -type DFF DFF
add mapped point data_out[3]/q data_out_reg[3]/Q -type DFF DFF
add mapped point data_out[2]/q data_out_reg[2]/Q -type DFF DFF
add mapped point data_out[1]/q data_out_reg[1]/Q -type DFF DFF
add mapped point data_out[4]/q data_out_reg[4]/Q -type DFF DFF
add mapped point data_out[7]/q data_out_reg[7]/Q -type DFF DFF
add mapped point data_out[6]/q data_out_reg[6]/Q -type DFF DFF
add mapped point data_out[5]/q data_out_reg[5]/Q -type DFF DFF
add mapped point data_out[0]/q data_out_reg[0]/Q -type DFF DFF
add mapped point scl_enable/q scl_enable_reg/Q -type DFF DFF
add mapped point state[1]/q state_reg[1]/Q -type DFF DFF
add mapped point address_reg[0]/q address_reg_reg[0]/Q -type DFF DFF
add mapped point address_reg[5]/q address_reg_reg[5]/Q -type DFF DFF
add mapped point write_data_reg[1]/q write_data_reg_reg[1]/Q -type DFF DFF
add mapped point write_data_reg[2]/q write_data_reg_reg[2]/Q -type DFF DFF
add mapped point write_data_reg[0]/q write_data_reg_reg[0]/Q -type DFF DFF
add mapped point address_reg[7]/q address_reg_reg[7]/Q -type DFF DFF
add mapped point write_data_reg[4]/q write_data_reg_reg[4]/Q -type DFF DFF
add mapped point state[2]/q state_reg[2]/Q -type DFF DFF
add mapped point write_data_reg[6]/q write_data_reg_reg[6]/Q -type DFF DFF
add mapped point write_data_reg[7]/q write_data_reg_reg[7]/Q -type DFF DFF
add mapped point address_reg[1]/q address_reg_reg[1]/Q -type DFF DFF
add mapped point address_reg[2]/q address_reg_reg[2]/Q -type DFF DFF
add mapped point write_data_reg[5]/q write_data_reg_reg[5]/Q -type DFF DFF
add mapped point address_reg[3]/q address_reg_reg[3]/Q -type DFF DFF
add mapped point address_reg[4]/q address_reg_reg[4]/Q -type DFF DFF
add mapped point write_data_reg[3]/q write_data_reg_reg[3]/Q -type DFF DFF
add mapped point address_reg[6]/q address_reg_reg[6]/Q -type DFF DFF
add mapped point i2c_clk/q i2c_clk_reg/Q -type DFF DFF
add mapped point clk_counter[0]/q clk_counter_reg[0]/Q -type DFF DFF



//Black Boxes



//Empty Modules as Blackboxes
