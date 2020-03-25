/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
#include "svdpi.h"
#include <cstring>


#if (defined(_MSC_VER) || defined(__MINGW32__) || defined(__CYGWIN__))
#define DPI_DLLISPEC __declspec(dllimport)
#define DPI_DLLESPEC __declspec(dllexport)
#else
#define DPI_DLLISPEC
#define DPI_DLLESPEC
#endif


extern "C"
{
	DPI_DLLISPEC extern void  DPISetMode(int mode) ;
	DPI_DLLISPEC extern int   DPIGetMode() ; 
	DPI_DLLISPEC extern void  DPIAllocateExportedFunctions(int size) ;
	DPI_DLLISPEC extern void  DPIAddExportedFunction(int index, const char* value) ;
	DPI_DLLISPEC extern void  DPIAllocateSVCallerName(int index, const char* y) ;
	DPI_DLLISPEC extern void  DPISetCallerName(int index, const char* y) ;
	DPI_DLLISPEC extern void  DPISetCallerLine(int index, unsigned int y) ;
	DPI_DLLISPEC extern void  DPISetCallerOffset(int index, int y) ;
	DPI_DLLISPEC extern void  DPIAllocateDPIScopes(int size) ;
	DPI_DLLISPEC extern void  DPISetDPIScopeFunctionName(int index, const char* y) ;
	DPI_DLLISPEC extern void  DPISetDPIScopeHierarchy(int index, const char* y) ;
	DPI_DLLISPEC extern void  DPIRelocateDPIScopeIP(int index, char* IP) ;
	DPI_DLLISPEC extern void  DPIAddDPIScopeAccessibleFunction(int index, unsigned int y) ;
	DPI_DLLISPEC extern void  DPIFlushAll() ;
	DPI_DLLISPEC extern void  DPIVerifyScope() ;
	DPI_DLLISPEC extern char* DPISignalHandle(char* sigHandle, int length) ;
	DPI_DLLISPEC extern char* DPIMalloc(unsigned noOfBytes) ;
	DPI_DLLISPEC extern void  DPITransactionAuto(char* srcValue, unsigned int startIndex, unsigned int endIndex, char* net) ;
	DPI_DLLISPEC extern void  DPIScheduleTransactionBlocking(char* var, char* driver, char* src, unsigned setback, unsigned lenMinusOnne) ;
	DPI_DLLISPEC extern void  DPIMemsetSvToDpi(char* dst, char* src, int numCBytes, int is2state) ;
	DPI_DLLISPEC extern void  DPIMemsetDpiToSv(char* dst, char* src, int numCBytes, int is2state) ;
	DPI_DLLISPEC extern void  DPIMemsetSvLogic1ToDpi(char* dst, char* src) ;
	DPI_DLLISPEC extern void  DPIMemsetDpiToSvLogic1(char* dst, char* src) ;
	DPI_DLLISPEC extern void  DPIMemsetDpiToSvUnpackedLogic(char* dst, char* src, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetDpiToSvUnpackedLogicWithPackedDim(char* dst, char* src, int pckedSz, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetSvToDpiUnpackedLogic(char* dst, char* src, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetSvToDpiUnpackedLogicWithPackedDim(char* dst, char* src, int pckdSz, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetDpiToSvUnpackedBit(char* dst, char* src, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetDpiToSvUnpackedBitWithPackedDim(char* dst, char* src, int pckdSz, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetSvToDpiUnpackedBit(char* dst, char* src, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetSvToDpiUnpackedBitWithPackedDim(char* dst, char* src, int pckdSz, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPISetFuncName(const char* funcName) ;
	DPI_DLLISPEC extern int   staticScopeCheck(const char* calledFunction) ;
	DPI_DLLISPEC extern void  DPIAllocateSVCallerInfo(int size) ;
	DPI_DLLISPEC extern void* DPICreateContext(int scopeId, char* IP, int callerIdx);
	DPI_DLLISPEC extern void* DPIGetCurrentContext();
	DPI_DLLISPEC extern void  DPISetCurrentContext(void*);
	DPI_DLLISPEC extern void  DPIRemoveContext(void*);
	DPI_DLLISPEC extern int   svGetScopeStaticId();
	DPI_DLLISPEC extern char* svGetScopeIP();
	DPI_DLLISPEC extern unsigned DPIGetUnpackedSizeFromSVOpenArray(svOpenArray*);
	DPI_DLLISPEC extern unsigned DPIGetConstraintSizeFromSVOpenArray(svOpenArray*, int);
	DPI_DLLISPEC extern int   topOffset() ;
	DPI_DLLISPEC extern char* DPIInitializeFunction(char* p, unsigned size, long long offset) ;
	DPI_DLLISPEC extern void  DPIInvokeFunction(char* processPtr, char* SP, void* func, char* IP) ;
	DPI_DLLISPEC extern void  DPIDeleteFunctionInvocation(char* SP) ;
	DPI_DLLISPEC extern void  DPISetTaskScopeId(int scopeId) ;
	DPI_DLLISPEC extern void  DPISetTaskCaller(int index) ;
	DPI_DLLISPEC extern int   DPIGetTaskCaller() ;
	DPI_DLLISPEC extern char* DPIInitializeTask(long long subprogInDPOffset, char* scopePropInIP, unsigned size, char* parentBlock) ;
	DPI_DLLISPEC extern void  DPIInvokeTask(long long subprogInDPOffset, char* SP, void* func, char* IP) ;
	DPI_DLLISPEC extern void  DPIDeleteTaskInvocation(char* SP) ;
	DPI_DLLISPEC extern void* DPICreateTaskContext(int (*wrapper)(char*, char*, char*), char* DP, char* IP, char* SP, size_t stackSz) ;
	DPI_DLLISPEC extern void  DPIRemoveTaskContext(void*) ;
	DPI_DLLISPEC extern void  DPICallCurrentContext() ;
	DPI_DLLISPEC extern void  DPIYieldCurrentContext() ;
	DPI_DLLISPEC extern void* DPIGetCurrentTaskContext() ;
	DPI_DLLISPEC extern int   DPIRunningInNewContext() ;
	DPI_DLLISPEC extern void  DPISetCurrentTaskContext(void* x) ;
}

namespace XILINX_DPI { 

	void dpiInitialize()
	{
		DPIAllocateSVCallerInfo(10) ;
		DPISetCallerName(0, "C:/Users/liuna/FSQRT_BFLOAT16/bfloat_sqrt_0.1/bfloat_sqrt_0.1.srcs/sim_1/new/tb_lampFPU.sv") ;
		DPISetCallerLine(0, 303) ;
		DPISetCallerOffset(0, 0) ;
		DPISetCallerName(1, "C:/Users/liuna/FSQRT_BFLOAT16/bfloat_sqrt_0.1/bfloat_sqrt_0.1.srcs/sim_1/new/tb_lampFPU.sv") ;
		DPISetCallerLine(1, 304) ;
		DPISetCallerOffset(1, 0) ;
		DPISetCallerName(2, "C:/Users/liuna/FSQRT_BFLOAT16/bfloat_sqrt_0.1/bfloat_sqrt_0.1.srcs/sim_1/new/tb_lampFPU.sv") ;
		DPISetCallerLine(2, 305) ;
		DPISetCallerOffset(2, 0) ;
		DPISetCallerName(3, "C:/Users/liuna/FSQRT_BFLOAT16/bfloat_sqrt_0.1/bfloat_sqrt_0.1.srcs/sim_1/new/tb_lampFPU.sv") ;
		DPISetCallerLine(3, 306) ;
		DPISetCallerOffset(3, 0) ;
		DPISetCallerName(4, "C:/Users/liuna/FSQRT_BFLOAT16/bfloat_sqrt_0.1/bfloat_sqrt_0.1.srcs/sim_1/new/tb_lampFPU.sv") ;
		DPISetCallerLine(4, 340) ;
		DPISetCallerOffset(4, 0) ;
		DPISetCallerName(5, "C:/Users/liuna/FSQRT_BFLOAT16/bfloat_sqrt_0.1/bfloat_sqrt_0.1.srcs/sim_1/new/tb_lampFPU.sv") ;
		DPISetCallerLine(5, 371) ;
		DPISetCallerOffset(5, 0) ;
		DPISetCallerName(6, "C:/Users/liuna/FSQRT_BFLOAT16/bfloat_sqrt_0.1/bfloat_sqrt_0.1.srcs/sim_1/new/tb_lampFPU.sv") ;
		DPISetCallerLine(6, 400) ;
		DPISetCallerOffset(6, 0) ;
		DPISetCallerName(7, "C:/Users/liuna/FSQRT_BFLOAT16/bfloat_sqrt_0.1/bfloat_sqrt_0.1.srcs/sim_1/new/tb_lampFPU.sv") ;
		DPISetCallerLine(7, 428) ;
		DPISetCallerOffset(7, 0) ;
		DPISetCallerName(8, "C:/Users/liuna/FSQRT_BFLOAT16/bfloat_sqrt_0.1/bfloat_sqrt_0.1.srcs/sim_1/new/tb_lampFPU.sv") ;
		DPISetCallerLine(8, 429) ;
		DPISetCallerOffset(8, 0) ;
		DPISetCallerName(9, "C:/Users/liuna/FSQRT_BFLOAT16/bfloat_sqrt_0.1/bfloat_sqrt_0.1.srcs/sim_1/new/tb_lampFPU.sv") ;
		DPISetCallerLine(9, 430) ;
		DPISetCallerOffset(9, 0) ;
		DPIAllocateDPIScopes(10) ;
		DPISetDPIScopeFunctionName(0, "DPI_fadd") ;
		DPISetDPIScopeHierarchy(0, "tb_lampFPU") ;
		DPIRelocateDPIScopeIP(0, (char*)(0x1fda8)) ;
		DPISetDPIScopeFunctionName(1, "DPI_fsub") ;
		DPISetDPIScopeHierarchy(1, "tb_lampFPU") ;
		DPIRelocateDPIScopeIP(1, (char*)(0x1fda8)) ;
		DPISetDPIScopeFunctionName(2, "DPI_fmul") ;
		DPISetDPIScopeHierarchy(2, "tb_lampFPU") ;
		DPIRelocateDPIScopeIP(2, (char*)(0x1fda8)) ;
		DPISetDPIScopeFunctionName(3, "DPI_fdiv") ;
		DPISetDPIScopeHierarchy(3, "tb_lampFPU") ;
		DPIRelocateDPIScopeIP(3, (char*)(0x1fda8)) ;
		DPISetDPIScopeFunctionName(4, "DPI_feq") ;
		DPISetDPIScopeHierarchy(4, "tb_lampFPU") ;
		DPIRelocateDPIScopeIP(4, (char*)(0x1fda8)) ;
		DPISetDPIScopeFunctionName(5, "DPI_flt") ;
		DPISetDPIScopeHierarchy(5, "tb_lampFPU") ;
		DPIRelocateDPIScopeIP(5, (char*)(0x1fda8)) ;
		DPISetDPIScopeFunctionName(6, "DPI_fle") ;
		DPISetDPIScopeHierarchy(6, "tb_lampFPU") ;
		DPIRelocateDPIScopeIP(6, (char*)(0x1fda8)) ;
		DPISetDPIScopeFunctionName(7, "DPI_i2f") ;
		DPISetDPIScopeHierarchy(7, "tb_lampFPU") ;
		DPIRelocateDPIScopeIP(7, (char*)(0x1fda8)) ;
		DPISetDPIScopeFunctionName(8, "DPI_f2i") ;
		DPISetDPIScopeHierarchy(8, "tb_lampFPU") ;
		DPIRelocateDPIScopeIP(8, (char*)(0x1fda8)) ;
		DPISetDPIScopeFunctionName(9, "DPI_fsqrt") ;
		DPISetDPIScopeHierarchy(9, "tb_lampFPU") ;
		DPIRelocateDPIScopeIP(9, (char*)(0x1fda8)) ;
	}

}


extern "C" {
	void iki_initialize_dpi()
	{ XILINX_DPI::dpiInitialize() ; } 
}


extern "C" {

	extern unsigned int DPI_fadd(unsigned int arg0, unsigned int arg1) ;
	extern unsigned int DPI_fsub(unsigned int arg0, unsigned int arg1) ;
	extern unsigned int DPI_fmul(unsigned int arg0, unsigned int arg1) ;
	extern unsigned int DPI_fdiv(unsigned int arg0, unsigned int arg1) ;
	extern unsigned int DPI_feq(unsigned int arg0, unsigned int arg1) ;
	extern unsigned int DPI_flt(unsigned int arg0, unsigned int arg1) ;
	extern unsigned int DPI_fle(unsigned int arg0, unsigned int arg1) ;
	extern unsigned int DPI_i2f(unsigned int arg0) ;
	extern unsigned int DPI_f2i(unsigned int arg0) ;
	extern unsigned int DPI_fsqrt(unsigned int arg0, int arg1) ;
}


extern "C" {
	unsigned int Dpi_wrapper_DPI_fadd(char *GlobalDP, char *IP, char *SP)
	{
DPISetMode(1) ; // Function chain mode : with or without context 

		    /******* Preserve Context Info *******/ 
		char *ptrToSP  = SP; 
		ptrToSP = ptrToSP + 160; 
		int scopeIdx = *((int*)ptrToSP);
		ptrToSP = (char*)((int*)ptrToSP + 1); 
		int callerIdx = *((int*)ptrToSP);
		void* funcContext = DPICreateContext(scopeIdx, IP, callerIdx);
		(*((void**)(SP + 160))) = funcContext;
		DPISetCurrentContext(*(void**)(SP + 160));
		ptrToSP = (char*)((int*)ptrToSP + 1); 

		    /******* Convert SV types to DPI-C Types *******/ 

		    /******* Create and populate DPI-C types for the arguments *******/ 

		ptrToSP = SP + 480 ; 
		unsigned int cObj0;
		DPIMemsetSvToDpi( (char*)(&cObj0), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		ptrToSP = SP + 648 ; 
		unsigned int cObj1;
		DPIMemsetSvToDpi( (char*)(&cObj1), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		    /******* Done Conversion of SV types to DPI-C Types *******/ 
		    /******* Call the DPI-C function *******/ 
		DPISetFuncName("DPI_fadd");
		DPIFlushAll();
		unsigned int result = 0 ;
		result = DPI_fadd(cObj0, cObj1);

		    /******* Write result value into the SP *******/ 
		ptrToSP = SP + 312 ; 
		DPIRemoveContext(funcContext);
		DPIFlushAll();
		DPISetFuncName(0);
		*((int*)ptrToSP) = result; 
		*((int*)ptrToSP+1) = 0; 
		/****** Subprogram Debug : Pop the Call Stack entry for this function invocation  ******/
		iki_vlog_function_callstack_update(SP); 
		return result ;
	}
	unsigned int Dpi_wrapper_DPI_fsub(char *GlobalDP, char *IP, char *SP)
	{
DPISetMode(1) ; // Function chain mode : with or without context 

		    /******* Preserve Context Info *******/ 
		char *ptrToSP  = SP; 
		ptrToSP = ptrToSP + 160; 
		int scopeIdx = *((int*)ptrToSP);
		ptrToSP = (char*)((int*)ptrToSP + 1); 
		int callerIdx = *((int*)ptrToSP);
		void* funcContext = DPICreateContext(scopeIdx, IP, callerIdx);
		(*((void**)(SP + 160))) = funcContext;
		DPISetCurrentContext(*(void**)(SP + 160));
		ptrToSP = (char*)((int*)ptrToSP + 1); 

		    /******* Convert SV types to DPI-C Types *******/ 

		    /******* Create and populate DPI-C types for the arguments *******/ 

		ptrToSP = SP + 480 ; 
		unsigned int cObj0;
		DPIMemsetSvToDpi( (char*)(&cObj0), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		ptrToSP = SP + 648 ; 
		unsigned int cObj1;
		DPIMemsetSvToDpi( (char*)(&cObj1), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		    /******* Done Conversion of SV types to DPI-C Types *******/ 
		    /******* Call the DPI-C function *******/ 
		DPISetFuncName("DPI_fsub");
		DPIFlushAll();
		unsigned int result = 0 ;
		result = DPI_fsub(cObj0, cObj1);

		    /******* Write result value into the SP *******/ 
		ptrToSP = SP + 312 ; 
		DPIRemoveContext(funcContext);
		DPIFlushAll();
		DPISetFuncName(0);
		*((int*)ptrToSP) = result; 
		*((int*)ptrToSP+1) = 0; 
		/****** Subprogram Debug : Pop the Call Stack entry for this function invocation  ******/
		iki_vlog_function_callstack_update(SP); 
		return result ;
	}
	unsigned int Dpi_wrapper_DPI_fmul(char *GlobalDP, char *IP, char *SP)
	{
DPISetMode(1) ; // Function chain mode : with or without context 

		    /******* Preserve Context Info *******/ 
		char *ptrToSP  = SP; 
		ptrToSP = ptrToSP + 160; 
		int scopeIdx = *((int*)ptrToSP);
		ptrToSP = (char*)((int*)ptrToSP + 1); 
		int callerIdx = *((int*)ptrToSP);
		void* funcContext = DPICreateContext(scopeIdx, IP, callerIdx);
		(*((void**)(SP + 160))) = funcContext;
		DPISetCurrentContext(*(void**)(SP + 160));
		ptrToSP = (char*)((int*)ptrToSP + 1); 

		    /******* Convert SV types to DPI-C Types *******/ 

		    /******* Create and populate DPI-C types for the arguments *******/ 

		ptrToSP = SP + 480 ; 
		unsigned int cObj0;
		DPIMemsetSvToDpi( (char*)(&cObj0), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		ptrToSP = SP + 648 ; 
		unsigned int cObj1;
		DPIMemsetSvToDpi( (char*)(&cObj1), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		    /******* Done Conversion of SV types to DPI-C Types *******/ 
		    /******* Call the DPI-C function *******/ 
		DPISetFuncName("DPI_fmul");
		DPIFlushAll();
		unsigned int result = 0 ;
		result = DPI_fmul(cObj0, cObj1);

		    /******* Write result value into the SP *******/ 
		ptrToSP = SP + 312 ; 
		DPIRemoveContext(funcContext);
		DPIFlushAll();
		DPISetFuncName(0);
		*((int*)ptrToSP) = result; 
		*((int*)ptrToSP+1) = 0; 
		/****** Subprogram Debug : Pop the Call Stack entry for this function invocation  ******/
		iki_vlog_function_callstack_update(SP); 
		return result ;
	}
	unsigned int Dpi_wrapper_DPI_fdiv(char *GlobalDP, char *IP, char *SP)
	{
DPISetMode(1) ; // Function chain mode : with or without context 

		    /******* Preserve Context Info *******/ 
		char *ptrToSP  = SP; 
		ptrToSP = ptrToSP + 160; 
		int scopeIdx = *((int*)ptrToSP);
		ptrToSP = (char*)((int*)ptrToSP + 1); 
		int callerIdx = *((int*)ptrToSP);
		void* funcContext = DPICreateContext(scopeIdx, IP, callerIdx);
		(*((void**)(SP + 160))) = funcContext;
		DPISetCurrentContext(*(void**)(SP + 160));
		ptrToSP = (char*)((int*)ptrToSP + 1); 

		    /******* Convert SV types to DPI-C Types *******/ 

		    /******* Create and populate DPI-C types for the arguments *******/ 

		ptrToSP = SP + 480 ; 
		unsigned int cObj0;
		DPIMemsetSvToDpi( (char*)(&cObj0), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		ptrToSP = SP + 648 ; 
		unsigned int cObj1;
		DPIMemsetSvToDpi( (char*)(&cObj1), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		    /******* Done Conversion of SV types to DPI-C Types *******/ 
		    /******* Call the DPI-C function *******/ 
		DPISetFuncName("DPI_fdiv");
		DPIFlushAll();
		unsigned int result = 0 ;
		result = DPI_fdiv(cObj0, cObj1);

		    /******* Write result value into the SP *******/ 
		ptrToSP = SP + 312 ; 
		DPIRemoveContext(funcContext);
		DPIFlushAll();
		DPISetFuncName(0);
		*((int*)ptrToSP) = result; 
		*((int*)ptrToSP+1) = 0; 
		/****** Subprogram Debug : Pop the Call Stack entry for this function invocation  ******/
		iki_vlog_function_callstack_update(SP); 
		return result ;
	}
	unsigned int Dpi_wrapper_DPI_feq(char *GlobalDP, char *IP, char *SP)
	{
DPISetMode(1) ; // Function chain mode : with or without context 

		    /******* Preserve Context Info *******/ 
		char *ptrToSP  = SP; 
		ptrToSP = ptrToSP + 160; 
		int scopeIdx = *((int*)ptrToSP);
		ptrToSP = (char*)((int*)ptrToSP + 1); 
		int callerIdx = *((int*)ptrToSP);
		void* funcContext = DPICreateContext(scopeIdx, IP, callerIdx);
		(*((void**)(SP + 160))) = funcContext;
		DPISetCurrentContext(*(void**)(SP + 160));
		ptrToSP = (char*)((int*)ptrToSP + 1); 

		    /******* Convert SV types to DPI-C Types *******/ 

		    /******* Create and populate DPI-C types for the arguments *******/ 

		ptrToSP = SP + 480 ; 
		unsigned int cObj0;
		DPIMemsetSvToDpi( (char*)(&cObj0), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		ptrToSP = SP + 648 ; 
		unsigned int cObj1;
		DPIMemsetSvToDpi( (char*)(&cObj1), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		    /******* Done Conversion of SV types to DPI-C Types *******/ 
		    /******* Call the DPI-C function *******/ 
		DPISetFuncName("DPI_feq");
		DPIFlushAll();
		unsigned int result = 0 ;
		result = DPI_feq(cObj0, cObj1);

		    /******* Write result value into the SP *******/ 
		ptrToSP = SP + 312 ; 
		DPIRemoveContext(funcContext);
		DPIFlushAll();
		DPISetFuncName(0);
		*((int*)ptrToSP) = result; 
		*((int*)ptrToSP+1) = 0; 
		/****** Subprogram Debug : Pop the Call Stack entry for this function invocation  ******/
		iki_vlog_function_callstack_update(SP); 
		return result ;
	}
	unsigned int Dpi_wrapper_DPI_flt(char *GlobalDP, char *IP, char *SP)
	{
DPISetMode(1) ; // Function chain mode : with or without context 

		    /******* Preserve Context Info *******/ 
		char *ptrToSP  = SP; 
		ptrToSP = ptrToSP + 160; 
		int scopeIdx = *((int*)ptrToSP);
		ptrToSP = (char*)((int*)ptrToSP + 1); 
		int callerIdx = *((int*)ptrToSP);
		void* funcContext = DPICreateContext(scopeIdx, IP, callerIdx);
		(*((void**)(SP + 160))) = funcContext;
		DPISetCurrentContext(*(void**)(SP + 160));
		ptrToSP = (char*)((int*)ptrToSP + 1); 

		    /******* Convert SV types to DPI-C Types *******/ 

		    /******* Create and populate DPI-C types for the arguments *******/ 

		ptrToSP = SP + 480 ; 
		unsigned int cObj0;
		DPIMemsetSvToDpi( (char*)(&cObj0), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		ptrToSP = SP + 648 ; 
		unsigned int cObj1;
		DPIMemsetSvToDpi( (char*)(&cObj1), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		    /******* Done Conversion of SV types to DPI-C Types *******/ 
		    /******* Call the DPI-C function *******/ 
		DPISetFuncName("DPI_flt");
		DPIFlushAll();
		unsigned int result = 0 ;
		result = DPI_flt(cObj0, cObj1);

		    /******* Write result value into the SP *******/ 
		ptrToSP = SP + 312 ; 
		DPIRemoveContext(funcContext);
		DPIFlushAll();
		DPISetFuncName(0);
		*((int*)ptrToSP) = result; 
		*((int*)ptrToSP+1) = 0; 
		/****** Subprogram Debug : Pop the Call Stack entry for this function invocation  ******/
		iki_vlog_function_callstack_update(SP); 
		return result ;
	}
	unsigned int Dpi_wrapper_DPI_fle(char *GlobalDP, char *IP, char *SP)
	{
DPISetMode(1) ; // Function chain mode : with or without context 

		    /******* Preserve Context Info *******/ 
		char *ptrToSP  = SP; 
		ptrToSP = ptrToSP + 160; 
		int scopeIdx = *((int*)ptrToSP);
		ptrToSP = (char*)((int*)ptrToSP + 1); 
		int callerIdx = *((int*)ptrToSP);
		void* funcContext = DPICreateContext(scopeIdx, IP, callerIdx);
		(*((void**)(SP + 160))) = funcContext;
		DPISetCurrentContext(*(void**)(SP + 160));
		ptrToSP = (char*)((int*)ptrToSP + 1); 

		    /******* Convert SV types to DPI-C Types *******/ 

		    /******* Create and populate DPI-C types for the arguments *******/ 

		ptrToSP = SP + 480 ; 
		unsigned int cObj0;
		DPIMemsetSvToDpi( (char*)(&cObj0), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		ptrToSP = SP + 648 ; 
		unsigned int cObj1;
		DPIMemsetSvToDpi( (char*)(&cObj1), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		    /******* Done Conversion of SV types to DPI-C Types *******/ 
		    /******* Call the DPI-C function *******/ 
		DPISetFuncName("DPI_fle");
		DPIFlushAll();
		unsigned int result = 0 ;
		result = DPI_fle(cObj0, cObj1);

		    /******* Write result value into the SP *******/ 
		ptrToSP = SP + 312 ; 
		DPIRemoveContext(funcContext);
		DPIFlushAll();
		DPISetFuncName(0);
		*((int*)ptrToSP) = result; 
		*((int*)ptrToSP+1) = 0; 
		/****** Subprogram Debug : Pop the Call Stack entry for this function invocation  ******/
		iki_vlog_function_callstack_update(SP); 
		return result ;
	}
	unsigned int Dpi_wrapper_DPI_i2f(char *GlobalDP, char *IP, char *SP)
	{
DPISetMode(1) ; // Function chain mode : with or without context 

		    /******* Preserve Context Info *******/ 
		char *ptrToSP  = SP; 
		ptrToSP = ptrToSP + 160; 
		int scopeIdx = *((int*)ptrToSP);
		ptrToSP = (char*)((int*)ptrToSP + 1); 
		int callerIdx = *((int*)ptrToSP);
		void* funcContext = DPICreateContext(scopeIdx, IP, callerIdx);
		(*((void**)(SP + 160))) = funcContext;
		DPISetCurrentContext(*(void**)(SP + 160));
		ptrToSP = (char*)((int*)ptrToSP + 1); 

		    /******* Convert SV types to DPI-C Types *******/ 

		    /******* Create and populate DPI-C types for the arguments *******/ 

		ptrToSP = SP + 480 ; 
		unsigned int cObj0;
		DPIMemsetSvToDpi( (char*)(&cObj0), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		    /******* Done Conversion of SV types to DPI-C Types *******/ 
		    /******* Call the DPI-C function *******/ 
		DPISetFuncName("DPI_i2f");
		DPIFlushAll();
		unsigned int result = 0 ;
		result = DPI_i2f(cObj0);

		    /******* Write result value into the SP *******/ 
		ptrToSP = SP + 312 ; 
		DPIRemoveContext(funcContext);
		DPIFlushAll();
		DPISetFuncName(0);
		*((int*)ptrToSP) = result; 
		*((int*)ptrToSP+1) = 0; 
		/****** Subprogram Debug : Pop the Call Stack entry for this function invocation  ******/
		iki_vlog_function_callstack_update(SP); 
		return result ;
	}
	unsigned int Dpi_wrapper_DPI_f2i(char *GlobalDP, char *IP, char *SP)
	{
DPISetMode(1) ; // Function chain mode : with or without context 

		    /******* Preserve Context Info *******/ 
		char *ptrToSP  = SP; 
		ptrToSP = ptrToSP + 160; 
		int scopeIdx = *((int*)ptrToSP);
		ptrToSP = (char*)((int*)ptrToSP + 1); 
		int callerIdx = *((int*)ptrToSP);
		void* funcContext = DPICreateContext(scopeIdx, IP, callerIdx);
		(*((void**)(SP + 160))) = funcContext;
		DPISetCurrentContext(*(void**)(SP + 160));
		ptrToSP = (char*)((int*)ptrToSP + 1); 

		    /******* Convert SV types to DPI-C Types *******/ 

		    /******* Create and populate DPI-C types for the arguments *******/ 

		ptrToSP = SP + 480 ; 
		unsigned int cObj0;
		DPIMemsetSvToDpi( (char*)(&cObj0), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		    /******* Done Conversion of SV types to DPI-C Types *******/ 
		    /******* Call the DPI-C function *******/ 
		DPISetFuncName("DPI_f2i");
		DPIFlushAll();
		unsigned int result = 0 ;
		result = DPI_f2i(cObj0);

		    /******* Write result value into the SP *******/ 
		ptrToSP = SP + 312 ; 
		DPIRemoveContext(funcContext);
		DPIFlushAll();
		DPISetFuncName(0);
		*((int*)ptrToSP) = result; 
		*((int*)ptrToSP+1) = 0; 
		/****** Subprogram Debug : Pop the Call Stack entry for this function invocation  ******/
		iki_vlog_function_callstack_update(SP); 
		return result ;
	}
	unsigned int Dpi_wrapper_DPI_fsqrt(char *GlobalDP, char *IP, char *SP)
	{
DPISetMode(1) ; // Function chain mode : with or without context 

		    /******* Preserve Context Info *******/ 
		char *ptrToSP  = SP; 
		ptrToSP = ptrToSP + 160; 
		int scopeIdx = *((int*)ptrToSP);
		ptrToSP = (char*)((int*)ptrToSP + 1); 
		int callerIdx = *((int*)ptrToSP);
		void* funcContext = DPICreateContext(scopeIdx, IP, callerIdx);
		(*((void**)(SP + 160))) = funcContext;
		DPISetCurrentContext(*(void**)(SP + 160));
		ptrToSP = (char*)((int*)ptrToSP + 1); 

		    /******* Convert SV types to DPI-C Types *******/ 

		    /******* Create and populate DPI-C types for the arguments *******/ 

		ptrToSP = SP + 480 ; 
		unsigned int cObj0;
		DPIMemsetSvToDpi( (char*)(&cObj0), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		ptrToSP = SP + 648 ; 
		int cObj1;
		DPIMemsetSvToDpi( (char*)(&cObj1), ptrToSP, 4, 1 );
		ptrToSP = ptrToSP + 8; 

		    /******* Done Conversion of SV types to DPI-C Types *******/ 
		    /******* Call the DPI-C function *******/ 
		DPISetFuncName("DPI_fsqrt");
		DPIFlushAll();
		unsigned int result = 0 ;
		result = DPI_fsqrt(cObj0, cObj1);

		    /******* Write result value into the SP *******/ 
		ptrToSP = SP + 312 ; 
		DPIRemoveContext(funcContext);
		DPIFlushAll();
		DPISetFuncName(0);
		*((int*)ptrToSP) = result; 
		*((int*)ptrToSP+1) = 0; 
		/****** Subprogram Debug : Pop the Call Stack entry for this function invocation  ******/
		iki_vlog_function_callstack_update(SP); 
		return result ;
	}
}


extern "C" {
}

