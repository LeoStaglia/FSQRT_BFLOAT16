`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2020 10:12:47 PM
// Design Name: 
// Module Name: tb_sqrt
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

parameter HALF_CLK_PERIOD_NS=20;

module tb_sqrt();

    import lampFPU_pkg::*;

    import "DPI-C" function int unsigned DPI_fsqrt(input int unsigned op);
    
    logic clk;
    logic rst;
    logic valid_i_tb;
    logic [(7+1)-1:0] extF_op1_i_tb;
    logic [(8+1)-1:0] extE_op1_i_tb;
    logic             s_op1_i_tb;
    logic             isZ_op1_i_tb;
    logic             isInf_op1_i_tb;
    logic             isNaN_op1_i_tb;
    
    logic                s_res_o_tb;
    logic [(8+1)-1:0]    e_res_o_tb;
    logic [(7+2)+3-1:0]  f_res_o_tb;
    logic                valid_o_tb;
    logic                isNaN_o_tb;
    logic                isZ_o_tb;
    logic                isInf_o_tb;
    
    //useful to pass data to the C function
    logic [7:0]          exp;
    logic [6:0]          frac;
    logic                sign;
    //C function result
    logic [31:0] res;
    
    always #HALF_CLK_PERIOD_NS clk = ~clk;
    
    lampFPU_sqrt 
        lampFPU_sqrt0(
            .clk(clk),
            .rst(rst),
            .valid_i(valid_i_tb),
            .extF_op1_i(extF_op1_i_tb),
            .extE_op1_i(extE_op1_i_tb),
            .s_op1_i(s_op1_i_tb),
            .isZ_op1_i_tb(isZ_op1_i_tb),
            .isInf_op1_i(isInf_op1_i_tb),
            .isNaN_op1_i(isNaN_op1_i_tb),
            .s_res_o(s_res_o_tb),
            .e_res_o(e_res_o_tb),
            .f_res_o(f_res_o_tb),
            .valid_o(valid_o_tb),
            .isNaN_o(isNaN_o_tb),
            .isZ_o(isZ_o_tb),
            .isInf_o(isInf_o_tb)
        );
    
    
    
    initial
    begin
         clk <= 1;
         rst = 1;
         valid_i_tb = '0;
         extF_op1_i_tb = '0;
         extE_op1_i_tb = '0;
         s_op1_i_tb = '0;
         isZ_op1_i_tb = '0;
         isInf_op1_i_tb = '0;
         isNaN_op1_i_tb = '0;
         s_res_o_tb = '0;
         e_res_o_tb = '0;
         f_res_o_tb = '0;
         valid_o_tb = '0;
         isNaN_o_tb = '0;
         isZ_o_tb = '0;
         isInf_o_tb = '0;
         repeat (10) @(posedge clk);
         rst <= 0;
         repeat (10) @(posedge clk);
         
         //creation of the operand
         sign = $urandom_range(0, 1);
         s_op1_i_tb <= sign;
         
         exp = $urandom_range(0, 255);
         extE_op1_i_tb <= {1'b0, exp};
         
         frac = $urandom_range(0, 127);
         if(exp)
            //normalized case 
            extF_op1_i_tb <= {1'b1, frac};
         else
            //unormalized case
            extF_op1_i_tb <= {1'b0, frac};
            
         //checks the particular cases
         //zero
         if(!exp && !frac)
            isZ_op1_i_tb <= 1;
         else
            isZ_op1_i_tb <= 0;
         //inf
         if(exp == 255 && frac == 0)
            isInf_op1_i_tb <= 1;
         else
            isInf_op1_i_tb <= 0;
         //NaN
         if(exp == 255 && frac)
            isNaN_op1_i_tb <= 1;
         else
            isNaN_op1_i_tb <= 0;
            
         while(!valid_o_tb) @(posedge clk);
         
         res = DPI_fsqrt({sign, exp, frac, 16'b0});
         
         if(res[31-:16] == {s_res_o_tb, e_res_o_tb, f_res_o_tb[11-:7]})
            $display("Correct");
         else
            $display("Not correct");
         
         
         
    end
    

endmodule
