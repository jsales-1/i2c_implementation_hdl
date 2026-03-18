
//input ports
add mapped point scl scl -type PI PI
add mapped point rst rst -type PI PI
add mapped point data_to_send[7] data_to_send[7] -type PI PI
add mapped point data_to_send[6] data_to_send[6] -type PI PI
add mapped point data_to_send[5] data_to_send[5] -type PI PI
add mapped point data_to_send[4] data_to_send[4] -type PI PI
add mapped point data_to_send[3] data_to_send[3] -type PI PI
add mapped point data_to_send[2] data_to_send[2] -type PI PI
add mapped point data_to_send[1] data_to_send[1] -type PI PI
add mapped point data_to_send[0] data_to_send[0] -type PI PI

//output ports
add mapped point data_received[7] data_received[7] -type PO PO
add mapped point data_received[6] data_received[6] -type PO PO
add mapped point data_received[5] data_received[5] -type PO PO
add mapped point data_received[4] data_received[4] -type PO PO
add mapped point data_received[3] data_received[3] -type PO PO
add mapped point data_received[2] data_received[2] -type PO PO
add mapped point data_received[1] data_received[1] -type PO PO
add mapped point data_received[0] data_received[0] -type PO PO

//inout ports
add mapped point sda sda




//Sequential Pins
add mapped point counter[2]/q counter_reg[2]/Q -type DFF DFF
add mapped point counter[0]/q counter_reg[0]/Q -type DFF DFF
add mapped point counter[1]/q counter_reg[1]/Q -type DFF DFF
add mapped point state[1]/q state_reg[1]/Q -type DFF DFF
add mapped point sda_drive_en/q sda_drive_en_reg/Q -type DFF DFF
add mapped point state[0]/q state_reg[0]/Q -type DFF DFF
add mapped point state[2]/q state_reg[2]/Q -type DFF DFF
add mapped point address_reg[0]/q address_reg_reg[0]/Q -type DFF DFF
add mapped point address_reg[6]/q address_reg_reg[6]/Q -type DFF DFF
add mapped point address_reg[4]/q address_reg_reg[4]/Q -type DFF DFF
add mapped point address_reg[2]/q address_reg_reg[2]/Q -type DFF DFF
add mapped point address_reg[1]/q address_reg_reg[1]/Q -type DFF DFF
add mapped point address_reg[7]/q address_reg_reg[7]/Q -type DFF DFF
add mapped point address_reg[5]/q address_reg_reg[5]/Q -type DFF DFF
add mapped point address_reg[3]/q address_reg_reg[3]/Q -type DFF DFF
add mapped point data_received[2]/q data_received_reg[2]/Q -type DFF DFF
add mapped point data_received[5]/q data_received_reg[5]/Q -type DFF DFF
add mapped point data_received[4]/q data_received_reg[4]/Q -type DFF DFF
add mapped point data_received[0]/q data_received_reg[0]/Q -type DFF DFF
add mapped point data_received[1]/q data_received_reg[1]/Q -type DFF DFF
add mapped point data_received[6]/q data_received_reg[6]/Q -type DFF DFF
add mapped point data_received[7]/q data_received_reg[7]/Q -type DFF DFF
add mapped point data_received[3]/q data_received_reg[3]/Q -type DFF DFF
add mapped point start_event/q start_event_reg/Q -type DFF DFF



//Black Boxes



//Empty Modules as Blackboxes
