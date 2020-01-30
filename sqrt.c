#include "C:\Xilinx\Vivado\2018.2\data\xsim\include\svdpi.h"
#include <stdio.h>
#include <math.h>


#define FLOAT_E_DW 8
#define FLOAT_F_DW 7

unsigned int DPI_fsqrt(unsigned int op){

    float f_op = *((float*) &op);
    double partial_res = sqrt(f_op);
    float res = (*(float *) &partial_res);

    return *((unsigned int*) &res);

}


