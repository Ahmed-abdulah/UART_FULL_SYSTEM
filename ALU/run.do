vlib work

vlog -sv alu_pkg.sv
vlog -sv ALU.sv
vlog -sv ALU_tb.sv

vsim -voptargs=+acc work.ALU_tb

run -all
