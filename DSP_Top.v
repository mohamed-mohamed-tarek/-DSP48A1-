module DSP_Top(A,B,D,C,CLK,CARRYIN,OPMODE,BCIN,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE,PCIN,BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF);
//Parameters
parameter A0REG=1'b0;
parameter A1REG=1'b1;
parameter B0REG=1'b0;
parameter B1REG=1'b1;
parameter CREG=1'b1;
parameter DREG=1'b1;
parameter MREG=1'b1;
parameter PREG=1'b1;
parameter CARRYINREG=1'b1;
parameter CARRYOUTREG=1'b1;
parameter OPMODEREG=1'b1;
parameter CARRYINSEL="OPMODE5";
parameter B_INPUT="DIRECT";
parameter RSTTYPE="SYNC";


input [17:0]A;
input [17:0]B;
input [17:0]BCIN;
input [47:0]C;
input [17:0]D;
input CARRYIN;
output [35:0]M;
output [47:0]P;
output CARRYOUT;
output CARRYOUTF;
//Control Input Ports
input CLK;
input [7:0]OPMODE;
//Clock Enable Input Ports
input CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP;
//Reset Input Ports
input RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP;
//Cascade Ports
input [47:0]PCIN;
output [17:0]BCOUT;
output[47:0]PCOUT;
// wires
wire [17:0] B0_MUX_IN;
wire [17:0] A0_MUX_OUT;
wire [17:0] B0_MUX_OUT;
wire [17:0] D_MUX_OUT;
wire [47:0] C_MUX_OUT;

wire[7:0] OPMODE_MUX_OUT;

wire[17:0] PRE_MUX_OUT;
wire[17:0] B1_MUX_IN;
wire[17:0] A1_MUX_OUT;
wire[17:0] B1_MUX_OUT;
wire [35:0] M_MUX_IN;
wire [35:0] M_MUX_OUT;

wire [47:0] Extended_M;
wire [47:0] D_A_B;

wire[47:0] X_MUX_OUT;
wire[47:0] Z_MUX_OUT;

wire CARRY_INPUT;
wire CARRYIN_MUX_OUT;

wire [47:0] P_MUX_IN;
wire [47:0] P_MUX_OUT;

wire CYO_MUX_IN;
 

//---------- level 1------------------
assign B0_MUX_IN =(B_INPUT=="DIRECT")? B:(B_INPUT=="CASCADE")? BCIN:0;

REG_MUX #(18,RSTTYPE) A0(.clk(CLK),.sel(A0REG),.CE(CEA),.rst(RSTA),.in(A),.out(A0_MUX_OUT));
REG_MUX #(18,RSTTYPE) B0(.clk(CLK),.sel(B0REG),.CE(CEB),.rst(RSTB),.in(B0_MUX_IN),.out(B0_MUX_OUT));
REG_MUX #(18,RSTTYPE) D_REG(.clk(CLK),.sel(DREG),.CE(CED),.rst(RSTD),.in(D),.out(D_MUX_OUT));
REG_MUX #(48,RSTTYPE) C_REG(.clk(CLK),.sel(CREG),.CE(CEC),.rst(RSTC),.in(C),.out(C_MUX_OUT));

REG_MUX #(8,RSTTYPE) OPMODE_REG(.clk(CLK),.sel(OPMODEREG),.CE(CEOPMODE),.rst(RSTOPMODE),.in(OPMODE),.out(OPMODE_MUX_OUT));


//---------- level 2------------------
assign PRE_MUX_OUT =(OPMODE_MUX_OUT[6])? (D_MUX_OUT-B0_MUX_OUT):(D_MUX_OUT+B0_MUX_OUT);
assign B1_MUX_IN =(OPMODE_MUX_OUT[4])? PRE_MUX_OUT:B0_MUX_OUT;

REG_MUX #(18,RSTTYPE) B1(.clk(CLK),.sel(B1REG),.CE(CEB),.rst(RSTB),.in(B1_MUX_IN),.out(B1_MUX_OUT));
REG_MUX #(18,RSTTYPE) A1(.clk(CLK),.sel(A1REG),.CE(CEA),.rst(RSTA),.in(A0_MUX_OUT),.out(A1_MUX_OUT));

assign BCOUT=B1_MUX_OUT;
assign M_MUX_IN =A1_MUX_OUT*B1_MUX_OUT;

REG_MUX #(36,RSTTYPE) M_REG(.clk(CLK),.sel(MREG),.CE(CEM),.rst(RSTM),.in(M_MUX_IN),.out(M_MUX_OUT));

assign M =M_MUX_OUT ;

//---------- level 3------------------
assign Extended_M={{12{M_MUX_OUT[35]}},M_MUX_OUT};
assign D_A_B = {D_MUX_OUT[11:0],A1_MUX_OUT,B1_MUX_OUT};
MUX_4_1 X(.sel(OPMODE_MUX_OUT[1:0]),.in0(48'h000000000000),.in1(Extended_M),.in2(P_MUX_OUT),.in3(D_A_B),.out(X_MUX_OUT));
MUX_4_1 Z(.sel(OPMODE_MUX_OUT[3:2]),.in0(48'h000000000000),.in1(PCIN),.in2(P_MUX_OUT),.in3(C_MUX_OUT),.out(Z_MUX_OUT));

assign CARRY_INPUT =(CARRYINSEL=="OPMODE5")? OPMODE_MUX_OUT[5]:(CARRYINSEL=="CARRYIN")? CARRYIN:0;

REG_MUX #(1,RSTTYPE) CYI(.clk(CLK),.sel(CARRYINREG),.CE(CECARRYIN),.rst(RSTCARRYIN),.in(CARRY_INPUT),.out(CARRYIN_MUX_OUT));

assign {CYO_MUX_IN,P_MUX_IN} =(OPMODE_MUX_OUT[7])? Z_MUX_OUT-(X_MUX_OUT+CARRYIN_MUX_OUT): Z_MUX_OUT+X_MUX_OUT+CARRYIN_MUX_OUT;

REG_MUX #(48,RSTTYPE) P_REG(.clk(CLK),.sel(PREG),.CE(CEP),.rst(RSTP),.in(P_MUX_IN),.out(P_MUX_OUT));

REG_MUX #(1,RSTTYPE) CYO(.clk(CLK),.sel(CARRYOUTREG),.CE(CECARRYIN),.rst(RSTCARRYIN),.in(CYO_MUX_IN),.out(CARRYOUT));
assign P =P_MUX_OUT ;
assign CARRYOUTF = CARRYOUT ;
assign PCOUT = P;



endmodule

