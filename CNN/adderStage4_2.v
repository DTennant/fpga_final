/*
	Author: Aniket Badhan
	Description: Addition stage 4 of Convolution layer 2, convolution of convolved image and convolved pattern
*/

`timescale 1ns / 1ps

module adderStage4_2(
    	input [18:0] input1,
    	input [18:0] input2,
	input [18:0] input3,
    	output reg [20:0] output1,
	input enable,
    	input clk,
	output reg done
    );
	
	always @ (posedge clk) begin
		if(enable) begin
			output1 <= {{2{input1[18]}}, input1} + {{2{input2[18]}}, input2} + {{2{input3[18]}}, input3};
			done <= 1'b1;
		end
		else begin
			output1 <= 0;
			done <= 1'b0;
		end
	end
	
endmodule
