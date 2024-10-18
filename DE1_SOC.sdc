#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period 20.000ns [get_ports CLOCK2_50]
create_clock -period 20.000ns [get_ports CLOCK3_50]
create_clock -period 20.000ns [get_ports CLOCK4_50]
create_clock -period 20.000ns [get_ports CLOCK_50]

# VGA : 640x480@60Hz
#create_clock -period "25.18 MHz" -name clk_vga [get_ports VGA_CLK]
# VGA : 800x600@60Hz
#create_clock -period "40.0 MHz" -name clk_vga [get_ports VGA_CLK]
# VGA : 1024x768@60Hz
#create_clock -period "65.0 MHz" -name clk_vga [get_ports VGA_CLK]
# VGA : 1280x1024@60Hz
#create_clock -period "108.0 MHz" -name clk_vga [get_ports VGA_CLK]

# for enhancing USB BlasterII to be reliable, 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

#copied from DE1_SOC_D8M_LB_RTL.sdc
create_generated_clock -source [get_pins { u0|pll_sys|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk }] \
                      -name clk_vga_ext [get_ports {VGA_CLK}] -invert

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************

#copied from DE1_SOC_D8M_LB_RTL.sdc
# D8M						  
# tpd  min 1ns ,max 6ns
set_input_delay -max 6.1 -clock  MIPI_PIXEL_CLK_ext  [get_ports {MIPI_PIXEL_VS MIPI_PIXEL_HS MIPI_PIXEL_D[*]}]
set_input_delay -min 0.9 -clock  MIPI_PIXEL_CLK_ext  [get_ports {MIPI_PIXEL_VS MIPI_PIXEL_HS MIPI_PIXEL_D[*]}]


#**************************************************************
# Set Output Delay
#**************************************************************
# max : Board Delay (Data) - Board Delay (Clock) + tsu (External Device)
# min : Board Delay (Data) - Board Delay (Clock) - th (External Device)
#set_output_delay -max -clock clk_vga 0.220 [get_ports VGA_R*]
#set_output_delay -min -clock clk_vga -1.506 [get_ports VGA_R*]
#set_output_delay -max -clock clk_vga 0.212 [get_ports VGA_G*]
#set_output_delay -min -clock clk_vga -1.519 [get_ports VGA_G*]
#set_output_delay -max -clock clk_vga 0.264 [get_ports VGA_B*]
#set_output_delay -min -clock clk_vga -1.519 [get_ports VGA_B*]
#set_output_delay -max -clock clk_vga 0.215 [get_ports VGA_BLANK]
#set_output_delay -min -clock clk_vga -1.485 [get_ports VGA_BLANK]

#copied and modified from DE1_SOC_D8M_LB_RTL.sdc
# D8M						  
# tpd  min 1ns ,max 6ns
set_input_delay -max 6.1 -clock  aMIPI_PIXEL_CLK_ext  [get_ports {aMIPI_PIXEL_VS aMIPI_PIXEL_HS aMIPI_PIXEL_D[*]}]
set_input_delay -min 0.9 -clock  aMIPI_PIXEL_CLK_ext  [get_ports {aMIPI_PIXEL_VS aMIPI_PIXEL_HS aMIPI_PIXEL_D[*]}]
set_input_delay -max 6.1 -clock  bMIPI_PIXEL_CLK_ext  [get_ports {bMIPI_PIXEL_VS bMIPI_PIXEL_HS bMIPI_PIXEL_D[*]}]
set_input_delay -min 0.9 -clock  bMIPI_PIXEL_CLK_ext  [get_ports {bMIPI_PIXEL_VS bMIPI_PIXEL_HS bMIPI_PIXEL_D[*]}]



#**************************************************************
# Set Clock Groups
#**************************************************************

#copied from DE1_SOC_D8M_LB_RTL.sdc
set_clock_groups -asynchronous -group [get_clocks {u0|pll_sys|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] \
                               -group [get_clocks {MIPI_PIXEL_CLK}]

#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************



