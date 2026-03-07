module i2c_master_controller (clk,
    enable,
    i2c_scl,
    i2c_sda,
    ready,
    rst,
    rw,
    address,
    data_in,
    data_out);
 input clk;
 input enable;
 inout i2c_scl;
 inout i2c_sda;
 output ready;
 input rst;
 input rw;
 input [6:0] address;
 input [7:0] data_in;
 output [7:0] data_out;

 wire _000_;
 wire _001_;
 wire _002_;
 wire _003_;
 wire _004_;
 wire _005_;
 wire _006_;
 wire _007_;
 wire _008_;
 wire _009_;
 wire _010_;
 wire _011_;
 wire _012_;
 wire _013_;
 wire _014_;
 wire _015_;
 wire _016_;
 wire _017_;
 wire _018_;
 wire _019_;
 wire _020_;
 wire _021_;
 wire _022_;
 wire _023_;
 wire _024_;
 wire _025_;
 wire _026_;
 wire _027_;
 wire _028_;
 wire _029_;
 wire _030_;
 wire _031_;
 wire _032_;
 wire _033_;
 wire _034_;
 wire _035_;
 wire _036_;
 wire _037_;
 wire _038_;
 wire _039_;
 wire _040_;
 wire _041_;
 wire _042_;
 wire _043_;
 wire _044_;
 wire _045_;
 wire _046_;
 wire _047_;
 wire _048_;
 wire _049_;
 wire _050_;
 wire _051_;
 wire _052_;
 wire _053_;
 wire _054_;
 wire _055_;
 wire _056_;
 wire _057_;
 wire _058_;
 wire _059_;
 wire _060_;
 wire _061_;
 wire _062_;
 wire _063_;
 wire _064_;
 wire _065_;
 wire _066_;
 wire _067_;
 wire _068_;
 wire _069_;
 wire _070_;
 wire _071_;
 wire _072_;
 wire _073_;
 wire _074_;
 wire _075_;
 wire _076_;
 wire _077_;
 wire _078_;
 wire _079_;
 wire _080_;
 wire _081_;
 wire _082_;
 wire _083_;
 wire _084_;
 wire _085_;
 wire _086_;
 wire _087_;
 wire _088_;
 wire _089_;
 wire _090_;
 wire _091_;
 wire _092_;
 wire _093_;
 wire _094_;
 wire _095_;
 wire _096_;
 wire _097_;
 wire _098_;
 wire _099_;
 wire _100_;
 wire _101_;
 wire _102_;
 wire _103_;
 wire _104_;
 wire _105_;
 wire _106_;
 wire _107_;
 wire _108_;
 wire _109_;
 wire _110_;
 wire _111_;
 wire _112_;
 wire _113_;
 wire _114_;
 wire _115_;
 wire _116_;
 wire _117_;
 wire _118_;
 wire _119_;
 wire _120_;
 wire _121_;
 wire _122_;
 wire _123_;
 wire _124_;
 wire _125_;
 wire _126_;
 wire _127_;
 wire _128_;
 wire _129_;
 wire _130_;
 wire _131_;
 wire _132_;
 wire _133_;
 wire _134_;
 wire \address_reg[0] ;
 wire \address_reg[1] ;
 wire \address_reg[2] ;
 wire \address_reg[3] ;
 wire \address_reg[4] ;
 wire \address_reg[5] ;
 wire \address_reg[6] ;
 wire \address_reg[7] ;
 wire \clk_counter[0] ;
 wire \clk_counter[1] ;
 wire \clk_counter[2] ;
 wire \counter[0] ;
 wire \counter[1] ;
 wire \counter[2] ;
 wire \counter[3] ;
 wire i2c_clk;
 wire scl_enable;
 wire sda_drive_en;
 wire sda_out;
 wire \state[0] ;
 wire \state[1] ;
 wire \state[2] ;
 wire \state[3] ;
 wire \state[4] ;
 wire \state[5] ;
 wire \state[6] ;
 wire \state[7] ;
 wire \state[8] ;
 wire \state[9] ;
 wire \write_data_reg[0] ;
 wire \write_data_reg[1] ;
 wire \write_data_reg[2] ;
 wire \write_data_reg[3] ;
 wire \write_data_reg[4] ;
 wire \write_data_reg[5] ;
 wire \write_data_reg[6] ;
 wire \write_data_reg[7] ;
 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire net7;
 wire net8;
 wire net9;
 wire net10;
 wire net11;
 wire net12;
 wire net13;
 wire net14;
 wire net15;
 wire net16;
 wire net17;
 wire net18;
 wire net19;
 wire net20;
 wire net21;
 wire net22;
 wire net23;
 wire net24;
 wire net25;
 wire net26;
 wire net27;
 wire net28;
 wire net29;
 wire net30;
 wire net31;
 wire net32;
 wire net33;
 wire net34;
 wire net35;
 wire net36;
 wire net37;
 wire net38;
 wire net39;
 wire net40;
 wire clknet_0_clk;
 wire clknet_1_0__leaf_clk;
 wire clknet_1_1__leaf_clk;
 wire net41;
 wire net42;
 wire net43;
 wire net44;

 sky130_fd_sc_hd__inv_2 _135_ (.A(net39),
    .Y(_028_));
 sky130_fd_sc_hd__inv_2 _136_ (.A(sda_drive_en),
    .Y(_134_));
 sky130_fd_sc_hd__inv_2 _137_ (.A(\state[9] ),
    .Y(_064_));
 sky130_fd_sc_hd__inv_2 _138_ (.A(net34),
    .Y(_025_));
 sky130_fd_sc_hd__inv_2 _139_ (.A(i2c_sda),
    .Y(_065_));
 sky130_fd_sc_hd__inv_2 _140_ (.A(net33),
    .Y(_066_));
 sky130_fd_sc_hd__inv_2 _141_ (.A(\state[0] ),
    .Y(_067_));
 sky130_fd_sc_hd__inv_2 _142_ (.A(net41),
    .Y(_000_));
 sky130_fd_sc_hd__inv_2 _143_ (.A(\address_reg[0] ),
    .Y(_068_));
 sky130_fd_sc_hd__or2_2 _144_ (.A(\counter[0] ),
    .B(\counter[1] ),
    .X(_069_));
 sky130_fd_sc_hd__inv_2 _145_ (.A(_069_),
    .Y(_070_));
 sky130_fd_sc_hd__o21ba_1 _146_ (.A1(\address_reg[0] ),
    .A2(_069_),
    .B1_N(net32),
    .X(_071_));
 sky130_fd_sc_hd__and2_1 _147_ (.A(\counter[0] ),
    .B(\counter[1] ),
    .X(_072_));
 sky130_fd_sc_hd__nand2_2 _148_ (.A(\counter[0] ),
    .B(\counter[1] ),
    .Y(_073_));
 sky130_fd_sc_hd__and2b_1 _149_ (.A_N(\counter[0] ),
    .B(\counter[1] ),
    .X(_074_));
 sky130_fd_sc_hd__nand2b_1 _150_ (.A_N(\counter[0] ),
    .B(\counter[1] ),
    .Y(_075_));
 sky130_fd_sc_hd__or3b_1 _151_ (.A(\counter[0] ),
    .B(\address_reg[2] ),
    .C_N(\counter[1] ),
    .X(_076_));
 sky130_fd_sc_hd__nand2b_2 _152_ (.A_N(\counter[1] ),
    .B(\counter[0] ),
    .Y(_077_));
 sky130_fd_sc_hd__inv_2 _153_ (.A(_077_),
    .Y(_078_));
 sky130_fd_sc_hd__o221a_1 _154_ (.A1(\address_reg[3] ),
    .A2(_073_),
    .B1(_077_),
    .B2(\address_reg[1] ),
    .C1(_076_),
    .X(_079_));
 sky130_fd_sc_hd__o21a_1 _155_ (.A1(\write_data_reg[3] ),
    .A2(_073_),
    .B1(net32),
    .X(_080_));
 sky130_fd_sc_hd__or3_1 _156_ (.A(\counter[0] ),
    .B(\counter[1] ),
    .C(\write_data_reg[0] ),
    .X(_081_));
 sky130_fd_sc_hd__o221a_1 _157_ (.A1(\write_data_reg[2] ),
    .A2(_075_),
    .B1(_077_),
    .B2(\write_data_reg[1] ),
    .C1(_081_),
    .X(_082_));
 sky130_fd_sc_hd__a22o_1 _158_ (.A1(_071_),
    .A2(_079_),
    .B1(_080_),
    .B2(_082_),
    .X(_083_));
 sky130_fd_sc_hd__nor2_1 _159_ (.A(\state[8] ),
    .B(net32),
    .Y(_084_));
 sky130_fd_sc_hd__mux2_1 _160_ (.A0(\address_reg[4] ),
    .A1(\write_data_reg[4] ),
    .S(net32),
    .X(_085_));
 sky130_fd_sc_hd__mux2_1 _161_ (.A0(\address_reg[7] ),
    .A1(\write_data_reg[7] ),
    .S(net32),
    .X(_086_));
 sky130_fd_sc_hd__mux2_1 _162_ (.A0(\address_reg[5] ),
    .A1(\write_data_reg[5] ),
    .S(\state[7] ),
    .X(_087_));
 sky130_fd_sc_hd__mux2_1 _163_ (.A0(\address_reg[6] ),
    .A1(\write_data_reg[6] ),
    .S(\state[7] ),
    .X(_088_));
 sky130_fd_sc_hd__or2_1 _164_ (.A(_075_),
    .B(_088_),
    .X(_089_));
 sky130_fd_sc_hd__o21a_1 _165_ (.A1(_073_),
    .A2(_086_),
    .B1(net33),
    .X(_090_));
 sky130_fd_sc_hd__o22a_1 _166_ (.A1(_069_),
    .A2(_085_),
    .B1(_087_),
    .B2(_077_),
    .X(_091_));
 sky130_fd_sc_hd__a31o_1 _167_ (.A1(_089_),
    .A2(_090_),
    .A3(_091_),
    .B1(_084_),
    .X(_092_));
 sky130_fd_sc_hd__a21o_1 _168_ (.A1(_066_),
    .A2(_083_),
    .B1(_092_),
    .X(_093_));
 sky130_fd_sc_hd__nor3_1 _169_ (.A(\state[1] ),
    .B(\state[3] ),
    .C(\state[5] ),
    .Y(_094_));
 sky130_fd_sc_hd__or3_1 _170_ (.A(sda_out),
    .B(\state[8] ),
    .C(net32),
    .X(_095_));
 sky130_fd_sc_hd__a31o_1 _171_ (.A1(_093_),
    .A2(_094_),
    .A3(_095_),
    .B1(\state[6] ),
    .X(_047_));
 sky130_fd_sc_hd__or4_1 _172_ (.A(_134_),
    .B(\state[9] ),
    .C(\state[4] ),
    .D(\state[2] ),
    .X(_096_));
 sky130_fd_sc_hd__or4bb_1 _173_ (.A(net32),
    .B(\state[6] ),
    .C_N(_094_),
    .D_N(_096_),
    .X(_046_));
 sky130_fd_sc_hd__or3_1 _174_ (.A(_000_),
    .B(\clk_counter[1] ),
    .C(net43),
    .X(_097_));
 sky130_fd_sc_hd__xnor2_1 _175_ (.A(net35),
    .B(net44),
    .Y(_033_));
 sky130_fd_sc_hd__nand2_1 _176_ (.A(_065_),
    .B(net16),
    .Y(_098_));
 sky130_fd_sc_hd__a221o_1 _177_ (.A1(i2c_sda),
    .A2(\state[2] ),
    .B1(_098_),
    .B2(\state[4] ),
    .C1(\state[1] ),
    .X(_009_));
 sky130_fd_sc_hd__nor2_1 _178_ (.A(\counter[2] ),
    .B(_069_),
    .Y(_099_));
 sky130_fd_sc_hd__nor4_1 _179_ (.A(\counter[0] ),
    .B(\counter[1] ),
    .C(\counter[3] ),
    .D(net33),
    .Y(_100_));
 sky130_fd_sc_hd__or3_2 _180_ (.A(\counter[3] ),
    .B(net33),
    .C(_069_),
    .X(_101_));
 sky130_fd_sc_hd__a32o_1 _181_ (.A1(_065_),
    .A2(\state[2] ),
    .A3(_068_),
    .B1(_101_),
    .B2(net32),
    .X(_010_));
 sky130_fd_sc_hd__a21o_1 _182_ (.A1(\state[8] ),
    .A2(_101_),
    .B1(\state[3] ),
    .X(_011_));
 sky130_fd_sc_hd__a32o_1 _183_ (.A1(_065_),
    .A2(\state[2] ),
    .A3(\address_reg[0] ),
    .B1(_101_),
    .B2(\state[9] ),
    .X(_012_));
 sky130_fd_sc_hd__nor2_1 _184_ (.A(net16),
    .B(_067_),
    .Y(_102_));
 sky130_fd_sc_hd__a311o_1 _185_ (.A1(_065_),
    .A2(net16),
    .A3(\state[4] ),
    .B1(\state[6] ),
    .C1(_102_),
    .X(_008_));
 sky130_fd_sc_hd__nor2_1 _186_ (.A(net40),
    .B(_067_),
    .Y(net27));
 sky130_fd_sc_hd__nand2_4 _187_ (.A(_025_),
    .B(scl_enable),
    .Y(i2c_scl));
 sky130_fd_sc_hd__nand2_1 _188_ (.A(\clk_counter[0] ),
    .B(\clk_counter[1] ),
    .Y(_103_));
 sky130_fd_sc_hd__or2_1 _189_ (.A(\clk_counter[0] ),
    .B(\clk_counter[1] ),
    .X(_104_));
 sky130_fd_sc_hd__o211a_1 _190_ (.A1(_000_),
    .A2(net42),
    .B1(_103_),
    .C1(_104_),
    .X(_001_));
 sky130_fd_sc_hd__xnor2_1 _191_ (.A(net42),
    .B(_103_),
    .Y(_002_));
 sky130_fd_sc_hd__nor3_1 _192_ (.A(\state[0] ),
    .B(\state[6] ),
    .C(\state[5] ),
    .Y(_003_));
 sky130_fd_sc_hd__and2_1 _193_ (.A(net16),
    .B(\state[0] ),
    .X(_007_));
 sky130_fd_sc_hd__and2_1 _194_ (.A(net32),
    .B(net30),
    .X(_006_));
 sky130_fd_sc_hd__nor2_1 _195_ (.A(_064_),
    .B(_101_),
    .Y(_004_));
 sky130_fd_sc_hd__and2_1 _196_ (.A(\state[8] ),
    .B(net30),
    .X(_005_));
 sky130_fd_sc_hd__or3_1 _197_ (.A(\state[9] ),
    .B(\state[8] ),
    .C(net32),
    .X(_105_));
 sky130_fd_sc_hd__a221oi_1 _198_ (.A1(i2c_sda),
    .A2(\state[2] ),
    .B1(net31),
    .B2(_105_),
    .C1(net39),
    .Y(_106_));
 sky130_fd_sc_hd__o31a_1 _199_ (.A1(\state[2] ),
    .A2(\state[3] ),
    .A3(_105_),
    .B1(_106_),
    .X(_107_));
 sky130_fd_sc_hd__inv_2 _200_ (.A(_107_),
    .Y(_108_));
 sky130_fd_sc_hd__nand2_1 _201_ (.A(_105_),
    .B(_106_),
    .Y(_109_));
 sky130_fd_sc_hd__mux2_1 _202_ (.A0(_107_),
    .A1(_109_),
    .S(\counter[0] ),
    .X(_034_));
 sky130_fd_sc_hd__o32a_1 _203_ (.A1(_070_),
    .A2(_072_),
    .A3(_109_),
    .B1(_107_),
    .B2(\counter[1] ),
    .X(_035_));
 sky130_fd_sc_hd__nor2_1 _204_ (.A(_066_),
    .B(_070_),
    .Y(_110_));
 sky130_fd_sc_hd__o32a_1 _205_ (.A1(_099_),
    .A2(_109_),
    .A3(_110_),
    .B1(_107_),
    .B2(\counter[2] ),
    .X(_036_));
 sky130_fd_sc_hd__o21a_1 _206_ (.A1(net33),
    .A2(_069_),
    .B1(\counter[3] ),
    .X(_111_));
 sky130_fd_sc_hd__nor2_1 _207_ (.A(_100_),
    .B(_111_),
    .Y(_112_));
 sky130_fd_sc_hd__a2bb2o_1 _208_ (.A1_N(_112_),
    .A2_N(_109_),
    .B1(_108_),
    .B2(\counter[3] ),
    .X(_037_));
 sky130_fd_sc_hd__and3b_1 _209_ (.A_N(net40),
    .B(net16),
    .C(\state[0] ),
    .X(_113_));
 sky130_fd_sc_hd__a31oi_4 _210_ (.A1(_028_),
    .A2(\state[9] ),
    .A3(_067_),
    .B1(net28),
    .Y(_114_));
 sky130_fd_sc_hd__nor2_1 _211_ (.A(_101_),
    .B(_114_),
    .Y(_115_));
 sky130_fd_sc_hd__a2bb2o_1 _212_ (.A1_N(net19),
    .A2_N(_115_),
    .B1(net29),
    .B2(_064_),
    .X(_116_));
 sky130_fd_sc_hd__a21oi_1 _213_ (.A1(_065_),
    .A2(_115_),
    .B1(_116_),
    .Y(_038_));
 sky130_fd_sc_hd__nor3_1 _214_ (.A(\counter[3] ),
    .B(net33),
    .C(_077_),
    .Y(_117_));
 sky130_fd_sc_hd__o21bai_1 _215_ (.A1(_064_),
    .A2(_117_),
    .B1_N(_114_),
    .Y(_118_));
 sky130_fd_sc_hd__nor2_2 _216_ (.A(_064_),
    .B(_114_),
    .Y(_119_));
 sky130_fd_sc_hd__a32o_1 _217_ (.A1(i2c_sda),
    .A2(_117_),
    .A3(_119_),
    .B1(_118_),
    .B2(net20),
    .X(_039_));
 sky130_fd_sc_hd__and3_1 _218_ (.A(i2c_sda),
    .B(_112_),
    .C(_119_),
    .X(_120_));
 sky130_fd_sc_hd__or3_1 _219_ (.A(\counter[3] ),
    .B(net33),
    .C(_075_),
    .X(_121_));
 sky130_fd_sc_hd__a21o_1 _220_ (.A1(\state[9] ),
    .A2(_121_),
    .B1(_114_),
    .X(_122_));
 sky130_fd_sc_hd__a32o_1 _221_ (.A1(_066_),
    .A2(_074_),
    .A3(_120_),
    .B1(_122_),
    .B2(net21),
    .X(_040_));
 sky130_fd_sc_hd__o31a_1 _222_ (.A1(\counter[3] ),
    .A2(net33),
    .A3(_073_),
    .B1(\state[9] ),
    .X(_123_));
 sky130_fd_sc_hd__o21a_1 _223_ (.A1(_114_),
    .A2(_123_),
    .B1(net22),
    .X(_124_));
 sky130_fd_sc_hd__a31o_1 _224_ (.A1(_066_),
    .A2(_072_),
    .A3(_120_),
    .B1(_124_),
    .X(_041_));
 sky130_fd_sc_hd__or2_1 _225_ (.A(\counter[3] ),
    .B(_066_),
    .X(_125_));
 sky130_fd_sc_hd__or2_1 _226_ (.A(_069_),
    .B(_125_),
    .X(_126_));
 sky130_fd_sc_hd__mux2_1 _227_ (.A0(i2c_sda),
    .A1(net23),
    .S(_126_),
    .X(_127_));
 sky130_fd_sc_hd__a22o_1 _228_ (.A1(net23),
    .A2(_114_),
    .B1(_119_),
    .B2(_127_),
    .X(_042_));
 sky130_fd_sc_hd__o21a_1 _229_ (.A1(_077_),
    .A2(_125_),
    .B1(net24),
    .X(_128_));
 sky130_fd_sc_hd__a22o_1 _230_ (.A1(net24),
    .A2(_114_),
    .B1(_119_),
    .B2(_128_),
    .X(_129_));
 sky130_fd_sc_hd__a31o_1 _231_ (.A1(net33),
    .A2(_078_),
    .A3(_120_),
    .B1(_129_),
    .X(_043_));
 sky130_fd_sc_hd__o21a_1 _232_ (.A1(_075_),
    .A2(_125_),
    .B1(net25),
    .X(_130_));
 sky130_fd_sc_hd__a22o_1 _233_ (.A1(net25),
    .A2(_114_),
    .B1(_119_),
    .B2(_130_),
    .X(_131_));
 sky130_fd_sc_hd__a31o_1 _234_ (.A1(net33),
    .A2(_074_),
    .A3(_120_),
    .B1(_131_),
    .X(_044_));
 sky130_fd_sc_hd__o21bai_1 _235_ (.A1(_073_),
    .A2(_125_),
    .B1_N(net26),
    .Y(_132_));
 sky130_fd_sc_hd__or3_1 _236_ (.A(i2c_sda),
    .B(_073_),
    .C(_125_),
    .X(_133_));
 sky130_fd_sc_hd__a32o_1 _237_ (.A1(_119_),
    .A2(_132_),
    .A3(_133_),
    .B1(_114_),
    .B2(net26),
    .X(_045_));
 sky130_fd_sc_hd__mux2_1 _238_ (.A0(\address_reg[0] ),
    .A1(net18),
    .S(net28),
    .X(_048_));
 sky130_fd_sc_hd__mux2_1 _239_ (.A0(\address_reg[1] ),
    .A1(net1),
    .S(net29),
    .X(_049_));
 sky130_fd_sc_hd__mux2_1 _240_ (.A0(\address_reg[2] ),
    .A1(net2),
    .S(net29),
    .X(_050_));
 sky130_fd_sc_hd__mux2_1 _241_ (.A0(\address_reg[3] ),
    .A1(net3),
    .S(net29),
    .X(_051_));
 sky130_fd_sc_hd__mux2_1 _242_ (.A0(\address_reg[4] ),
    .A1(net4),
    .S(net28),
    .X(_052_));
 sky130_fd_sc_hd__mux2_1 _243_ (.A0(\address_reg[5] ),
    .A1(net5),
    .S(net28),
    .X(_053_));
 sky130_fd_sc_hd__mux2_1 _244_ (.A0(\address_reg[6] ),
    .A1(net6),
    .S(net28),
    .X(_054_));
 sky130_fd_sc_hd__mux2_1 _245_ (.A0(\address_reg[7] ),
    .A1(net7),
    .S(net28),
    .X(_055_));
 sky130_fd_sc_hd__mux2_1 _246_ (.A0(\write_data_reg[0] ),
    .A1(net8),
    .S(net29),
    .X(_056_));
 sky130_fd_sc_hd__mux2_1 _247_ (.A0(\write_data_reg[1] ),
    .A1(net9),
    .S(net29),
    .X(_057_));
 sky130_fd_sc_hd__mux2_1 _248_ (.A0(\write_data_reg[2] ),
    .A1(net10),
    .S(net29),
    .X(_058_));
 sky130_fd_sc_hd__mux2_1 _249_ (.A0(\write_data_reg[3] ),
    .A1(net11),
    .S(net29),
    .X(_059_));
 sky130_fd_sc_hd__mux2_1 _250_ (.A0(\write_data_reg[4] ),
    .A1(net12),
    .S(net28),
    .X(_060_));
 sky130_fd_sc_hd__mux2_1 _251_ (.A0(\write_data_reg[5] ),
    .A1(net13),
    .S(net28),
    .X(_061_));
 sky130_fd_sc_hd__mux2_1 _252_ (.A0(\write_data_reg[6] ),
    .A1(net14),
    .S(net28),
    .X(_062_));
 sky130_fd_sc_hd__mux2_1 _253_ (.A0(\write_data_reg[7] ),
    .A1(net15),
    .S(net28),
    .X(_063_));
 sky130_fd_sc_hd__inv_2 _254_ (.A(net39),
    .Y(_026_));
 sky130_fd_sc_hd__inv_2 _255_ (.A(net39),
    .Y(_024_));
 sky130_fd_sc_hd__inv_2 _256_ (.A(net40),
    .Y(_013_));
 sky130_fd_sc_hd__inv_2 _257_ (.A(net40),
    .Y(_014_));
 sky130_fd_sc_hd__inv_2 _258_ (.A(net40),
    .Y(_015_));
 sky130_fd_sc_hd__inv_2 _259_ (.A(net39),
    .Y(_016_));
 sky130_fd_sc_hd__inv_2 _260_ (.A(net39),
    .Y(_017_));
 sky130_fd_sc_hd__inv_2 _261_ (.A(net39),
    .Y(_018_));
 sky130_fd_sc_hd__inv_2 _262_ (.A(net39),
    .Y(_019_));
 sky130_fd_sc_hd__inv_2 _263_ (.A(net39),
    .Y(_020_));
 sky130_fd_sc_hd__inv_2 _264_ (.A(net39),
    .Y(_021_));
 sky130_fd_sc_hd__inv_2 _265_ (.A(net17),
    .Y(_022_));
 sky130_fd_sc_hd__inv_2 _266_ (.A(net40),
    .Y(_023_));
 sky130_fd_sc_hd__inv_2 _267_ (.A(net34),
    .Y(_027_));
 sky130_fd_sc_hd__inv_2 _268_ (.A(net35),
    .Y(_029_));
 sky130_fd_sc_hd__inv_2 _269_ (.A(net40),
    .Y(_030_));
 sky130_fd_sc_hd__inv_2 _270_ (.A(net40),
    .Y(_031_));
 sky130_fd_sc_hd__inv_2 _271_ (.A(net40),
    .Y(_032_));
 sky130_fd_sc_hd__dfstp_1 _272_ (.CLK(clknet_1_1__leaf_clk),
    .D(_033_),
    .SET_B(_013_),
    .Q(i2c_clk));
 sky130_fd_sc_hd__dfxtp_2 _273_ (.CLK(net37),
    .D(_034_),
    .Q(\counter[0] ));
 sky130_fd_sc_hd__dfxtp_2 _274_ (.CLK(net36),
    .D(_035_),
    .Q(\counter[1] ));
 sky130_fd_sc_hd__dfxtp_1 _275_ (.CLK(net37),
    .D(_036_),
    .Q(\counter[2] ));
 sky130_fd_sc_hd__dfxtp_1 _276_ (.CLK(net36),
    .D(_037_),
    .Q(\counter[3] ));
 sky130_fd_sc_hd__dfxtp_1 _277_ (.CLK(net36),
    .D(_038_),
    .Q(net19));
 sky130_fd_sc_hd__dfxtp_1 _278_ (.CLK(net36),
    .D(_039_),
    .Q(net20));
 sky130_fd_sc_hd__dfxtp_1 _279_ (.CLK(net36),
    .D(_040_),
    .Q(net21));
 sky130_fd_sc_hd__dfxtp_1 _280_ (.CLK(net36),
    .D(_041_),
    .Q(net22));
 sky130_fd_sc_hd__dfxtp_1 _281_ (.CLK(net36),
    .D(_042_),
    .Q(net23));
 sky130_fd_sc_hd__dfxtp_1 _282_ (.CLK(net36),
    .D(_043_),
    .Q(net24));
 sky130_fd_sc_hd__dfxtp_1 _283_ (.CLK(net36),
    .D(_044_),
    .Q(net25));
 sky130_fd_sc_hd__dfxtp_1 _284_ (.CLK(net36),
    .D(_045_),
    .Q(net26));
 sky130_fd_sc_hd__dfstp_1 _285_ (.CLK(net35),
    .D(_008_),
    .SET_B(_014_),
    .Q(\state[0] ));
 sky130_fd_sc_hd__dfrtp_1 _286_ (.CLK(net35),
    .D(_004_),
    .RESET_B(_015_),
    .Q(\state[1] ));
 sky130_fd_sc_hd__dfrtp_2 _287_ (.CLK(net38),
    .D(_005_),
    .RESET_B(_016_),
    .Q(\state[2] ));
 sky130_fd_sc_hd__dfrtp_1 _288_ (.CLK(net35),
    .D(\state[5] ),
    .RESET_B(_017_),
    .Q(\state[3] ));
 sky130_fd_sc_hd__dfrtp_1 _289_ (.CLK(net35),
    .D(_006_),
    .RESET_B(_018_),
    .Q(\state[4] ));
 sky130_fd_sc_hd__dfrtp_1 _290_ (.CLK(net35),
    .D(_007_),
    .RESET_B(_019_),
    .Q(\state[5] ));
 sky130_fd_sc_hd__dfrtp_1 _291_ (.CLK(net35),
    .D(_009_),
    .RESET_B(_020_),
    .Q(\state[6] ));
 sky130_fd_sc_hd__dfrtp_1 _292_ (.CLK(net35),
    .D(_010_),
    .RESET_B(_021_),
    .Q(\state[7] ));
 sky130_fd_sc_hd__dfrtp_1 _293_ (.CLK(net38),
    .D(_011_),
    .RESET_B(_022_),
    .Q(\state[8] ));
 sky130_fd_sc_hd__dfrtp_4 _294_ (.CLK(net35),
    .D(_012_),
    .RESET_B(_023_),
    .Q(\state[9] ));
 sky130_fd_sc_hd__dfstp_1 _295_ (.CLK(_025_),
    .D(_046_),
    .SET_B(_024_),
    .Q(sda_drive_en));
 sky130_fd_sc_hd__dfstp_1 _296_ (.CLK(_027_),
    .D(_047_),
    .SET_B(_026_),
    .Q(sda_out));
 sky130_fd_sc_hd__dfxtp_1 _297_ (.CLK(net38),
    .D(_048_),
    .Q(\address_reg[0] ));
 sky130_fd_sc_hd__dfxtp_1 _298_ (.CLK(net37),
    .D(_049_),
    .Q(\address_reg[1] ));
 sky130_fd_sc_hd__dfxtp_1 _299_ (.CLK(net37),
    .D(_050_),
    .Q(\address_reg[2] ));
 sky130_fd_sc_hd__dfxtp_1 _300_ (.CLK(net37),
    .D(_051_),
    .Q(\address_reg[3] ));
 sky130_fd_sc_hd__dfxtp_1 _301_ (.CLK(net34),
    .D(_052_),
    .Q(\address_reg[4] ));
 sky130_fd_sc_hd__dfxtp_1 _302_ (.CLK(net34),
    .D(_053_),
    .Q(\address_reg[5] ));
 sky130_fd_sc_hd__dfxtp_1 _303_ (.CLK(net34),
    .D(_054_),
    .Q(\address_reg[6] ));
 sky130_fd_sc_hd__dfxtp_1 _304_ (.CLK(net34),
    .D(_055_),
    .Q(\address_reg[7] ));
 sky130_fd_sc_hd__dfxtp_1 _305_ (.CLK(net37),
    .D(_056_),
    .Q(\write_data_reg[0] ));
 sky130_fd_sc_hd__dfxtp_1 _306_ (.CLK(net37),
    .D(_057_),
    .Q(\write_data_reg[1] ));
 sky130_fd_sc_hd__dfxtp_1 _307_ (.CLK(net37),
    .D(_058_),
    .Q(\write_data_reg[2] ));
 sky130_fd_sc_hd__dfxtp_1 _308_ (.CLK(net37),
    .D(_059_),
    .Q(\write_data_reg[3] ));
 sky130_fd_sc_hd__dfxtp_1 _309_ (.CLK(net34),
    .D(_060_),
    .Q(\write_data_reg[4] ));
 sky130_fd_sc_hd__dfxtp_1 _310_ (.CLK(net34),
    .D(_061_),
    .Q(\write_data_reg[5] ));
 sky130_fd_sc_hd__dfxtp_1 _311_ (.CLK(net34),
    .D(_062_),
    .Q(\write_data_reg[6] ));
 sky130_fd_sc_hd__dfxtp_1 _312_ (.CLK(net34),
    .D(_063_),
    .Q(\write_data_reg[7] ));
 sky130_fd_sc_hd__dfrtp_1 _313_ (.CLK(_029_),
    .D(_003_),
    .RESET_B(_028_),
    .Q(scl_enable));
 sky130_fd_sc_hd__dfrtp_1 _314_ (.CLK(clknet_1_0__leaf_clk),
    .D(_000_),
    .RESET_B(_030_),
    .Q(\clk_counter[0] ));
 sky130_fd_sc_hd__dfrtp_1 _315_ (.CLK(clknet_1_1__leaf_clk),
    .D(_001_),
    .RESET_B(_031_),
    .Q(\clk_counter[1] ));
 sky130_fd_sc_hd__dfrtp_1 _316_ (.CLK(clknet_1_0__leaf_clk),
    .D(_002_),
    .RESET_B(_032_),
    .Q(\clk_counter[2] ));
 sky130_fd_sc_hd__ebufn_8 _317_ (.A(sda_out),
    .TE_B(_134_),
    .Z(i2c_sda));
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Right_0 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Right_1 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Right_2 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Right_3 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Right_4 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Right_5 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Right_6 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Right_7 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Right_8 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Right_9 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Right_10 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Right_11 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Right_12 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_13_Right_13 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_14_Right_14 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_15_Right_15 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_16_Right_16 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_17_Right_17 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_18_Right_18 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_19_Right_19 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_20_Right_20 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_21_Right_21 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_22_Right_22 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_23_Right_23 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_24_Right_24 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Left_25 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Left_26 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Left_27 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Left_28 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Left_29 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Left_30 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Left_31 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Left_32 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Left_33 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Left_34 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Left_35 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Left_36 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Left_37 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_13_Left_38 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_14_Left_39 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_15_Left_40 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_16_Left_41 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_17_Left_42 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_18_Left_43 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_19_Left_44 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_20_Left_45 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_21_Left_46 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_22_Left_47 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_23_Left_48 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_24_Left_49 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_50 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_51 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_52 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_53 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_54 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_1_55 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_1_56 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_57 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_58 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_59 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_3_60 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_3_61 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_62 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_63 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_64 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_5_65 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_5_66 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_67 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_68 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_69 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_7_70 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_7_71 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_72 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_73 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_74 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_9_75 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_9_76 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_77 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_78 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_79 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_11_80 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_11_81 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_82 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_83 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_84 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_13_85 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_13_86 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_14_87 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_14_88 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_14_89 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_15_90 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_15_91 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_16_92 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_16_93 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_16_94 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_17_95 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_17_96 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_18_97 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_18_98 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_18_99 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_19_100 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_19_101 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_20_102 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_20_103 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_20_104 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_21_105 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_21_106 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_22_107 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_22_108 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_22_109 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_23_110 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_23_111 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_24_112 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_24_113 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_24_114 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_24_115 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_24_116 ();
 sky130_fd_sc_hd__clkbuf_1 input1 (.A(address[0]),
    .X(net1));
 sky130_fd_sc_hd__clkbuf_1 input2 (.A(address[1]),
    .X(net2));
 sky130_fd_sc_hd__clkbuf_1 input3 (.A(address[2]),
    .X(net3));
 sky130_fd_sc_hd__clkbuf_1 input4 (.A(address[3]),
    .X(net4));
 sky130_fd_sc_hd__clkbuf_1 input5 (.A(address[4]),
    .X(net5));
 sky130_fd_sc_hd__clkbuf_1 input6 (.A(address[5]),
    .X(net6));
 sky130_fd_sc_hd__clkbuf_1 input7 (.A(address[6]),
    .X(net7));
 sky130_fd_sc_hd__clkbuf_1 input8 (.A(data_in[0]),
    .X(net8));
 sky130_fd_sc_hd__clkbuf_1 input9 (.A(data_in[1]),
    .X(net9));
 sky130_fd_sc_hd__clkbuf_1 input10 (.A(data_in[2]),
    .X(net10));
 sky130_fd_sc_hd__clkbuf_1 input11 (.A(data_in[3]),
    .X(net11));
 sky130_fd_sc_hd__clkbuf_1 input12 (.A(data_in[4]),
    .X(net12));
 sky130_fd_sc_hd__clkbuf_1 input13 (.A(data_in[5]),
    .X(net13));
 sky130_fd_sc_hd__clkbuf_1 input14 (.A(data_in[6]),
    .X(net14));
 sky130_fd_sc_hd__clkbuf_1 input15 (.A(data_in[7]),
    .X(net15));
 sky130_fd_sc_hd__buf_1 input16 (.A(enable),
    .X(net16));
 sky130_fd_sc_hd__buf_1 input17 (.A(rst),
    .X(net17));
 sky130_fd_sc_hd__clkbuf_1 input18 (.A(rw),
    .X(net18));
 sky130_fd_sc_hd__buf_2 output19 (.A(net19),
    .X(data_out[0]));
 sky130_fd_sc_hd__buf_2 output20 (.A(net20),
    .X(data_out[1]));
 sky130_fd_sc_hd__buf_2 output21 (.A(net21),
    .X(data_out[2]));
 sky130_fd_sc_hd__buf_2 output22 (.A(net22),
    .X(data_out[3]));
 sky130_fd_sc_hd__buf_2 output23 (.A(net23),
    .X(data_out[4]));
 sky130_fd_sc_hd__buf_2 output24 (.A(net24),
    .X(data_out[5]));
 sky130_fd_sc_hd__buf_2 output25 (.A(net25),
    .X(data_out[6]));
 sky130_fd_sc_hd__buf_2 output26 (.A(net26),
    .X(data_out[7]));
 sky130_fd_sc_hd__buf_2 output27 (.A(net27),
    .X(ready));
 sky130_fd_sc_hd__clkbuf_4 fanout28 (.A(_113_),
    .X(net28));
 sky130_fd_sc_hd__buf_2 fanout29 (.A(_113_),
    .X(net29));
 sky130_fd_sc_hd__clkbuf_1 max_cap30 (.A(net31),
    .X(net30));
 sky130_fd_sc_hd__clkbuf_1 max_cap31 (.A(_100_),
    .X(net31));
 sky130_fd_sc_hd__buf_2 fanout32 (.A(\state[7] ),
    .X(net32));
 sky130_fd_sc_hd__buf_2 fanout33 (.A(\counter[2] ),
    .X(net33));
 sky130_fd_sc_hd__buf_2 fanout34 (.A(net38),
    .X(net34));
 sky130_fd_sc_hd__buf_2 fanout35 (.A(net38),
    .X(net35));
 sky130_fd_sc_hd__clkbuf_2 fanout36 (.A(net38),
    .X(net36));
 sky130_fd_sc_hd__clkbuf_2 fanout37 (.A(net38),
    .X(net37));
 sky130_fd_sc_hd__clkbuf_2 fanout38 (.A(i2c_clk),
    .X(net38));
 sky130_fd_sc_hd__buf_4 fanout39 (.A(net40),
    .X(net39));
 sky130_fd_sc_hd__clkbuf_4 fanout40 (.A(net17),
    .X(net40));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_0_clk (.A(clk),
    .X(clknet_0_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_1_0__f_clk (.A(clknet_0_clk),
    .X(clknet_1_0__leaf_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_1_1__f_clk (.A(clknet_0_clk),
    .X(clknet_1_1__leaf_clk));
 sky130_fd_sc_hd__clkbuf_4 clkload0 (.A(clknet_1_1__leaf_clk));
 sky130_fd_sc_hd__dlygate4sd3_1 hold1 (.A(\clk_counter[0] ),
    .X(net41));
 sky130_fd_sc_hd__dlygate4sd3_1 hold2 (.A(\clk_counter[2] ),
    .X(net42));
 sky130_fd_sc_hd__dlygate4sd3_1 hold3 (.A(\clk_counter[2] ),
    .X(net43));
 sky130_fd_sc_hd__dlygate4sd3_1 hold4 (.A(_097_),
    .X(net44));
endmodule
