// Copyright 2019 Politecnico di Milano.
// Copyright and related rights are licensed under the Solderpad Hardware
// Licence, Version 2.0 (the "Licence"); you may not use this file except in
// compliance with the Licence. You may obtain a copy of the Licence at
// https://solderpad.org/licenses/SHL-2.0/. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this Licence is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the Licence for the
// specific language governing permissions and limitations under the Licence.
//
// Authors (in alphabetical order):
// Andrea Galimberti    <andrea.galimberti@polimi.it>
// Davide Zoni          <davide.zoni@polimi.it>
//
// Date: 30.09.2019

package lampFPU_pkg;

	parameter LAMP_FLOAT_DW		=	16;
	parameter LAMP_FLOAT_S_DW 	=	1;
	parameter LAMP_FLOAT_E_DW 	=	8;
	parameter LAMP_FLOAT_F_DW 	=	7;

	parameter LAMP_INTEGER_DW	=	32;
	parameter LAMP_INTEGER_S_DW	=	1;
	parameter LAMP_INTEGER_F_DW	=	31;

	parameter LAMP_FLOAT_E_BIAS	=	(2 ** (LAMP_FLOAT_E_DW - 1)) - 1;
	parameter LAMP_FLOAT_E_MAX	=	(2 ** LAMP_FLOAT_E_DW) - 1;

	parameter INF				=	15'h7f80;
	parameter ZERO				=	15'h0000;
	parameter SNAN				=	15'h7fbf;
	parameter QNAN				=	15'h7fc0;

	//	used in TB only
	parameter PLUS_INF			=	16'h7f80;
	parameter MINUS_INF			=	16'hff80;
	parameter PLUS_ZERO			=	16'h0000;
	parameter MINUS_ZERO		=	16'h8000;

	parameter INF_E_F			=	15'b111111110000000; // w/o sign
	parameter SNAN_E_F			=	15'b111111110111111; // w/o sign
	parameter QNAN_E_F			=	15'b111111111000000; // w/o sign
	parameter ZERO_E_F			=	15'b000000000000000; // w/o sign

	//	div-only
	parameter LAMP_APPROX_DW	=	4;
	parameter LAMP_PREC_DW		=	8;
	parameter LAMP_APPROX_MULS	=	$clog2 ((LAMP_FLOAT_DW+1)/LAMP_APPROX_DW);

	typedef enum logic
	{
		FPU_RNDMODE_NEAREST		=	'd0,
		FPU_RNDMODE_TRUNCATE	=	'd1
	} rndModeFPU_t;

	typedef enum logic[3:0]
	{
		FPU_IDLE	= 4'd0,

		FPU_I2F		= 4'd1,
		FPU_F2I		= 4'd2,

		FPU_ADD		= 4'd3,
		FPU_SUB		= 4'd4,
		FPU_MUL		= 4'd5,
		FPU_DIV		= 4'd6,

		FPU_EQ		= 4'd7,
		FPU_LT		= 4'd8,
		FPU_LE		= 4'd9,
		FPU_SQRT    = 4'd10,
		FPU_ISQRT   = 4'd11
	} opcodeFPU_t;

	function automatic logic [LAMP_FLOAT_S_DW+LAMP_FLOAT_E_DW+LAMP_FLOAT_F_DW-1:0] FUNC_splitOperand(input [LAMP_FLOAT_DW-1:0] op);
		return op;
	endfunction

	function automatic logic [LAMP_FLOAT_E_DW+1-1:0] FUNC_extendExp(input [LAMP_FLOAT_E_DW-1:0] e_op, input isDN);
		return	{ 1'b0, e_op[7:1], (e_op[0] | isDN) };
	endfunction

	function automatic logic [LAMP_FLOAT_F_DW+1-1:0] FUNC_extendFrac(input [LAMP_FLOAT_F_DW-1:0] f_op, input isDN, input isZ);
		return	{ (~isDN & ~isZ), f_op};
	endfunction

	function automatic logic FUNC_op1_GT_op2(
			input [LAMP_FLOAT_F_DW+1-1:0] f_op1, input [LAMP_FLOAT_E_DW+1-1:0] e_op1,
			input [LAMP_FLOAT_F_DW+1-1:0] f_op2, input [LAMP_FLOAT_E_DW+1-1:0] e_op2
	);
		logic 		e_op1_GT_op2, e_op1_EQ_op2;
		logic 		f_op1_GT_op2;
		logic 		op1_GT_op2, op1_EQ_op2;

		e_op1_GT_op2 	= (e_op1 > e_op2);
		e_op1_EQ_op2 	= (e_op1 == e_op2);

		f_op1_GT_op2 	= (f_op1 > f_op2);

		op1_GT_op2		= e_op1_GT_op2 | (e_op1_EQ_op2 & f_op1_GT_op2);

		return	op1_GT_op2;
	endfunction

	function automatic logic [$clog2(1+1+LAMP_FLOAT_F_DW+3)-1:0] FUNC_AddSubPostNorm_numLeadingZeros( input [1+1+LAMP_FLOAT_F_DW+3-1:0] f_initial_res);

		casez(f_initial_res)
			12'b1???????????: return  'd0;
			12'b01??????????: return  'd0;
			12'b001?????????: return  'd1;
			12'b0001????????: return  'd2;
			12'b00001???????: return  'd3;
			12'b000001??????: return  'd4;
			12'b0000001?????: return  'd5;
			12'b00000001????: return  'd6;
			12'b000000001???: return  'd7;
			12'b0000000001??: return  'd8;
			12'b00000000001?: return  'd9;
			12'b000000000001: return  'd10;
			12'b000000000000: return  'd0; // zero result
		endcase
	endfunction

	function automatic logic [$clog2(LAMP_FLOAT_F_DW+1)-1:0] FUNC_numLeadingZeros(
					input logic [(LAMP_FLOAT_F_DW+1)-1:0] f_i
				);
				    casez(f_i)
				      8'b1???????: return 'd0;
				      8'b01??????: return 'd1;
				      8'b001?????: return 'd2;
				      8'b0001????: return 'd3;
				      8'b00001???: return 'd4;
				      8'b000001??: return 'd5;
				      8'b0000001?: return 'd6;
				      8'b00000001: return 'd7;
				      8'b00000000: return 'd0; // zero result
    				endcase
	endfunction

	function automatic logic [5-1:0] FUNC_checkOperand(input [LAMP_FLOAT_DW-1:0] op);
		logic [LAMP_FLOAT_S_DW-1:0] s_op;
		logic [LAMP_FLOAT_E_DW-1:0] e_op;
		logic [LAMP_FLOAT_F_DW-1:0] f_op;

		logic isInf_op, isDN_op, isZ_op, isSNAN_op, isQNAN_op;
		s_op = op[15];
		e_op = op[14-:8];
		f_op = op[8:0];

		// check deNorm (isDN), +/-inf (isInf), +/-zero (isZ), not a number (isSNaN, isQNaN)
		isInf_op 	= (&e_op) &  ~(|f_op); 					// E==0xFF	&&	f==0x0
		isDN_op 	= ~(|e_op) & (|f_op);					// E==0x0	&&	f!=0x0
		isZ_op 		= ~(|op[14:0]);							// E==0x0	&&	f==0x0
		isSNAN_op 	= (&e_op) & ~f_op[6] & (|f_op[5:0]);
		isQNAN_op 	= (&e_op) & f_op[6];

		return {isInf_op, isDN_op, isZ_op, isSNAN_op, isQNAN_op};
	endfunction

	function automatic logic [$clog2(LAMP_INTEGER_DW)-1:0] FUNC_i2f_integerExponent(
					input logic [LAMP_INTEGER_DW-1:0] int32_i
				);
					casez(int32_i)
						32'b1???????????????????????????????: return 'd31;
						32'b01??????????????????????????????: return 'd30;
						32'b001?????????????????????????????: return 'd29;
						32'b0001????????????????????????????: return 'd28;
						32'b00001???????????????????????????: return 'd27;
						32'b000001??????????????????????????: return 'd26;
						32'b0000001?????????????????????????: return 'd25;
						32'b00000001????????????????????????: return 'd24;
						32'b000000001???????????????????????: return 'd23;
						32'b0000000001??????????????????????: return 'd22;
						32'b00000000001?????????????????????: return 'd21;
						32'b000000000001????????????????????: return 'd20;
						32'b0000000000001???????????????????: return 'd19;
						32'b00000000000001??????????????????: return 'd18;
						32'b000000000000001?????????????????: return 'd17;
						32'b0000000000000001????????????????: return 'd16;
						32'b00000000000000001???????????????: return 'd15;
						32'b000000000000000001??????????????: return 'd14;
						32'b0000000000000000001?????????????: return 'd13;
						32'b00000000000000000001????????????: return 'd12;
						32'b000000000000000000001???????????: return 'd11;
						32'b0000000000000000000001??????????: return 'd10;
						32'b00000000000000000000001?????????: return 'd9;
						32'b000000000000000000000001????????: return 'd8;
						32'b0000000000000000000000001???????: return 'd7;
						32'b00000000000000000000000001??????: return 'd6;
						32'b000000000000000000000000001?????: return 'd5;
						32'b0000000000000000000000000001????: return 'd4;
						32'b00000000000000000000000000001???: return 'd3;
						32'b000000000000000000000000000001??: return 'd2;
						32'b0000000000000000000000000000001?: return 'd1;
						32'b0000000000000000000000000000000?: return 'd0;
					endcase
	endfunction

	function automatic logic FUNC_i2f_stickyBit(
					input logic [(LAMP_INTEGER_F_DW+3)-1:0] f_i,
					input logic [$clog2(LAMP_INTEGER_DW)-1:0] s_i
				);
					case (s_i)
						0	:	return 1'b0;
						1	:	return 1'b0;
						2	:	return f_i[3];
						3	:	return |f_i[4:3];
						4	:	return |f_i[5:3];
						5	:	return |f_i[6:3];
						6	:	return |f_i[7:3];
						7	:	return |f_i[8:3];
						8	:	return |f_i[9:3];
						9	:	return |f_i[10:3];
						10	:	return |f_i[11:3];
						11	:	return |f_i[12:3];
						12	:	return |f_i[13:3];
						13	:	return |f_i[14:3];
						14	:	return |f_i[15:3];
						15	:	return |f_i[16:3];
						16	:	return |f_i[17:3];
						17	:	return |f_i[18:3];
						18	:	return |f_i[19:3];
						19	:	return |f_i[20:3];
						20	:	return |f_i[21:3];
						21	:	return |f_i[22:3];
						22	:	return |f_i[23:3];
						23	:	return |f_i[24:3];
					endcase
	endfunction

	function automatic logic FUNC_f2i_stickyBit(
					input logic [(LAMP_INTEGER_DW+3)-1:0] f_i,
					input logic [$clog2(LAMP_INTEGER_DW)-1:0] s_i
				);
					case (s_i)
						0	:	return 1'b0;
						1	:	return 1'b0;
						2	:	return f_i[3];
						3	:	return |f_i[4:3];
						4	:	return |f_i[5:3];
						5	:	return |f_i[6:3];
						6	:	return |f_i[7:3];
						7	:	return |f_i[8:3];
						8	:	return |f_i[9:3];
					endcase
	endfunction

	/*
	* FUNC_addsub_calcStickyBit:
	*
	* Calculate the sticky bit in add sub operations.
	*
	* Input: the f mantissa extended with 3 LSB, i.e., G,R,S, one
	* hidden bit, i.e., MSB-1, and an extra MSB for ovf or 2'complement.
	*
	* Output: the computed sticky bit
	*/
	function automatic logic FUNC_addsub_calcStickyBit(
					input logic [(1+LAMP_FLOAT_F_DW+3)-1:0] f_i,
					input logic [(LAMP_FLOAT_E_DW+1)-1:0] num_shr_i
				);
			    case(num_shr_i)
			    	5'd0 :		return 1'b0;		// no right shift -> 0 sticky
					5'd1 :		return 1'b0;		// two added zero bits G,R
					5'd2 :		return 1'b0;		// two added zero bits G,R
					5'd3 :		return f_i[3];
					5'd4 :		return |f_i[3+:1];
			    	5'd5 :		return |f_i[3+:2];
			    	5'd6 :		return |f_i[3+:3];
			    	5'd7 :		return |f_i[3+:4];
			    	5'd8 :		return |f_i[3+:5];
			    	5'd9 :		return |f_i[3+:6];
					default:	return |f_i[3+:7];
			    endcase
		endfunction

	/* FUNC_rndToNearestEven (Round-to-nearest-even):
	*
	* Description: performs the round to nearest even required by the IEEE 754-SP standard
	* with a minor modification to trade performance/area with precision.
	* instead of adding .1 in some scenarios with a possible 23bit carry chain
	* the number of bit in the carry chain is configurable. This way if the
	* considered LSB of the f are all 1 a truncation is performed instead of
	* a rnd. This removes the possible normalization stage after rounding.
	*/
	function automatic logic[LAMP_FLOAT_F_DW-1:0] FUNC_rndToNearestEven
			(
				input [(1/*ovf*/+1/*hidden*/+LAMP_FLOAT_F_DW+3/*G,R,S*/)-1:0]		f_res_postNorm
			);

		localparam NUM_BIT_TO_RND	=	4;

		logic 								isAddOne;
		logic [(1+1+LAMP_FLOAT_F_DW+3)-1:0] tempF_1;
		logic [(1+1+LAMP_FLOAT_F_DW+3)-1:0] tempF;
		//
		// Rnd to nearest even
		//	X0.00 -> X0		|	X1.00 -> X1
		//	X0.01 -> X0		|	X1.01 -> X1
		//	X0.10 -> X0		|	X1.10 -> X1. +1
		//	X0.11 -> X1		|	X1.11 -> X1. +1
		//
		tempF_1 = f_res_postNorm;
		case(f_res_postNorm[3:1] /*3 bits X.G(S|R)*/ )
			3'b0_00:	begin tempF_1[3] = 0;	isAddOne =0; end
			3'b0_01:	begin tempF_1[3] = 0;	isAddOne =0; end
			3'b0_10:	begin tempF_1[3] = 0;	isAddOne =0; end
			3'b0_11:	begin tempF_1[3] = 1;	isAddOne =0; end
			3'b1_00:	begin tempF_1[3] = 1;	isAddOne =0; end
			3'b1_01:	begin tempF_1[3] = 1; 	isAddOne =0; end
			3'b1_10:	begin tempF_1[3] = 1;	isAddOne =1; end
			3'b1_11:	begin tempF_1[3] = 1;	isAddOne =1; end
		endcase

		// limit rnd to NUM_BIT_TO_RND LSBs of the f, truncate otherwise
		// this avoid another normalization step, if any
		if(&tempF_1[3+:NUM_BIT_TO_RND])
			tempF =	tempF_1 ;
		else
			tempF =	tempF_1 + (isAddOne<<3);

		return tempF[3+:LAMP_FLOAT_F_DW];
	endfunction

	function automatic logic[LAMP_INTEGER_DW-1:0] FUNC_f2i_rndToNearestEven
			(
				input [(LAMP_INTEGER_DW+3)-1:0]	f_res_postNorm
			);

		logic							isAddOne;
		logic	[LAMP_INTEGER_DW-1:0]	f_res;

		isAddOne	=	(f_res_postNorm[3] && f_res_postNorm[2]) || (f_res_postNorm[2] && f_res_postNorm[1]);
		f_res		=	f_res_postNorm[3+:LAMP_INTEGER_DW] + isAddOne;

		return f_res;
	endfunction

	/*
	* Nan +/- X	  -> Nan
	* X   +/- Nan -> Nan
	* +inf + +inf -> +inf
	* +inf - -inf -> +inf
	* -inf - +inf -> -inf
	* -inf + -inf -> -inf
	* +inf - inf -> NAN
	* -inf + inf -> NAN
	*/
	function automatic logic[3:0] FUNC_calcInfNanResAddSub (
				input isOpSub_i,
				input isInf_op1_i, input sign_op1_i, input isSNan_op1_i, input isQNan_op1_i,
				input isInf_op2_i, input sign_op2_i, input isSNan_op2_i, input isQNan_op2_i

			);

		logic realOp2_sign;
		logic isNan_op1 = isSNan_op1_i || isQNan_op1_i;
		logic isNan_op2 = isSNan_op2_i || isQNan_op2_i;

		logic isValidRes, isInfRes, isNanRes, signRes;
		realOp2_sign 	= sign_op2_i ^ isOpSub_i;

		isValidRes 		= (isInf_op1_i || isInf_op2_i || isNan_op1 || isNan_op2) ? 1 : 0;
		if (isNan_op1)
		begin //sign is not important, since a Nan remains a nan what-so-ever
			isInfRes = 0; isNanRes = 1; signRes = sign_op1_i;
		end
		else if (isNan_op2)
		begin
			isInfRes = 0; isNanRes = 1; signRes = sign_op2_i;
		end
		else // both are not NaN
		begin
			case({sign_op1_i, isInf_op1_i, realOp2_sign, isInf_op2_i})
				4'b00_00: begin isNanRes = 0; isInfRes = 0; signRes = 0; end
				4'b00_01: begin isNanRes = 0; isInfRes = 1; signRes = 0; end
				4'b00_10: begin isNanRes = 0; isInfRes = 0; signRes = 0; end
				4'b00_11: begin isNanRes = 0; isInfRes = 1; signRes = 1; end
				4'b01_00: begin isNanRes = 0; isInfRes = 1; signRes = 0; end
				4'b01_01: begin isNanRes = 0; isInfRes = 1; signRes = 0; end
				4'b01_10: begin isNanRes = 0; isInfRes = 1; signRes = 0; end
				4'b01_11: begin isNanRes = 1; isInfRes = 0; signRes = 1; end //Nan - NOTE sign goes neg if one of the operands is neg
				4'b10_00: begin isNanRes = 0; isInfRes = 0; signRes = 0; end
				4'b10_01: begin isNanRes = 0; isInfRes = 1; signRes = 0; end
				4'b10_10: begin isNanRes = 0; isInfRes = 0; signRes = 0; end
				4'b10_11: begin isNanRes = 0; isInfRes = 1; signRes = 1; end
				4'b11_00: begin isNanRes = 0; isInfRes = 1; signRes = 1; end
				4'b11_01: begin isNanRes = 1; isInfRes = 0; signRes = 1; end //Nan - NOTE sign goes neg if one of the operands is neg
				4'b11_10: begin isNanRes = 0; isInfRes = 1; signRes = 1; end
				4'b11_11: begin isNanRes = 0; isInfRes = 1; signRes = 1; end
			endcase
		end
		return {isValidRes, isInfRes, isNanRes, signRes};
	endfunction

	/*
	* 		Nan 	x 			X		-> 		 Nan
	* 		X 		x 			Nan 	-> 		 Nan
	* (+/-) inf 	x 	(+/-) 	inf 	-> (+/-) inf
	* (+/-) inf 	x 			0		-> 		 Nan
	* (+/-) inf		x 	(+/-)	X		-> (+/-) inf
	*/
	function automatic logic[4:0] FUNC_calcInfNanZeroResMul (
				input isZero_op1_i, isInf_op1_i, input sign_op1_i, input isSNan_op1_i, input isQNan_op1_i,
				input isZero_op2_i, isInf_op2_i, input sign_op2_i, input isSNan_op2_i, input isQNan_op2_i

			);

		logic isNan_op1 = isSNan_op1_i || isQNan_op1_i;
		logic isNan_op2 = isSNan_op2_i || isQNan_op2_i;

		logic isValidRes, isZeroRes, isInfRes, isNanRes, signRes;

		isValidRes	= (isZero_op1_i || isZero_op2_i || isInf_op1_i || isInf_op2_i || isNan_op1 || isNan_op2) ? 1 : 0;
		if (isNan_op1)
		begin //sign is not important, since a Nan remains a nan what-so-ever
			isZeroRes = 0; isInfRes = 0; isNanRes = 1; signRes = sign_op1_i;
		end
		else if (isNan_op2)
		begin
			isZeroRes = 0; isInfRes = 0; isNanRes = 1; signRes = sign_op2_i;
		end
		else // both are not NaN
		begin
			case({isZero_op1_i, isZero_op2_i, isInf_op1_i,isInf_op2_i})
				4'b00_00: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end
				4'b00_01: begin isNanRes = 0; isZeroRes = 0; isInfRes = 1; signRes = sign_op1_i ^ sign_op2_i; 	end
				4'b00_10: begin isNanRes = 0; isZeroRes = 0; isInfRes = 1; signRes = sign_op1_i ^ sign_op2_i; 	end
				4'b00_11: begin isNanRes = 0; isZeroRes = 0; isInfRes = 1; signRes = sign_op1_i ^ sign_op2_i; 	end
				4'b01_00: begin isNanRes = 0; isZeroRes = 1; isInfRes = 0; signRes = sign_op1_i ^ sign_op2_i; 	end	//TODO check sign of zero res
				4'b01_01: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end	//Impossible
				4'b01_10: begin isNanRes = 1; isZeroRes = 0; isInfRes = 0; signRes = 1; 						end	//TODO check sign of zero res
				4'b01_11: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end //Impossible
				4'b10_00: begin isNanRes = 0; isZeroRes = 1; isInfRes = 0; signRes = sign_op1_i ^ sign_op2_i; 	end
				4'b10_01: begin isNanRes = 1; isZeroRes = 0; isInfRes = 0; signRes = 1;						 	end
				4'b10_10: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end //Impossible
				4'b10_11: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end //Impossible
				4'b11_00: begin isNanRes = 0; isZeroRes = 1; isInfRes = 0; signRes = sign_op1_i ^ sign_op2_i; 	end
				4'b11_01: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end //Impossible
				4'b11_10: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end //Impossible
				4'b11_11: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end //Impossible
			endcase
		end
		return {isValidRes, isZeroRes, isInfRes, isNanRes, signRes};
	endfunction

	/*
	* 		Nan 	/ 			X		-> 		 Nan
	* 		X 		/ 			Nan 	-> (+/-) inf
	* (+/-)	inf		/ 			X 		-> (+/-) inf
	* 		X 		/ 	(+/-) 	inf 	-> (+/-) 0
	* (+/-) !0 		/ 	(+/-) 	0 		-> 		 inf
	* (+/-) 0 		/ 	(+/-) 	0 		-> 		 Nan
	* (+/-) inf 	/ 	(+/-) 	inf 	-> 		 Nan
	*/
	function automatic logic[4:0] FUNC_calcInfNanZeroResDiv (
				input isZero_op1_i, isInf_op1_i, input sign_op1_i, input isSNan_op1_i, input isQNan_op1_i,
				input isZero_op2_i, isInf_op2_i, input sign_op2_i, input isSNan_op2_i, input isQNan_op2_i
			);

		logic isNan_op1 = isSNan_op1_i || isQNan_op1_i;
		logic isNan_op2 = isSNan_op2_i || isQNan_op2_i;

		logic isValidRes, isZeroRes, isInfRes, isNanRes, signRes;

		isValidRes	= (isZero_op1_i || isZero_op2_i || isInf_op1_i || isInf_op2_i || isNan_op1 || isNan_op2) ? 1 : 0;
		if (isNan_op1)
		begin //sign is not important, since a Nan remains a nan what-so-ever
			isZeroRes = 0; isInfRes = 0; isNanRes = 1; signRes = sign_op1_i;
		end
		else if (isNan_op2)
		begin
			isZeroRes = 0; isInfRes = 0; isNanRes = 1; signRes = sign_op2_i;
		end
		else // both are not NaN
		begin
			case({isZero_op1_i, isZero_op2_i, isInf_op1_i,isInf_op2_i})
				4'b00_00: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end
				4'b00_01: begin isNanRes = 0; isZeroRes = 1; isInfRes = 0; signRes = sign_op1_i ^ sign_op2_i;	end	//	x	/ inf
				4'b00_10: begin isNanRes = 0; isZeroRes = 0; isInfRes = 1; signRes = sign_op1_i ^ sign_op2_i; 	end	//	inf	/ x
				4'b00_11: begin isNanRes = 1; isZeroRes = 0; isInfRes = 0; signRes = sign_op1_i ^ sign_op2_i; 	end	//	inf	/ inf
				4'b01_00: begin isNanRes = 0; isZeroRes = 0; isInfRes = 1; signRes = sign_op1_i ^ sign_op2_i; 	end	//	x	/ 0
				4'b01_01: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end	//	Impossible
				4'b01_10: begin isNanRes = 0; isZeroRes = 0; isInfRes = 1; signRes = sign_op1_i ^ sign_op2_i; 	end	//	inf	/ 0
				4'b01_11: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end //	Impossible
				4'b10_00: begin isNanRes = 0; isZeroRes = 1; isInfRes = 0; signRes = sign_op1_i ^ sign_op2_i; 	end	//	0	/ x
				4'b10_01: begin isNanRes = 0; isZeroRes = 1; isInfRes = 0; signRes = sign_op1_i ^ sign_op2_i; 	end	//	0	/ inf
				4'b10_10: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end //	Impossible
				4'b10_11: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end //	Impossible
				4'b11_00: begin isNanRes = 1; isZeroRes = 0; isInfRes = 0; signRes = sign_op1_i ^ sign_op2_i; 	end	//	0	/ 0
				4'b11_01: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end //	Impossible
				4'b11_10: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end //	Impossible
				4'b11_11: begin isNanRes = 0; isZeroRes = 0; isInfRes = 0; signRes = 0; 						end //	Impossible
			endcase
		end
		return {isValidRes, isZeroRes, isInfRes, isNanRes, signRes};
	endfunction

	function automatic logic[LAMP_APPROX_DW-1:0] FUNC_approxRecip(
		input [(1+LAMP_FLOAT_F_DW)-1:0] f_i
	);
		case(f_i[(1+LAMP_FLOAT_F_DW)-2-:LAMP_APPROX_DW])
			'b0000	:	return 'b1111;
			'b0001	:	return 'b1101;
			'b0010	:	return 'b1100;
			'b0011	:	return 'b1010;
			'b0100	:	return 'b1001;
			'b0101	:	return 'b1000;
			'b0110	:	return 'b0111;
			'b0111	:	return 'b0110;
			'b1000	:	return 'b0101;
			'b1001	:	return 'b0100;
			'b1010	:	return 'b0011;
			'b1011	:	return 'b0011;
			'b1100	:	return 'b0010;
			'b1101	:	return 'b0001;
			'b1110	:	return 'b0001;
			'b1111	:	return 'b0000;
		endcase
	endfunction

endpackage
