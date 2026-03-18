//
// Conformal-LEC: Version 15.10-s220 (27-Aug-2015) (64 bit executable)
//
// Complete Standard Cell Library Modules for i2c_slave_controller
// Generated on: Mar 18 2026
//

// --- Basic Gates ---
module INVXL(Y, A);
input  A;
output Y;
wire  Y, A;
  not U$1(Y, A);
endmodule

module NAND2XL(Y, A, B);
input  A, B;
output Y;
wire  Y, A, B;
  nand U$1(Y, A, B);
endmodule

module NOR2XL(Y, A, B);
input  A, B;
output Y;
wire  Y, A, B;
  nor U$1(Y, A, B);
endmodule

module NAND2BXL(Y, AN, B);
input  AN, B;
output Y;
wire  Y, AN, B, n$1;
  nand U$1(Y, n$1, B);
  not U$2(n$1, AN);
endmodule

module NAND2BX1(Y, AN, B);
input  AN, B;
output Y;
wire  Y, AN, B, n$1;
  nand U$1(Y, n$1, B);
  not U$2(n$1, AN);
endmodule

module NOR2BX1(Y, AN, B);
input  AN, B;
output Y;
wire  Y, AN, B, n$1;
  nor U$1(Y, n$1, B);
  not U$2(n$1, AN);
endmodule

module NAND3XL(Y, A, B, C);
input  A, B, C;
output Y;
wire  Y, A, B, C;
  nand U$1(Y, A, B, C);
endmodule

module NAND3BXL(Y, AN, B, C);
input  AN, B, C;
output Y;
wire  Y, AN, B, C, n$1;
  nand U$1(Y, n$1, B, C);
  not U$2(n$1, AN);
endmodule

module NAND4XL(Y, A, B, C, D);
input  A, B, C, D;
output Y;
wire  Y, A, B, C, D;
  nand U$1(Y, A, B, C, D);
endmodule

module AND4XL(Y, A, B, C, D);
input  A, B, C, D;
output Y;
wire  Y, A, B, C, D;
  and U$1(Y, A, B, C, D);
endmodule

module NOR4X1(Y, A, B, C, D);
input  A, B, C, D;
output Y;
wire  Y, A, B, C, D;
  nor U$1(Y, A, B, C, D);
endmodule

module NOR3BXL(Y, AN, B, C);
input  AN, B, C;
output Y;
wire  Y, AN, B, C, n$1;
  nor U$1(Y, n$1, B, C);
  not U$2(n$1, AN);
endmodule

module OR2X1(Y, A, B);
input  A, B;
output Y;
wire  Y, A, B;
  or U$1(Y, A, B);
endmodule

// --- Complex Gates ---
module AOI21XL(Y, A0, A1, B0);
input  A0, A1, B0;
output Y;
wire  Y, A0, A1, B0, n$1;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, A0, A1);
endmodule

module AOI22XL(Y, A0, A1, B0, B1);
input  B0, B1, A0, A1;
output Y;
wire  Y, A0, A1, B0, B1, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, B0, B1);
  and U$3(n$2, A0, A1);
endmodule

module AOI31X1(Y, A0, A1, A2, B0);
input  A0, A1, A2, B0;
output Y;
wire  Y, A0, A1, A2, B0, n$1;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, A0, A1, A2);
endmodule

module AOI32X1(Y, A0, A1, A2, B0, B1);
input  B0, B1, A0, A1, A2;
output Y;
wire  Y, A0, A1, A2, B0, B1, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, B0, B1);
  and U$3(n$2, A0, A1, A2);
endmodule

module AOI33XL(Y, A0, A1, A2, B0, B1, B2);
input  B0, B1, B2, A0, A1, A2;
output Y;
wire  Y, A0, A1, A2, B0, B1, B2, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, B0, B1, B2);
  and U$3(n$2, A0, A1, A2);
endmodule

module AOI211XL(Y, A0, A1, B0, C0);
input  A0, A1, B0, C0;
output Y;
wire  Y, A0, A1, B0, C0, n$1;
  nor U$1(Y, n$1, B0, C0);
  and U$2(n$1, A0, A1);
endmodule

module AOI221X1(Y, A0, A1, B0, B1, C0);
input  A0, A1, B0, B1, C0;
output Y;
wire  Y, A0, A1, B0, B1, C0, n$1, n$2;
  nor U$1(Y, n$1, n$2, C0);
  and U$2(n$1, A0, A1);
  and U$3(n$2, B0, B1);
endmodule

module OAI21XL(Y, A0, A1, B0);
input  A0, A1, B0;
output Y;
wire  Y, A0, A1, B0, n$1;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, A0, A1);
endmodule

module OAI21X1(Y, A0, A1, B0);
input  A0, A1, B0;
output Y;
wire  Y, A0, A1, B0, n$1;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, A0, A1);
endmodule

