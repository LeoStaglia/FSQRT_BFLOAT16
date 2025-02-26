`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2020 10:11:33 PM
// Design Name: 
// Module Name: lampFPU_sqrt
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

import lampFPU_pkg::*;

module lampFPU_sqrt(

input                                       clk,
input                                       rst, 
input logic                                 doSqrt_i,
input logic [(LAMP_FLOAT_F_DW+1)-1:0]       extF_op1_i,
input logic [LAMP_FLOAT_E_DW-1:0]           e_op1_i,
input logic                                 s_op1_i,
input logic                                 isZ_op1_i,
input logic                                 isInf_op1_i,
input logic                                 isSNaN_op1_i,
input logic                                 isQNaN_op1_i,
input logic                                 isOpInv_i,

output logic                                s_res_o,
output logic [LAMP_FLOAT_E_DW-1:0]          e_res_o,
//+2 comes from integer digit and overflow (always 0), +3 are G, R, S bits
output logic [(LAMP_FLOAT_F_DW+2+3)-1:0]    f_res_o,	
output logic                                valid_o,
output logic                                isToRound_o
);

localparam IDLE = 2'b00, WORK = 2'b01, CALC = 2'b10, RESULT = 2'b11;
localparam NUMBER_OF_ITERATIONS = 5;
localparam STICKYANALYSIS = 1;
localparam SHIFT_CONST4=2, SHIFT_CONST2=1;
localparam APPROX_CONST4 = 'd112 << (LAMP_FLOAT_F_DW - 7), APPROX_CONST2 = 'd368 << (LAMP_FLOAT_F_DW - 7);

//state registers
logic [1:0]     ss, ss_next;

logic [(LAMP_FLOAT_F_DW+1+3)-1:0]           b_r, b_next;
logic [(LAMP_FLOAT_F_DW+1+3)-1:0]           y_r, y_next;
logic [(LAMP_FLOAT_F_DW+1+3)-1:0]           g_r, g_next;
logic [(LAMP_FLOAT_F_DW+1+3)-1:0]           i_r, i_next;
logic [2*(LAMP_FLOAT_F_DW+1+3)-1:0]         y_square_r, y_square_next;
logic                                       s_r, s_r_next;            //to keep in memory the sign of the result, that can be computed immediately
logic [LAMP_FLOAT_E_DW-1:0]                 e_r, e_r_next;            //same as above	
logic [2:0]                                 iteration_r, iteration_next;
logic [8-1:0]                               i_ib_r, i_ib_next;		  //represents the number of bits needed to represent the integer part in the inverse

logic                                       isSNaN_r, isSNaN_next;
logic                                       isQNaN_r, isQNaN_next;
logic                                       isZ_r, isZ_next;
logic                                       isInf_r, isInf_next;
logic                                       isInv_r, isInv_next;	

//dimension of the sizes follows this representation:
//x*(size+i+grs), where x represents the number of float multiplied, size is the dimension of the fractional part, i of the integer part, grs are guard, round, sticky bits
logic [2*(LAMP_FLOAT_F_DW+1+3)-1:0]         g_temp_r;
logic [2*(LAMP_FLOAT_F_DW+1+3)-1:0]         i_temp_r;
logic [(LAMP_FLOAT_F_DW+2+3)-1:0]           y_temp_r; 			//in order to be consistent in sizes
logic [3*(LAMP_FLOAT_F_DW+1+3)-1:0]         b_partial_r;
logic [7:0]                                 lzeros_r;
logic [7:0]	                                lzeros_inv_r;
logic [LAMP_FLOAT_E_DW-1:0]                 e_div2_r;


always @(posedge clk)
begin
    if(rst)
    begin
        ss          <= IDLE;
        b_r         <= '0;		
        y_r         <= '0;
        g_r         <= '0;
		i_r			<= '0;
		y_square_r  <= '0;
        s_r         <= '0;
        e_r         <= '0;
        isSNaN_r    <= '0;
        isQNaN_r    <= '0;
        isZ_r       <= '0;
        isInf_r     <= '0;
        iteration_r <= '0;
		i_ib_r		<= '0;
		isInv_r     <= '0;
    end
    else
    begin
        ss <= ss_next;
        b_r <= b_next;
        y_r <= y_next;
        g_r <= g_next;
		i_r <= i_next;
		y_square_r <= y_square_next;
        s_r <= s_r_next;
        e_r <= e_r_next;
        isSNaN_r <= isSNaN_next;
        isQNaN_r <= isQNaN_next;
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
    isToRound_o = '0;
    //internal registers
    b_next = b_r;
    y_next = y_r;
    g_next = g_r;
    i_next = i_r;
    y_square_next = y_square_r;
    s_r_next = s_r;
    e_r_next = e_r;
    ss_next = ss;
	isSNaN_next = isSNaN_r;
	isQNaN_next = isQNaN_r;
	isZ_next = isZ_r;
	isInf_next = isInf_r;
	isInv_next = isInv_r;
	iteration_next = iteration_r;
	i_ib_next = i_ib_r;
//-------------------------------------------------------------------------------------------------------------------------------------------------------
    case(ss)
        IDLE:
        begin
            if(doSqrt_i)
            begin
                isInv_next = isOpInv_i;
                if(s_op1_i)
                begin
                    ss_next = RESULT;
                    s_r_next = '1;
                    isQNaN_next = '1;
                end
                else if(isZ_op1_i | isInf_op1_i | isQNaN_op1_i | isSNaN_op1_i)
                begin
                    ss_next = RESULT;
                    s_r_next = s_op1_i;
					if(isOpInv_i)
					begin
					   if(isSNaN_op1_i | isQNaN_op1_i)
					       isQNaN_next = 'd1;
					   else if(isZ_op1_i)
					       isInf_next = 'd1;
					   else if(isInf_op1_i)
					       isZ_next = 'd1;
					end
					else
					begin
                        isQNaN_next = isSNaN_op1_i | isQNaN_op1_i;
                        isZ_next = isZ_op1_i;
                        isInf_next = isInf_op1_i;
                   end
                end
                else
                begin
                    ss_next = WORK;
                    b_next = (e_op1_i[0] || (e_op1_i == '0)) ? {extF_op1_i, 3'd0} : {1'd0, extF_op1_i, 2'd0};     //if exp is even, unbiased is odd, so divided by 2 would lead to fractionary exponent
                    e_div2_r = (e_op1_i >> 1);                                                                      //to solve this we put part of the exponent inside the mantissa and make it even
                    e_r_next = ~(isOpInv_i) ? e_div2_r + ('b1 << (LAMP_FLOAT_E_DW - 2)) : ('b11 << LAMP_FLOAT_E_DW -2) - 'd2 - e_div2_r;                                           //line added to handle invsqrt case
                    s_r_next = s_op1_i;                                                                                 //exponent calculation can be done immediately then
                    g_next = b_next;                                                                                     //second constructor is first constructor >> 1
                    i_next = 'b1 << (LAMP_FLOAT_F_DW + 3);//11'b10000000000;
                    i_ib_next = 'd1;
                    iteration_next = '0;	
                end
            end
        end				// ifffffffgrs
        WORK:			// 110000000000
        begin			// iifffffffgrs
            if(b_r <= APPROX_CONST4)
            begin
                //Y is clamped to 4
                b_next = b_r << SHIFT_CONST4*2; //We know shifting is appliable (without loss of information) due to numerical analysis
                g_next = g_r << SHIFT_CONST4;
                i_ib_next = i_ib_r + SHIFT_CONST4; //the invsqrt is considered by adding only the shifting factor to the number of non-fractional bits the shifting factor
                iteration_next = iteration_r+1;
                if(iteration_r < NUMBER_OF_ITERATIONS - 1 && b_next != ('b1 << (LAMP_FLOAT_F_DW + 3)))//'b10000000000        
                    ss_next = WORK;
                 else
                    ss_next = RESULT;
                
            end
            else if(b_r > APPROX_CONST4 && b_r <= APPROX_CONST2)
            begin
                //Y is clamped to 2
                b_next = b_r << SHIFT_CONST2*2; //We know shifting is appliable (without loss of information) due to numerical analysis
                g_next = g_r << SHIFT_CONST2;
                i_ib_next = i_ib_r + SHIFT_CONST2; //the invsqrt is considered by adding only the shifting factor to the number of non-fractional bits the shifting factor
                iteration_next = iteration_r+1;
                if(iteration_r < NUMBER_OF_ITERATIONS - 1 && b_next != ('b1 << (LAMP_FLOAT_F_DW + 3)))        
                    ss_next = WORK;
                else
                    ss_next = RESULT;
                
            end
            else
            begin
                y_temp_r = ('b11 << (LAMP_FLOAT_F_DW + 3)) - ({1'b0, b_r}); //12'b110000000000
                y_next = {y_temp_r[(LAMP_FLOAT_F_DW+2+3)-1:2], y_temp_r[1]};                         //taking the first 8 bits of the result of the previous operations (we are sure that the most significant bit will always be 0)
                y_square_next = {y_temp_r[(LAMP_FLOAT_F_DW+2+3)-1:2], y_temp_r[1]} * {y_temp_r[(LAMP_FLOAT_F_DW+2+3)-1:2], y_temp_r[1]};
                ss_next = CALC;
            end
        end 
        CALC:
        begin
            b_partial_r = b_r * y_square_r;
            b_next = b_partial_r[((LAMP_FLOAT_F_DW+3) * 3) -: (LAMP_FLOAT_F_DW+1+3)];                //each number has 7+3 fractional digits, 3 multiplications implies 30 fractional digits, bit indexed 30 is the first integer digit
            g_temp_r = (g_r * y_r);                //we use only the most relevant bits for the multiplication. The result would have 2 integer digits, so we shift         
            g_next = {g_temp_r[2*(LAMP_FLOAT_F_DW+3)+1-1 -: (1+LAMP_FLOAT_F_DW+2)], |g_temp_r[(LAMP_FLOAT_F_DW + 3) -:STICKYANALYSIS]};
            i_temp_r = (i_r * y_r);
            lzeros_inv_r = FUNC_numLeadingZeros(i_temp_r[2*(LAMP_FLOAT_F_DW+1+3)-1 -:8]);
            i_ib_next = i_ib_r + 1 - lzeros_inv_r;
            i_temp_r = i_temp_r << lzeros_inv_r;
            i_next = {i_temp_r[2*(LAMP_FLOAT_F_DW+1+3)-1 -:(LAMP_FLOAT_F_DW+1+2)], |i_temp_r[(LAMP_FLOAT_F_DW + 3) -: STICKYANALYSIS]};        //check if this notation can work, otherwise use << 
            iteration_next = iteration_r + 1;
            if(iteration_r < NUMBER_OF_ITERATIONS - 1 && b_next != ('b1 << (LAMP_FLOAT_F_DW + 3)))        
                ss_next = WORK;
            else
                ss_next = RESULT;
        end
        RESULT:
		begin
		    valid_o = '1;
            //5'b0 is there because top truncates last 5 bits in case of exceptional values
            unique if(isQNaN_r)
                {s_res_o, e_res_o, f_res_o} = {s_r, QNAN_E_F, 5'b0};        
            else if(isSNaN_r)
                {s_res_o, e_res_o, f_res_o} = {s_r, SNAN_E_F, 5'b0};
            else if(isZ_r)
                {s_res_o, e_res_o, f_res_o} = {s_r, ZERO_E_F, 5'b0};
            else if(isInf_r)
                {s_res_o, e_res_o, f_res_o} = {s_r, INF_E_F, 5'b0};
            else 
            begin
                if(~isInv_r)
                begin
                    lzeros_r = FUNC_numLeadingZeros(g_r[(LAMP_FLOAT_F_DW+1+3)-1 -:8]);
                    s_res_o = s_r;
                    e_res_o = e_r - lzeros_r;
                    f_res_o = {1'b0, g_r << lzeros_r};
                end
                else
                begin
                    s_res_o = s_r;
                    e_res_o = e_r + i_ib_r - 1;
                    f_res_o = {1'b0, i_r};
                end
            end
            isToRound_o = ~(isQNaN_r | isSNaN_r | isZ_r | isInf_r);
            
            ss_next = IDLE;
            isQNaN_next = '0;
            isSNaN_next = '0;
            isZ_next = '0;
            isInf_next = '0;            
        end
    endcase 
end
endmodule
