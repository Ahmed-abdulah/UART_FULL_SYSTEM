module SYS_TOP #(
  parameter int DATA_WIDTH = 8,
  parameter int RF_ADDR = 4
)(
  input  logic RST_N,
  input  logic UART_CLK,
  input  logic REF_CLK,
  input  logic UART_RX_IN,
  output logic UART_TX_O,
  output logic parity_error,
  output logic framing_error
);

  logic                      SYNC_UART_RST;
  logic                      SYNC_REF_RST;
  logic                      UART_TX_CLK;
  logic                      UART_RX_CLK;
  logic [DATA_WIDTH-1:0]     Operand_A;
  logic [DATA_WIDTH-1:0]     Operand_B;
  logic [DATA_WIDTH-1:0]     UART_Config;
  logic [DATA_WIDTH-1:0]     DIV_RATIO;
  logic [DATA_WIDTH-1:0]     DIV_RATIO_RX;
  logic [DATA_WIDTH-1:0]     UART_RX_OUT;
  logic                      UART_RX_V_OUT;
  logic [DATA_WIDTH-1:0]     UART_RX_SYNC;
  logic                      UART_RX_V_SYNC;
  logic [DATA_WIDTH-1:0]     UART_TX_IN;
  logic                      UART_TX_VLD;
  logic [DATA_WIDTH-1:0]     UART_TX_SYNC;
  logic                      UART_TX_V_SYNC;
  logic                      UART_TX_Busy;
  logic                      UART_TX_Busy_PULSE;
  logic                      RF_WrEn;
  logic                      RF_RdEn;
  logic [RF_ADDR-1:0]        RF_Address;
  logic [DATA_WIDTH-1:0]     RF_WrData;
  logic [DATA_WIDTH-1:0]     RF_RdData;
  logic                      RF_RdData_VLD;
  logic                      CLKG_EN;
  logic                      ALU_EN;
  logic [3:0]                ALU_FUN;
  logic [DATA_WIDTH*2-1:0]   ALU_OUT;
  logic                      ALU_OUT_VLD;
  logic                      ALU_CLK;
  logic                      FIFO_FULL;
  logic                      CLKDIV_EN;

  RST_SYNC #(.NUM_STAGES(2)) UART_RST_SYNC (
    .RST(RST_N),
    .CLK(UART_CLK),
    .SYNC_RST(SYNC_UART_RST)
  );

  RST_SYNC #(.NUM_STAGES(2)) REF_RST_SYNC (
    .RST(RST_N),
    .CLK(REF_CLK),
    .SYNC_RST(SYNC_REF_RST)
  );

  DATA_SYNC #(.NUM_STAGES(2), .BUS_WIDTH(8)) RX_DATA_SYNC (
    .CLK(REF_CLK),
    .RST(SYNC_REF_RST),
    .unsync_bus(UART_RX_OUT),
    .bus_enable(UART_RX_V_OUT),
    .sync_bus(UART_RX_SYNC),
    .enable_pulse_d(UART_RX_V_SYNC)
  );

  Async_fifo #(.D_SIZE(DATA_WIDTH), .P_SIZE(4), .F_DEPTH(8)) TX_FIFO (
    .i_w_clk(REF_CLK),
    .i_w_rstn(SYNC_REF_RST),
    .i_w_inc(UART_TX_VLD),
    .i_w_data(UART_TX_IN),
    .i_r_clk(UART_TX_CLK),
    .i_r_rstn(SYNC_UART_RST),
    .i_r_inc(UART_TX_Busy_PULSE),
    .o_r_data(UART_TX_SYNC),
    .o_full(FIFO_FULL),
    .o_empty(UART_TX_V_SYNC)
  );

  PULSE_GEN TX_BUSY_PULSE (
    .clk(UART_TX_CLK),
    .rst(SYNC_UART_RST),
    .lvl_sig(UART_TX_Busy),
    .pulse_sig(UART_TX_Busy_PULSE)
  );

  ClkDiv TX_CLK_DIV (
    .i_ref_clk(UART_CLK),
    .i_rst(SYNC_UART_RST),
    .i_clk_en(CLKDIV_EN),
    .i_div_ratio(DIV_RATIO),
    .o_div_clk(UART_TX_CLK)
  );

  CLKDIV_MUX RX_DIV_MUX (
    .IN(UART_Config[7:2]),
    .OUT(DIV_RATIO_RX)
  );

  ClkDiv RX_CLK_DIV (
    .i_ref_clk(UART_CLK),
    .i_rst(SYNC_UART_RST),
    .i_clk_en(CLKDIV_EN),
    .i_div_ratio(DIV_RATIO_RX),
    .o_div_clk(UART_RX_CLK)
  );

  UART U0_UART (
    .RST(SYNC_UART_RST),
    .TX_CLK(UART_TX_CLK),
    .RX_CLK(UART_RX_CLK),
    .parity_enable(UART_Config[0]),
    .parity_type(UART_Config[1]),
    .Prescale(UART_Config[7:2]),
    .RX_IN_S(UART_RX_IN),
    .RX_OUT_P(UART_RX_OUT),
    .RX_OUT_V(UART_RX_V_OUT),
    .TX_IN_P(UART_TX_SYNC),
    .TX_IN_V(!UART_TX_V_SYNC),
    .TX_OUT_S(UART_TX_O),
    .TX_OUT_V(UART_TX_Busy),
    .parity_error(parity_error),
    .framing_error(framing_error)
  );

  SYS_CTRL U0_SYS_CTRL (
    .CLK(REF_CLK),
    .RST(SYNC_REF_RST),
    .RF_RdData(RF_RdData),
    .RF_RdData_VLD(RF_RdData_VLD),
    .RF_WrEn(RF_WrEn),
    .RF_RdEn(RF_RdEn),
    .RF_Address(RF_Address),
    .RF_WrData(RF_WrData),
    .ALU_EN(ALU_EN),
    .ALU_FUN(ALU_FUN),
    .ALU_OUT(ALU_OUT),
    .ALU_OUT_VLD(ALU_OUT_VLD),
    .CLKG_EN(CLKG_EN),
    .CLKDIV_EN(CLKDIV_EN),
    .FIFO_FULL(FIFO_FULL),
    .UART_RX_DATA(UART_RX_SYNC),
    .UART_RX_VLD(UART_RX_V_SYNC),
    .UART_TX_DATA(UART_TX_IN),
    .UART_TX_VLD(UART_TX_VLD)
  );

  RegFile U0_RegFile (
    .CLK(REF_CLK),
    .RST(SYNC_REF_RST),
    .WrEn(RF_WrEn),
    .RdEn(RF_RdEn),
    .Address(RF_Address),
    .WrData(RF_WrData),
    .RdData(RF_RdData),
    .RdData_Valid(RF_RdData_VLD),
    .REG0(Operand_A),
    .REG1(Operand_B),
    .REG2(UART_Config),
    .REG3(DIV_RATIO)
  );

  ALU U0_ALU (
    .CLK(ALU_CLK),
    .RST(SYNC_REF_RST),
    .A(Operand_A),
    .B(Operand_B),
    .EN(ALU_EN),
    .ALU_FUN(ALU_FUN),
    .ALU_OUT(ALU_OUT),
    .OUT_VALID(ALU_OUT_VLD)
  );

  CLK_GATE U0_CLK_GATE (
    .CLK_EN(CLKG_EN),
    .CLK(REF_CLK),
    .GATED_CLK(ALU_CLK)
  );

endmodule