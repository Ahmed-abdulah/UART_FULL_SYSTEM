vlib work

vlog -sv RegFile.sv
vlog -sv RegFile_tb.sv

vsim -voptargs=+acc work.RegFile_tb

add wave -position insertpoint sim:/RegFile_tb/*
add wave -position insertpoint -radix hex sim:/RegFile_tb/DUT/regArr



run -all

wave zoom full