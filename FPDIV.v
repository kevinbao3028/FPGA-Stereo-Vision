// megafunction wizard: %ALTFP_DIV%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: altfp_div 

// ============================================================
// File Name: FPDIV.v
// Megafunction Name(s):
// 			altfp_div
//
// Simulation Library Files(s):
// 			
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 20.1.1 Build 720 11/11/2020 SJ Standard Edition
// ************************************************************


//Copyright (C) 2020  Intel Corporation. All rights reserved.
//Your use of Intel Corporation's design tools, logic functions 
//and other software and tools, and any partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Intel Program License 
//Subscription Agreement, the Intel Quartus Prime License Agreement,
//the Intel FPGA IP License Agreement, or other applicable license
//agreement, including, without limitation, that your use is for
//the sole purpose of programming logic devices manufactured by
//Intel and sold by Intel or its authorized distributors.  Please
//refer to the applicable agreement for further details, at
//https://fpgasoftware.intel.com/eula.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module FPDIV (
	clock,
	dataa,
	datab,
	result);

	input	  clock;
	input	[31:0]  dataa;
	input	[31:0]  datab;
	output	[31:0]  result;

	wire [31:0] sub_wire0;
	wire [31:0] result = sub_wire0[31:0];

	altfp_div	altfp_div_component (
				.clock (clock),
				.dataa (dataa),
				.datab (datab),
				.result (sub_wire0));
	defparam
		altfp_div_component.denormal_support = "NO",
		altfp_div_component.optimize = "AREA",
		altfp_div_component.pipeline = 14,
		altfp_div_component.reduced_functionality = "NO",
		altfp_div_component.width_exp = 8,
		altfp_div_component.width_man = 23;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone V"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "1"
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: CONSTANT: DENORMAL_SUPPORT STRING "NO"
// Retrieval info: CONSTANT: OPTIMIZE STRING "AREA"
// Retrieval info: CONSTANT: PIPELINE NUMERIC "14"
// Retrieval info: CONSTANT: REDUCED_FUNCTIONALITY STRING "NO"
// Retrieval info: CONSTANT: WIDTH_EXP NUMERIC "8"
// Retrieval info: CONSTANT: WIDTH_MAN NUMERIC "23"
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL "clock"
// Retrieval info: USED_PORT: dataa 0 0 32 0 INPUT NODEFVAL "dataa[31..0]"
// Retrieval info: USED_PORT: datab 0 0 32 0 INPUT NODEFVAL "datab[31..0]"
// Retrieval info: USED_PORT: result 0 0 32 0 OUTPUT NODEFVAL "result[31..0]"
// Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: @dataa 0 0 32 0 dataa 0 0 32 0
// Retrieval info: CONNECT: @datab 0 0 32 0 datab 0 0 32 0
// Retrieval info: CONNECT: result 0 0 32 0 @result 0 0 32 0
// Retrieval info: GEN_FILE: TYPE_NORMAL FPDIV.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL FPDIV.inc TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL FPDIV.cmp TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL FPDIV.bsf TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL FPDIV_inst.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL FPDIV_bb.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL FPDIV_syn.v TRUE
