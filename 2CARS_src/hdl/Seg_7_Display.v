`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:52:53 06/12/2014 
// Design Name: 
// Module Name:    seg7decimal 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module seg7decimal(

	input [31:0] x,
    input clk,
    output reg [6:0] a_to_g,
    output reg [7:0] an,
    output reg dp 
	 );
	 
	 
wire [2:0] s;	 
reg [3:0] digit;
wire [7:0] aen;
reg [19:0] clkdiv;

assign s = clkdiv[19:17];
assign aen = 8'b11111111; // all turned off initially

// quad 4to1 MUX.


always @(posedge clk)// or posedge clr)
	
	case(s)
	0:digit = x[3:0]; // s is 00 -->0 ;  digit gets assigned 4 bit value assigned to x[3:0]
	1:digit = x[7:4]; // s is 01 -->1 ;  digit gets assigned 4 bit value assigned to x[7:4]
	2:digit = x[11:8]; // s is 10 -->2 ;  digit gets assigned 4 bit value assigned to x[11:8
	3:digit = x[15:12]; // s is 11 -->3 ;  digit gets assigned 4 bit value assigned to x[15:12]
	4:digit = x[19:16];
	5:digit = x[23:20];
	6:digit = x[27:24];
	7:digit = x[31:28];
	default:digit = x[3:0];
	
	endcase
	
	//decoder or truth-table for 7a_to_g display values
	always @(*)

case(digit)


//////////<---MSB-LSB<---
//////////////gfedcba////////////////////////////////////////////              a
0:begin
    a_to_g = 7'b1000000;
    dp = 1;
    end
1:begin
    a_to_g = 7'b1111001;
    dp = 1;
    end
2:begin
    a_to_g = 7'b0100100;
    dp = 1;
    end
3:begin
    a_to_g = 7'b0110000;
    dp = 1;
    end
4:begin
    a_to_g = 7'b0011001;
    dp = 1;
    end
5:begin
    a_to_g = 7'b0010010;
    dp = 1;
    end
6:begin
    a_to_g = 7'b0000010;
    dp = 1;
    end
7:begin
    a_to_g = 7'b1111000;
    dp = 1;
    end
8:begin
    a_to_g = 7'b0000000;
    dp = 1;
    end
9:begin
    a_to_g = 7'b0010000;
    dp = 1;
    end

'hA:begin
    a_to_g = 7'b0001000;
    dp = 0;
    end
'hB:begin
    a_to_g = 7'b0000011;
    dp = 0;
    end
'hC:begin
    a_to_g = 7'b1000110;
    dp = 0;
    end
'hD:begin
    a_to_g = 7'b0100001;
    dp = 0;
    end
'hE:begin
    a_to_g = 7'b0000110;
    dp = 0;
    end
'hF:begin
    a_to_g = 7'b0000100;
    dp = 0;
    end

default: a_to_g = 7'b0000000; // U

endcase


always @(*)begin
an=8'b11111111;
if(aen[s] == 1)
an[s] = 0;
end


//clkdiv

always @(posedge clk) begin
clkdiv <= clkdiv+1;
end


endmodule
