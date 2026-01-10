module RegFile_tb;

  // Parameters
  parameter WIDTH = 8;
  parameter DEPTH = 16;
  parameter ADDR  = 4;
  parameter CLK_PERIOD = 10;
  
  // Testbench signals
  logic                 CLK;
  logic                 RST;
  logic                 WrEn;
  logic                 RdEn;
  logic [ADDR-1:0]      Address;
  logic [WIDTH-1:0]     WrData;
  logic [WIDTH-1:0]     RdData;
  logic                 RdData_Valid;
  logic [WIDTH-1:0]     REG0, REG1, REG2, REG3;
  
  // DUT instantiation
  RegFile #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH),
    .ADDR(ADDR)
  ) DUT (
    .CLK(CLK),
    .RST(RST),
    .WrEn(WrEn),
    .RdEn(RdEn),
    .Address(Address),
    .WrData(WrData),
    .RdData(RdData),
    .RdData_Valid(RdData_Valid),
    .REG0(REG0),
    .REG1(REG1),
    .REG2(REG2),
    .REG3(REG3)
  );
  
  // Clock generation
  initial begin
    CLK = 0;
    forever #(CLK_PERIOD/2) CLK = ~CLK;
  end
  
  // Test stimulus
  initial begin
    // Initialize signals
    RST     = 1;
    WrEn    = 0;
    RdEn    = 0;
    Address = 0;
    WrData  = 0;
    
    // Apply reset
    #5;
    RST = 0;
    #(CLK_PERIOD*2);
    RST = 1;
    #(CLK_PERIOD);
    
    $display("=== Test 1: Check Reset Values ===");
    read_register(2);
    read_register(3);
    read_register(0);
    
    $display("\n=== Test 2: Write Operations ===");
    write_register(0, 8'hAA);
    write_register(1, 8'h55);
    write_register(4, 8'hFF);
    
    $display("\n=== Test 3: Read Operations ===");
    read_register(0);
    read_register(1);
    read_register(4);
    
    $display("\n=== Test 4: Overwrite Registers ===");
    write_register(2, 8'h12);
    write_register(3, 8'h34);
    read_register(2);
    read_register(3);
    
    $display("\n=== Test 5: Check REG0-REG3 Outputs ===");
    #(CLK_PERIOD);
    $display("REG0 = 0x%0h, REG1 = 0x%0h, REG2 = 0x%0h, REG3 = 0x%0h", 
             REG0, REG1, REG2, REG3);
    
    $display("\n=== All Tests Complete ===");
    #(CLK_PERIOD*5);
    $stop;
  end
  
  // Task: Write to register
  task write_register(input [ADDR-1:0] addr, input [WIDTH-1:0] data);
    @(negedge CLK);
    Address = addr;
    WrData  = data;
    WrEn    = 1;
    RdEn    = 0;
    @(negedge CLK);
    WrEn    = 0;
    $display("Write: Addr=0x%0h, Data=0x%0h", addr, data);
  endtask
  
  // Task: Read from register
  task read_register(input [ADDR-1:0] addr);
    @(negedge CLK);
    Address = addr;
    WrEn    = 0;
    RdEn    = 1;
    @(posedge CLK);
    #1;
    if (RdData_Valid)
      $display("Read:  Addr=0x%0h, Data=0x%0h (Valid)", addr, RdData);
    else
      $display("Read:  Addr=0x%0h, Data=Invalid", addr);
    @(negedge CLK);
    RdEn = 0;
  endtask

endmodule