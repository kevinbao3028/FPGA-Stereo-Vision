transcript on
if ![file isdirectory DE1_SOC_iputf_libs] {
	file mkdir DE1_SOC_iputf_libs
}

if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/altera_ver
vmap altera_ver ./verilog_libs/altera_ver
vlog -vlog01compat -work altera_ver {d:/intelfpga/20.1/quartus/eda/sim_lib/altera_primitives.v}

vlib verilog_libs/lpm_ver
vmap lpm_ver ./verilog_libs/lpm_ver
vlog -vlog01compat -work lpm_ver {d:/intelfpga/20.1/quartus/eda/sim_lib/220model.v}

vlib verilog_libs/sgate_ver
vmap sgate_ver ./verilog_libs/sgate_ver
vlog -vlog01compat -work sgate_ver {d:/intelfpga/20.1/quartus/eda/sim_lib/sgate.v}

vlib verilog_libs/altera_mf_ver
vmap altera_mf_ver ./verilog_libs/altera_mf_ver
vlog -vlog01compat -work altera_mf_ver {d:/intelfpga/20.1/quartus/eda/sim_lib/altera_mf.v}

vlib verilog_libs/altera_lnsim_ver
vmap altera_lnsim_ver ./verilog_libs/altera_lnsim_ver
vlog -sv -work altera_lnsim_ver {d:/intelfpga/20.1/quartus/eda/sim_lib/altera_lnsim.sv}

vlib verilog_libs/cyclonev_ver
vmap cyclonev_ver ./verilog_libs/cyclonev_ver
vlog -vlog01compat -work cyclonev_ver {d:/intelfpga/20.1/quartus/eda/sim_lib/mentor/cyclonev_atoms_ncrypt.v}
vlog -vlog01compat -work cyclonev_ver {d:/intelfpga/20.1/quartus/eda/sim_lib/mentor/cyclonev_hmi_atoms_ncrypt.v}
vlog -vlog01compat -work cyclonev_ver {d:/intelfpga/20.1/quartus/eda/sim_lib/cyclonev_atoms.v}

vlib verilog_libs/cyclonev_hssi_ver
vmap cyclonev_hssi_ver ./verilog_libs/cyclonev_hssi_ver
vlog -vlog01compat -work cyclonev_hssi_ver {d:/intelfpga/20.1/quartus/eda/sim_lib/mentor/cyclonev_hssi_atoms_ncrypt.v}
vlog -vlog01compat -work cyclonev_hssi_ver {d:/intelfpga/20.1/quartus/eda/sim_lib/cyclonev_hssi_atoms.v}

vlib verilog_libs/cyclonev_pcie_hip_ver
vmap cyclonev_pcie_hip_ver ./verilog_libs/cyclonev_pcie_hip_ver
vlog -vlog01compat -work cyclonev_pcie_hip_ver {d:/intelfpga/20.1/quartus/eda/sim_lib/mentor/cyclonev_pcie_hip_atoms_ncrypt.v}
vlog -vlog01compat -work cyclonev_pcie_hip_ver {d:/intelfpga/20.1/quartus/eda/sim_lib/cyclonev_pcie_hip_atoms.v}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

###### Libraries for IPUTF cores 
###### End libraries for IPUTF cores 
###### MIF file copy and HDL compilation commands for IPUTF cores 


vlog "C:/Users/deval/Desktop/181dualcam/FPMUL_sim/FPMUL.vo"

vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/linebuffer.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/MIPI_BRIDGE_CAMERA_Config.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/MIPI_CAMERA_CONFIG.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/I2C_RESET_DELAY.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/CLOCKMEM.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/I2C_READ_DATA.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/I2C_WRITE_PTR.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/I2C_WRITE_WDATA.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/MIPI_BRIDGE_CONFIG.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/RAWDATA_TO_RGB.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/LINEBUFFER_RD.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/RECTIFY.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/INTDIV.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/RECTBUFFER.v}
vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/de1_soc.v}
vlib video_pll2
vmap video_pll2 video_pll2
vlog -vlog01compat -work video_pll2 +incdir+C:/Users/deval/Desktop/181dualcam/video_pll2/synthesis {C:/Users/deval/Desktop/181dualcam/video_pll2/synthesis/video_pll2.v}
vlog -vlog01compat -work video_pll2 +incdir+C:/Users/deval/Desktop/181dualcam/video_pll2/synthesis/submodules {C:/Users/deval/Desktop/181dualcam/video_pll2/synthesis/submodules/video_pll2_video_pll_0.v}
vlog -vlog01compat -work video_pll2 +incdir+C:/Users/deval/Desktop/181dualcam/video_pll2/synthesis/submodules {C:/Users/deval/Desktop/181dualcam/video_pll2/synthesis/submodules/altera_up_avalon_reset_from_locked_signal.v}
vlog -vlog01compat -work video_pll2 +incdir+C:/Users/deval/Desktop/181dualcam/video_pll2/synthesis/submodules {C:/Users/deval/Desktop/181dualcam/video_pll2/synthesis/submodules/video_pll2_video_pll_0_video_pll.v}

vlog -vlog01compat -work work +incdir+C:/Users/deval/Desktop/181dualcam {C:/Users/deval/Desktop/181dualcam/testbench.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -L video_pll2 -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
