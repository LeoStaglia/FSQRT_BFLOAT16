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

input clk,

input rst, 

input valid_i,

input logic [(7+1)-1:0] extF_op1_i,

//to insert the package inclusion for the constants.

input logic [(8+1)-1:0] extE_op1_i,

input logic s_op1_i,

output logic s_res_o,

output logic [(8+1)-1:0] e_res_o,

output logic [(7+1)-1:0] f_res_o,

output logic valid_o

);

localparam IDLE = 2'b00, WORK = 2'b01, CALC = 2'b10, RESULT = 2'b11;
localparam NUMBER_OF_ITERATIONS = 5;

//state registers
logic [1:0] ss, ss_next;

logic [(7+1)-1:0] b, b_next;
logic [(7+1)-1:0] y, y_next;
logic [(7+1)-1:0] g, g_next;
logic s_o, s_o_next; //to keep in memory the sign of the result, that can be computer immediately
logic [(8+1)-1:0] e_o, e_o_next; //same as above

logic [2:0] iteration_r, iteration_next;

logic [8:0] y_temp; //in order to be consistent in sizes

logic [15:0] y_square;
logic [23:0] b_partial;

always @(posedge clk)
begin
    if(rst)
    begin
        ss <= IDLE;
        b <= '0;
        y <= '0;
        g <= '0;
        s_o <= '0;
        e_o <= '0;
        iteration_r <= '0;
    end
    else
    begin
        ss <= ss_next;
        b <= b_next;
        y <= y_next;
        g <= g_next;
        s_o <= s_o_next;
        e_o <= e_o_next;
        iteration_r <= iteration_next;
    end

end


always@(*)
begin
    //output
    valid_o = '0;
    e_res_o = '0;
    f_res_o = '0;
    s_res_o = '0;
    //internal registers
    b_next = b;
    y_next = y;
    g_next = g;
    s_o_next = s_o;
    e_o_next = e_o;
    ss_next = ss;
//-------------------------------------------------------------------------------------------------------------------------------------------------------
    case(ss)
        IDLE:
        begin
            if(valid_i)
            begin
                b_next = extF_op1_i;
                e_o_next = ((extE_op1_i - 127) >> 2) + 127; //exponent calculation can be done immediately for normalized numbers
                s_o_next = s_op1_i;
                g_next <= '1;
                if(s_o_next == 0)
                    ss_next = WORK;
                else
                    ss_next = RESULT; // case of negative argument for square root (NaN)
            end
        end
        WORK:
        begin
            if(iteration_r < NUMBER_OF_ITERATIONS)
                begin
                    y_temp = ((9'b110000000 - ({1'b0, b})) >> 2);
                    y_next = y_temp[7:0]; //taking the first 8 bits of the result of the previous operations (we are sure that the most significant bit will always be 0)
                    g_next = g * y_next;
                    ss_next = CALC;
                end
            else
                ss_next = RESULT;
        end 
        CALC:
        begin
            y_square = y * y;
            b_partial = b * y_square;
            b_next = b_partial[23 -: 8];
            iteration_next = iteration_r + 1;
        end
        
        //missing result state.
            
    
    
    endcase
    
end

 



endmodule
