`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2020 10:11:33 PM
// Design Name: 
// Module Name: calc_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module calc_fsm(

input                   clk,
input                   rst, 
input                   valid_i,
input logic [(7+1)-1:0] extF_op1_i,
input logic [(8+1)-1:0] extE_op1_i,
input logic             s_op1_i,
input logic             isZ_op1_i,
input logic             isInf_op1_i,
input logic             isNaN_op1_i,
input logic             isInv_i,

output logic                s_res_o,
output logic [(8+1)-1:0]    e_res_o,
output logic [(7+1)-1 + 3 /*G, R, S bits*/:0]    f_res_o,
output logic                valid_o,
output logic                isNaN_o,
output logic                isZ_o,
output logic                isInf_o
);

import lampFPU_pkg::*;

localparam IDLE = 2'b00, WORK = 2'b01, CALC = 2'b10, RESULT = 2'b11;
localparam NUMBER_OF_ITERATIONS = 5;

//state registers
logic [1:0]     ss, ss_next;

logic [(7+1)-1 + 3 /*G, R, S bits*/:0]           b_r, b_next;
logic [(7+1)-1 + 3 /*G, R, S bits*/:0]           y_r, y_next;
logic [(7+1)-1 + 3 /*G, R, S bits*/:0]        	 g_r, g_next;
logic [(7+1)-1 + 3 /*G, R, S bits*/:0]        	 i_r, i_next;
logic                       s_r, s_r_next;                  //to keep in memory the sign of the result, that can be computed immediately
logic [(8+1)-1:0]           e_r, e_r_next;                  //same as above	
logic [(8+1)-1:0]           e_div2_r;
logic [2:0]                 iteration_r, iteration_next;
logic [8-1:0]	      		i_ib_r, i_ib_next;				//represents the number of bits needed to represent the integer part in the inverse

logic                       isNaN_r, isNaN_next;
logic                       isZ_r, isZ_next;
logic                       isInf_r, isInf_next;
logic                       isInv_r, isInv_next;	

//dimension of the sizes follows this representation:
//x*(size+i+grs), where x represents the number of float multiplied, size is the dimension of the fractional part, i of the integer part, grs are guard, round, sticky bits
logic [2*(7+1+3)-1:0]       g_temp_r;
logic [2*(7+1+3)-1:0]		i_temp_r;
logic [(7+2+3)-1:0]         y_temp_r; 			//in order to be consistent in sizes
logic [2*(7+1+3)-1:0]       y_square_r;
logic [3*(7+1+3)-1:0]       b_partial_r;
logic [7:0]                 lzeros_r;
logic [7:0]					lzeros_inv_r;


always @(posedge clk)
begin
    if(rst)
    begin
        ss          <= IDLE;
        b_r         <= 'x;		
        y_r         <= 'x;
        g_r         <= 'x;
		i_r			<= 'x;
        s_r         <= 'x;
        e_r         <= 'x;              //check if those x create some problems
        isNaN_r     <= 'x;
        isZ_r       <= 'x;
        isInf_r     <= 'x;
        iteration_r <= 'x;
		i_ib_r		<= 'x;
		isInv_r     <= 'x;
    end
    else
    begin
        ss <= ss_next;
        b_r <= b_next;
        y_r <= y_next;
        g_r <= g_next;
		i_r <= i_next;
        s_r <= s_r_next;
        e_r <= e_r_next;
        isNaN_r <= isNaN_next;
        isZ_r <= isZ_next;
        isInf_r <= isInf_next;
        iteration_r <= iteration_next;
		i_ib_r <= i_ib_next;
		isInv_r <= isInv_next;
    end

end


always@(*)
begin
    //output
    valid_o = '0;
    e_res_o = '0;
    f_res_o = '0;
    s_res_o = '0;
    isNaN_o = '0;
    isZ_o   = '0;
    isInf_o = '0;
    //internal registers
    b_next = b_r;
    y_next = y_r;
    g_next = g_r;
    s_r_next = s_r;
    e_r_next = e_r;
    ss_next = ss;
	isNaN_next = isNaN_r;
	isZ_next = isZ_r;
	isInf_next = isInf_r;
	isInv_next = isInv_r;
	iteration_next = iteration_r;
	i_ib_next = i_ib_r;
//-------------------------------------------------------------------------------------------------------------------------------------------------------
    case(ss)
        IDLE:
        begin
            if(valid_i)
            begin
                if(s_op1_i)
                begin
                    ss_next = RESULT;
                    s_r_next = '1;
                    e_r_next = 'd255;
                    g_next = '0 - 1;
                    isNaN_next = '1;
                end
                else if(isZ_op1_i | isInf_op1_i | isNaN_op1_i)
                begin
                    ss_next = RESULT;
                    s_r_next = s_op1_i;
                    e_r_next = extE_op1_i;
                    g_next = {extF_op1_i, 3'd0};
					if(isInv_i)
					begin
					   if(isNaN_op1_i)
					   begin
					       isNaN_next = isNaN_op1_i;
					       isZ_next = isZ_op1_i;
					       isInf_next = isInf_op1_i;
					   end
					   else if(isZ_op1_i)
					   begin
					       isInf_next = 'd1;
					       isZ_next = 'd0;
					       isNaN_next = isNaN_op1_i;
					   end
					   else if(isInf_op1_i)
					   begin
					       isInf_next = 'd0;
					       isZ_next = 'd1;
					       isNaN_next = isNaN_op1_i;
					   end
					end
					else
					begin
                        isNaN_next = isNaN_op1_i;
                        isZ_next = isZ_op1_i;
                        isInf_next = isInf_op1_i;
                   end
                end
                else
                begin
                    ss_next = WORK;
                    isNaN_next  = '0;
                    isZ_next    = '0;
                    isInf_next  = '0;
                    b_next = (extE_op1_i[0] || (extE_op1_i == '0)) ? {extF_op1_i, 3'd0} : {1'd0, extF_op1_i, 2'd0};     //if exp is even, unbiased is odd, so divided by 2 would lead to fractionary exponent
                    e_div2_r = (extE_op1_i >> 1);                                                      			    //to solve this we put part of the exponent inside the mantissa and make it even
                    e_r_next = (isInv_i) ? e_div2_r + 'd64 : 'd190 - e_div2_r;                                           //line added to handle invsqrt case
                    s_r_next = s_op1_i;                                                                     			//exponent calculation can be done immediately then
                    g_next = b_next; 																					//second constructor is first constructor >> 1
					i_next = 11'b10000000000;
					i_ib_next = 'd1;
                    iteration_next = '0;	
                end
            end
        end				// ifffffffgrs
        WORK:			// 110000000000
        begin			// iifffffffgrs
			y_temp_r = 12'b110000000000 - ({1'b0, b_r});
            y_next = {y_temp_r[11:2], |y_temp_r[1:0]};                         //taking the first 8 bits of the result of the previous operations (we are sure that the most significant bit will always be 0)
            ss_next = CALC;
        end 
        CALC:
        begin
            y_square_r = y_r * y_r;
            b_partial_r = b_r * y_square_r;
            b_next = b_partial_r[30 -: 11];				//each number has 7+3 fractional digits, 3 multiplications implies 30 fractional digits, bit indexed 30 is the first integer digit
            g_temp_r = (g_r * y_r);				//we use only the most relevant bits for the multiplication. The result would have 2 integer digits, so we shift		 
			g_next = {g_temp_r[20 -:10], |g_temp_r[10:0]};
			i_temp_r = (i_r * y_r);
			lzeros_inv_r = FUNC_numLeadingZeros(i_temp_r[21-:8]);
			i_ib_next = i_ib_r + 1 - lzeros_inv_r;
			i_temp_r = i_temp_r << lzeros_inv_r;
			i_next = {i_temp_r[21 -:10], |i_temp_r[10:0]};		//check if this notation can work, otherwise use << 
            iteration_next = iteration_r + 1;
            if(iteration_r < NUMBER_OF_ITERATIONS - 1 && b_next != 'b10000000000)        
                ss_next = WORK;
            else
                ss_next = RESULT;
        end
        RESULT:
		begin
			valid_o = '1;
			if(~isInv_r)
			begin
                lzeros_r = FUNC_numLeadingZeros(g_r[10-:8]);
                s_res_o = s_r;
                e_res_o = e_r - lzeros_r;
                f_res_o = g_r << lzeros_r;
            end
            else
            begin
                s_res_o = s_r;
                e_res_o = e_r + i_ib_r - 'd1;
                f_res_o = i_r;
            end
            isNaN_o = isNaN_r;
            isZ_o = isZ_r;
            isInf_o = isInf_r;
            ss_next = IDLE;
        end
    endcase 
end
endmodule
