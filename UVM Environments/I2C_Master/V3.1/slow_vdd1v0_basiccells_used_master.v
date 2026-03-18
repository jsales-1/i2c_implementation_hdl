//
// Conformal-LEC: Version 15.10-s220 (27-Aug-2015) (64 bit executable)
//
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

module DFFHQX1(Q, D, CK);
input  D, CK;
output Q;
wire  Q, D, CK, QBINT;
  _HDFF_verplex U$1(.Q(Q), .QN(QBINT), .S(1'b0), .R(1'b0), .CK(CK), .D(D));
endmodule

module MX2X1(Y, A, B, S0);
input  A, B, S0;
output Y;
wire  Y, A, B, S0, n$1, n$2, n$3;
  or U$1(Y, n$1, n$2);
  and U$2(n$1, S0, B);
  and U$3(n$2, n$3, A);
  not U$4(n$3, S0);
endmodule

module OAI211X1(Y, A0, A1, B0, C0);
input  A0, A1, B0, C0;
output Y;
wire  Y, A0, A1, B0, C0, n$1;
  nand U$1(Y, n$1, B0, C0);
  or U$2(n$1, A0, A1);
endmodule

module NAND4BXL(Y, AN, B, C, D);
input  AN, B, C, D;
output Y;
wire  Y, AN, B, C, D, n$1;
  nand U$1(Y, n$1, B, C, D);
  not U$2(n$1, AN);
endmodule

module AOI21XL(Y, A0, A1, B0);
input  A0, A1, B0;
output Y;
wire  Y, A0, A1, B0, n$1;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, A0, A1);
endmodule

module NAND4XL(Y, A, B, C, D);
input  A, B, C, D;
output Y;
wire  Y, A, B, C, D;
  nand U$1(Y, A, B, C, D);
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

module AOI33XL(Y, A0, A1, A2, B0, B1, B2);
input  B0, B1, B2, A0, A1, A2;
output Y;
wire  Y, A0, A1, A2, B0, B1, B2, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, B0, B1, B2);
  and U$3(n$2, A0, A1, A2);
endmodule

module AOI32X1(Y, A0, A1, A2, B0, B1);
input  B0, B1, A0, A1, A2;
output Y;
wire  Y, A0, A1, A2, B0, B1, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, B0, B1);
  and U$3(n$2, A0, A1, A2);
endmodule

module NAND2XL(Y, A, B);
input  A, B;
output Y;
wire  Y, A, B;
  nand U$1(Y, A, B);
endmodule

module OAI221X1(Y, A0, A1, B0, B1, C0);
input  A0, A1, B0, B1, C0;
output Y;
wire  Y, A0, A1, B0, B1, C0, n$1, n$2;
  nand U$1(Y, n$1, n$2, C0);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
endmodule

module SDFFQX1(Q, D, SE, SI, CK);
input  D, SE, SI, CK;
output Q;
wire  Q, D, SE, SI, CK, QBINT, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(Q), .QN(QBINT), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  or U$3(n$1, n$2, n$3);
  and U$4(n$2, SE, SI);
  and U$5(n$3, n$4, D);
  not U$6(n$4, SE);
endmodule

module MXI2XL(Y, A, B, S0);
input  A, B, S0;
output Y;
wire  Y, A, B, S0, n$1, n$2, n$3;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, S0, B);
  and U$3(n$2, n$3, A);
  not U$4(n$3, S0);
endmodule

module AOI31X1(Y, A0, A1, A2, B0);
input  A0, A1, A2, B0;
output Y;
wire  Y, A0, A1, A2, B0, n$1;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, A0, A1, A2);
endmodule

module NAND3BXL(Y, AN, B, C);
input  AN, B, C;
output Y;
wire  Y, AN, B, C, n$1;
  nand U$1(Y, n$1, B, C);
  not U$2(n$1, AN);
endmodule

module NAND2BXL(Y, AN, B);
input  AN, B;
output Y;
wire  Y, AN, B, n$1;
  nand U$1(Y, n$1, B);
  not U$2(n$1, AN);
endmodule

module AOI222X1(Y, A0, A1, B0, B1, C0, C1);
input  C0, C1, A0, A1, B0, B1;
output Y;
wire  Y, A0, A1, B0, B1, C0, C1, n$1, n$2, n$3;
  nor U$1(Y, n$1, n$2, n$3);
  and U$2(n$1, C0, C1);
  and U$3(n$2, A0, A1);
  and U$4(n$3, B0, B1);
