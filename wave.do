onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/i
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/x
add wave -noupdate /testbench/y
add wave -noupdate /testbench/ix
add wave -noupdate /testbench/iy
add wave -noupdate /testbench/rectifier/div_ax/clken
add wave -noupdate /testbench/rectifier/div_ax/clock
add wave -noupdate /testbench/rectifier/div_ax/denom
add wave -noupdate /testbench/rectifier/div_ax/numer
add wave -noupdate /testbench/rectifier/div_ax/quotient
add wave -noupdate /testbench/rectifier/div_ax/remain
add wave -noupdate /testbench/rectifier/div_ax/sub_wire0
add wave -noupdate /testbench/rectifier/div_ax/sub_wire1
add wave -noupdate /testbench/rectifier/y_want_a
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 253
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {881 ps}