module OAI31X1(Y, A0, A1, A2, B0);
input  A0, A1, A2, B0;
output Y;
wire  Y, A0, A1, A2, B0, n$1;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, A0, A1, A2);
endmodule

module OAI32X1(Y, A0, A1, A2, B0, B1);
input  B0, B1, A0, A1, A2;
output Y;
wire  Y, A0, A1, A2, B0, B1, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, B0, B1);
  or U$3(n$2, A0, A1, A2);
endmodule

module OAI33X1(Y, A0, A1, A2, B0, B1, B2);
input  B0, B1, B2, A0, A1, A2;
output Y;
wire  Y, A0, A1, A2, B0, B1, B2, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, B0, B1, B2);
  or U$3(n$2, A0, A1, A2);
endmodule

module OAI211X1(Y, A0, A1, B0, C0);
input  A0, A1, B0, C0;
output Y;
wire  Y, A0, A1, B0, C0, n$1;
  nand U$1(Y, n$1, B0, C0);
  or U$2(n$1, A0, A1);
endmodule

module OAI2BB1X1(Y, A0N, A1N, B0);
input  A0N, A1N, B0;
output Y;
wire  Y, A0N, A1N, B0, n$1, n$2, n$3;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
endmodule

module OA22X1(Y, A0, A1, B0, B1);
input  A0, A1, B0, B1;
output Y;
wire  Y, A0, A1, B0, B1, n$1, n$2;
  and U$1(Y, n$1, n$2);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
endmodule

// --- Multiplexers ---
module MXI2XL(Y, A, B, S0);
input  A, B, S0;
output Y;
wire  Y, A, B, S0, n$1, n$2, n$3;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, S0, B);
  and U$3(n$2, n$3, A);
  not U$4(n$3, S0);
endmodule

// --- Tri-state Buffers ---
module TBUFXL(Y, A, OE);
input  A, OE;
output Y;
wire  Y, A, OE;
  bufif1 U$1(Y, A, OE);
endmodule

// --- Flip-Flops and Latches ---
module DFFNSRX1(Q, QN, D, RN, SN, CKN);
input  D, RN, SN, CKN;
output Q, QN;
wire  Q, QN, D, RN, SN, CKN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(Q), .QN(QN), .S(n$1), .R(n$5), .CK(n$3), .D(D));
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, CKN);
  not U$7(n$4, n$1);
  and U$8(n$5, n$4, n$2);
endmodule

module DFFRX1(Q, QN, D, RN, CK);
input  D, RN, CK;
output Q, QN;
wire  Q, QN, D, RN, CK, n$1;
  _HDFF_verplex U$1(.Q(Q), .QN(QN), .S(1'b0), .R(n$1), .CK(CK), .D(D));
  not U$4(n$1, RN);
endmodule

module DFFRHQX1(Q, D, RN, CK);
input  D, RN, CK;
output Q;
wire  Q, D, RN, CK, QBINT, n$1;
  _HDFF_verplex U$1(.Q(Q), .QN(QBINT), .S(1'b0), .R(n$1), .CK(CK), .D(D));
  not U$3(n$1, RN);
endmodule

module SDFFRHQX1(Q, D, SE, SI, RN, CK);
input  D, SE, SI, RN, CK;
output Q;
wire  Q, D, SE, SI, RN, CK, QBINT, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(Q), .QN(QBINT), .S(1'b0), .R(n$1), .CK(CK), .D(n$2));
  not U$3(n$1, RN);
  or U$4(n$2, n$3, n$4);
  and U$5(n$3, SE, SI);
  and U$6(n$4, n$5, D);
  not U$7(n$5, SE);
endmodule

// --- Primitives (Required for simulation) ---
module _HDFF_verplex(Q, QN, S, R, CK, D);
// verplex DFF
output  Q, QN;
input   S, R, CK, D;
wire   N1;
  DFF_UDP  i0(N1, S, R, CK, D);
  buf  (Q, N1);
  not  (QN, N1);
endmodule

primitive DFF_UDP(Q, S, R, CK, D);
output Q;
input  S, R, CK, D;
reg    Q;
  table
    1  0   ?    ?  :  ?  :  1; // Asserting preset
    *  0   ?    ?  :  1  :  1; // Changing preset
    ?  1   ?    ?  :  ?  :  0; // Asserting reset (dominates preset)
    0  *   ?    ?  :  0  :  0; // Changing reset
    0  ?   (01) 0  :  ?  :  0; // rising clock
    ?  0   (01) 1  :  ?  :  1; // rising clock 
    0  ?   p    0  :  0  :  0; // potential rising clock
    ?  0   p    1  :  1  :  1; // potential rising clock
    0  0   n    ?  :  ?  :  -; // Clock falling register output does not change
    0  0   ?    *  :  ?  :  -; // Changing Data
  endtable
endprimitive