endmodule

module NOR2XL(Y, A, B);
input  A, B;
output Y;
wire  Y, A, B;
  nor U$1(Y, A, B);
endmodule

module NOR2BX1(Y, AN, B);
input  AN, B;
output Y;
wire  Y, AN, B, n$1;
  nor U$1(Y, n$1, B);
  not U$2(n$1, AN);
endmodule

module OR2X1(Y, A, B);
input  A, B;
output Y;
wire  Y, A, B;
  or U$1(Y, A, B);
endmodule

module DFFSHQX1(Q, D, SN, CK);
input  D, SN, CK;
output Q;
wire  Q, D, SN, CK, QBINT, n$1;
  _HDFF_verplex U$1(.Q(Q), .QN(QBINT), .S(n$1), .R(1'b0), .CK(CK), .D(D));
  not U$3(n$1, SN);
endmodule

module AND2X1(Y, A, B);
input  A, B;
output Y;
wire  Y, A, B;
  and U$1(Y, A, B);
endmodule

module OAI21XL(Y, A0, A1, B0);
input  A0, A1, B0;
output Y;
wire  Y, A0, A1, B0, n$1;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, A0, A1);
endmodule

module NAND3XL(Y, A, B, C);
input  A, B, C;
output Y;
wire  Y, A, B, C;
  nand U$1(Y, A, B, C);
endmodule

module OAI22XL(Y, A0, A1, B0, B1);
input  B0, B1, A0, A1;
output Y;
wire  Y, A0, A1, B0, B1, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, B0, B1);
  or U$3(n$2, A0, A1);
endmodule

module TBUFX1(Y, A, OE);
input  A, OE;
output Y;
wire  Y, A, OE;
  bufif1 U$1(Y, A, OE);
endmodule

module DFFRX1(Q, QN, D, RN, CK);
input  D, RN, CK;
output Q, QN;
wire  Q, QN, D, RN, CK, n$1;
  _HDFF_verplex U$1(.Q(Q), .QN(QN), .S(1'b0), .R(n$1), .CK(CK), .D(D));
  not U$4(n$1, RN);
endmodule

// ADDITIONAL CELLS NEEDED BASED ON ERRORS
module INVXL(Y, A);
input  A;
output Y;
wire  Y, A;
  not U$1(Y, A);
endmodule

module AOI22XL(Y, A0, A1, B0, B1);
input  B0, B1, A0, A1;
output Y;
wire  Y, A0, A1, B0, B1, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, B0, B1);
  and U$3(n$2, A0, A1);
endmodule

module NOR3XL(Y, A, B, C);
input  A, B, C;
output Y;
wire  Y, A, B, C;
  nor U$1(Y, A, B, C);
endmodule

module OAI22X1(Y, A0, A1, B0, B1);
input  B0, B1, A0, A1;
output Y;
wire  Y, A0, A1, B0, B1, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, B0, B1);
  or U$3(n$2, A0, A1);
endmodule

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

module _HDLAT_verplex(Q, QN, S, R, CK, D);
// verplex DLAT
output  Q, QN;
input   S, R, CK, D;
wire   N1;
  DLAT_UDP i0(N1, S, R, CK, D);
  buf  (Q, N1);
  not  (QN, N1);
endmodule

primitive DLAT_UDP(Q, S, R, CK, D);
output Q;
input  S, R, CK, D;
reg    Q;
  table
    1  0   ?    ?  :  ?  :  1; // Asserting preset
    ?  1   ?    ?  :  ?  :  0; // Asserting reset (dominates preset)
    0  0   1    0  :  ?  :  0; // Data clocked
    0  ?   *    0  :  0  :  0; // Clock transitions
    0  *   0    ?  :  0  :  0; // Changing reset
    0  *   ?    0  :  0  :  0;
    0  0   1    1  :  ?  :  1; // Data clocked
    *  0   0    ?  :  1  :  1; // Changing preset
    *  0   ?    1  :  1  :  1;
    ?  0   *    1  :  1  :  1; // Clock transitions
    0  0   0    ?  :  ?  :  -; // Hold
  endtable
endprimitive