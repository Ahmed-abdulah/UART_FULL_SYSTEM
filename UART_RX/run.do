vlib work

vlog -sv *.sv

vsim -voptargs=+acc UART_RX_TB

run -all 