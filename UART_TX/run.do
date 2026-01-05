vlib work
vlog -sv *.sv
vsim -voptargs=+acc work.UART_TX_TB
add wave *
run -all
