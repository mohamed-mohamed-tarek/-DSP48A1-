module MUX_4_1(sel,in0,in1,in2,in3,out);
parameter N=48;
input [1:0] sel;
input [N-1:0] in0,in1,in2,in3;
output reg [N-1:0] out;

always @(*) begin
	case(sel)
		2'b00: out=in0;
		2'b01: out=in1;
		2'b10: out=in2;
		2'b11: out=in3; 
		endcase
end


endmodule