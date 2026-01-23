module tb;

  parameter int WIDTH = 8;
  parameter int ADDR = 4;

  logic                CLK;
  logic                RST;
  logic [WIDTH-1:0]    RF_RdData;
  logic                RF_RdData_VLD;
  logic [WIDTH*2-1:0]  ALU_OUT;
  logic                ALU_OUT_VLD;
  logic [WIDTH-1:0]    UART_RX_DATA;
  logic                UART_RX_VLD;
  logic                FIFO_FULL;
  logic                ALU_EN;
  logic [3:0]          ALU_FUN;
  logic                CLKG_EN;
  logic                CLKDIV_EN;
  logic                RF_WrEn;
  logic                RF_RdEn;
  logic [ADDR-1:0]     RF_Address;
  logic [WIDTH-1:0]    RF_WrData;
  logic [WIDTH-1:0]    UART_TX_DATA;
  logic                UART_TX_VLD;

  SYS_CTRL #(
    .WIDTH(WIDTH),
    .ADDR(ADDR)
  ) dut (.*);

  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
  end

  task send_uart_byte(input logic [7:0] data);
    @(posedge CLK);
    UART_RX_DATA = data;
    UART_RX_VLD = 1'b1;
    @(posedge CLK);
    UART_RX_VLD = 1'b0;
  endtask

  task wait_cycles(input int n);
    repeat(n) @(posedge CLK);
  endtask

  initial begin
    RST = 0;
    RF_RdData = 0;
    RF_RdData_VLD = 0;
    ALU_OUT = 0;
    ALU_OUT_VLD = 0;
    UART_RX_DATA = 0;
    UART_RX_VLD = 0;
    FIFO_FULL = 0;

    repeat(3) @(posedge CLK);
    RST = 1;
    repeat(2) @(posedge CLK);

    $display("\n=== TEST 1: RF WRITE COMMAND ===");
    send_uart_byte(8'hAA);
    $display("Time=%0t Sent RF_WRITE_CMD", $time);
    
    send_uart_byte(8'h05);
    $display("Time=%0t Sent Address=0x05", $time);
    
    send_uart_byte(8'hA3);
    $display("Time=%0t Sent Data=0xA3", $time);
    if (RF_WrEn) $display("  RF Write: Addr=%h Data=%h", RF_Address, RF_WrData);
    
    wait_cycles(2);

    $display("\n=== TEST 2: RF READ COMMAND ===");
    send_uart_byte(8'hBB);
    $display("Time=%0t Sent RF_READ_CMD", $time);
    
    send_uart_byte(8'h05);
    $display("Time=%0t Sent Address=0x05", $time);
    if (RF_RdEn) $display("  RF Read: Addr=%h", RF_Address);
    
    @(posedge CLK);
    RF_RdData = 8'hA3;
    RF_RdData_VLD = 1'b1;
    @(posedge CLK);
    RF_RdData_VLD = 1'b0;
    if (UART_TX_VLD) $display("  UART TX: Data=%h", UART_TX_DATA);
    
    wait_cycles(2);

    $display("\n=== TEST 3: ALU WITH OPERANDS ===");
    send_uart_byte(8'hCC);
    $display("Time=%0t Sent ALU_W_OP_CMD", $time);
    
    send_uart_byte(8'h0A);
    $display("Time=%0t Sent OperandA=0x0A", $time);
    if (RF_WrEn) $display("  Write to RF[0]: Data=%h", RF_WrData);
    
    send_uart_byte(8'h05);
    $display("Time=%0t Sent OperandB=0x05", $time);
    if (RF_WrEn) $display("  Write to RF[1]: Data=%h", RF_WrData);
    
    send_uart_byte(8'h00);
    $display("Time=%0t Sent ALU_FUN=0x0 (ADD)", $time);
    if (ALU_EN) $display("  ALU Enabled: FUN=%h", ALU_FUN);
    
    @(posedge CLK);
    ALU_OUT = 16'h000F;
    ALU_OUT_VLD = 1'b1;
    @(posedge CLK);
    ALU_OUT_VLD = 1'b0;
    
    wait_cycles(1);
    if (UART_TX_VLD) $display("  UART TX Byte1=%h", UART_TX_DATA);
    
    @(posedge CLK);
    if (UART_TX_VLD) $display("  UART TX Byte2=%h", UART_TX_DATA);
    
    wait_cycles(2);

    $display("\n=== TEST 4: ALU WITHOUT OPERANDS ===");
    send_uart_byte(8'hDD);
    $display("Time=%0t Sent ALU_WN_OP_CMD", $time);
    
    send_uart_byte(8'h01);
    $display("Time=%0t Sent ALU_FUN=0x1 (SUB)", $time);
    if (ALU_EN) $display("  ALU Enabled: FUN=%h", ALU_FUN);
    
    @(posedge CLK);
    ALU_OUT = 16'h0005;
    ALU_OUT_VLD = 1'b1;
    @(posedge CLK);
    ALU_OUT_VLD = 1'b0;
    
    wait_cycles(1);
    if (UART_TX_VLD) $display("  UART TX Byte1=%h", UART_TX_DATA);
    
    @(posedge CLK);
    if (UART_TX_VLD) $display("  UART TX Byte2=%h", UART_TX_DATA);
    
    wait_cycles(5);

    $display("\n=== TEST COMPLETED ===");
    $finish;
  end

  initial begin
    $dumpfile("sys_ctrl.vcd");
    $dumpvars(0, tb);
  end

endmodule