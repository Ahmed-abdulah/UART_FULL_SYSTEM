# Debug compilation script
vlib work
vmap work work

vlog -sv ../ALU/alu_pkg.sv
vlog -sv ../UART_RX/UART_rx_pkg.sv


vlog -sv ../ALU/ALU.sv
vlog -sv ../CLK_DIV/clk_div.sv
vlog -sv ../CLK_DIV/mux_div.sv
vlog -sv ../RegFile/RegFile.sv


vlog -sv ../SYNC/Data_SYNC.sv
vlog -sv ../SYNC/PULSE_GEN.sv
vlog -sv ../TOP/rst_sync.sv


vlog -sv ../FIFO/async_FIFO.sv


vlog -sv ../TOP/CLK_GATE.sv
vlog -sv ../TOP/MUX.sv

vlog -sv ../UART_RX/data_sampling.sv
vlog -sv ../UART_RX/deserializer.sv
vlog -sv ../UART_RX/edge_bit_counter.sv
vlog -sv ../UART_RX/parity_clk.sv
vlog -sv ../UART_RX/start_clk.sv
vlog -sv ../UART_RX/stop_clk.sv
vlog -sv ../UART_RX/uart_rx_fsm.sv
vlog -sv ../UART_RX/UART_RX.sv


vlog -sv ../UART_TX/mux.sv
echo "=== Compiling UART TX - parity_calc ==="
vlog -sv ../UART_TX/parity_calc.sv
echo "=== Compiling UART TX - serializer ==="
vlog -sv ../UART_TX/serializer.sv
echo "=== Compiling UART TX - tx_fsm ==="
vlog -sv ../UART_TX/tx_fsm.sv
echo "=== Compiling UART TX - UART_TX ==="
vlog -sv ../UART_TX/UART_TX.sv


vlog -sv ../Control/System_Control.sv

vlog -sv ../UART_TOP/UART.sv

vlog -sv ../TOP/SYSTEM_TOP.sv



vlog SYS_TOP_TB.sv

# Start simulation
echo "=== Starting Simulation ==="
vsim -c SYS_TOP_TBBBB

# Run simulation
echo "=== Running Test ==="
run -all

# Exit
quit