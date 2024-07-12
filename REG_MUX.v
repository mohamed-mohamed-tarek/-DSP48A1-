module REG_MUX(clk,sel,CE,rst,in,out);
parameter N=18;
parameter RSTTYPE="SYNC";
input clk,sel,CE,rst;
input [N-1:0] in;
output [N-1:0] out;
reg [N-1:0] OUT_REG;

generate
	if(RSTTYPE=="SYNC")
		always @(posedge clk or posedge rst) begin
			if (rst) begin
				OUT_REG<=0;			
				
			end
			else if(CE) begin
				OUT_REG<=in;
			end
		end
	if(RSTTYPE=="ASYNC")
		always @(posedge clk) begin
			if (rst) begin
				OUT_REG<=0;
				
			end
			else if (CE) begin
				OUT_REG<=in;
			end
		end
	
endgenerate

assign out =(sel)? OUT_REG:in;
endmodule

