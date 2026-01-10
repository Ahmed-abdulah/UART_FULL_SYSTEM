module ALU_tb 
  import alu_pkg::*;
();

  parameter OPER_WIDTH = 8;
  parameter OUT_WIDTH  = OPER_WIDTH * 2;
  parameter CLK_PERIOD = 10;
  
  logic [OPER_WIDTH-1:0] A;
  logic [OPER_WIDTH-1:0] B;
  logic                  EN;
  alu_op_e               ALU_FUN;
  logic                  CLK;
  logic                  RST;
  logic [OUT_WIDTH-1:0]  ALU_OUT;
  logic                  OUT_VALID;
  
  int passed = 0;
  int failed = 0;
  
  ALU #(
    .OPER_WIDTH(OPER_WIDTH),
    .OUT_WIDTH(OUT_WIDTH)
  ) DUT (
    .A(A),
    .B(B),
    .EN(EN),
    .ALU_FUN(ALU_FUN),
    .CLK(CLK),
    .RST(RST),
    .ALU_OUT(ALU_OUT),
    .OUT_VALID(OUT_VALID)
  );
  
  initial begin
    CLK = 0;
    forever #(CLK_PERIOD/2) CLK = ~CLK;
  end
  
  initial begin
    RST     = 1;
    EN      = 0;
    A       = 0;
    B       = 0;
    ALU_FUN = ADD;
    
    #5;
    RST = 0;
    #(CLK_PERIOD*2);
    RST = 1;
    #(CLK_PERIOD);
    
    $display("========================================");
    $display("    ALU Verification Test");
    $display("========================================\n");
    
    $display("=== Test 1: Arithmetic Operations ===");
    test_operation(8'h0A, 8'h05, ADD, 16'h000F, "Addition");
    test_operation(8'h0A, 8'h05, SUB, 16'h0005, "Subtraction");
    test_operation(8'h0A, 8'h05, MUL, 16'h0032, "Multiplication");
    test_operation(8'h0A, 8'h05, DIV, 16'h0002, "Division");
    
    $display("\n=== Test 2: Logical Operations ===");
    test_operation(8'hAA, 8'h55, AND,  16'h0000, "AND");
    test_operation(8'hAA, 8'h55, OR,   16'h00FF, "OR");
    test_operation(8'hFF, 8'hFF, NAND, 16'h0000, "NAND");
    test_operation(8'h00, 8'h00, NOR,  16'h00FF, "NOR");
    test_operation(8'hAA, 8'h55, XOR,  16'h00FF, "XOR");
    test_operation(8'hAA, 8'hAA, XNOR, 16'h00FF, "XNOR");
    
    $display("\n=== Test 3: Comparison Operations ===");
    test_operation(8'h0A, 8'h0A, EQ, 16'h0001, "Equal (A==B)");
    test_operation(8'h0A, 8'h05, EQ, 16'h0000, "Equal (A!=B)");
    test_operation(8'h0A, 8'h05, GT, 16'h0002, "Greater (A>B)");
    test_operation(8'h05, 8'h0A, GT, 16'h0000, "Greater (A<B)");
    test_operation(8'h05, 8'h0A, LT, 16'h0003, "Less (A<B)");
    test_operation(8'h0A, 8'h05, LT, 16'h0000, "Less (A>B)");
    
    $display("\n=== Test 4: Shift Operations ===");
    test_operation(8'hAA, 8'h00, SHR, 16'h0055, "Shift Right");
    test_operation(8'h55, 8'h00, SHL, 16'h00AA, "Shift Left");
    
    $display("\n=== Test 5: Enable Control ===");
    test_disabled(8'h0A, 8'h05, ADD);
    
    $display("\n=== Test 6: Edge Cases ===");
    test_operation(8'hFF, 8'h01, ADD, 16'h0100, "Overflow Addition");
    test_operation(8'h00, 8'h01, SUB, 16'hFFFF, "Underflow Subtraction");
    test_operation(8'hFF, 8'hFF, MUL, 16'hFE01, "Max Multiplication");
    
    $display("\n========================================");
    $display("         Test Summary");
    $display("========================================");
    $display("Passed: %0d", passed);
    $display("Failed: %0d", failed);
    $display("Total:  %0d", passed + failed);
    $display("========================================\n");
    
    #(CLK_PERIOD*5);
    $stop;
  end
  
  task test_operation(
    input [OPER_WIDTH-1:0] in_a,
    input [OPER_WIDTH-1:0] in_b,
    input alu_op_e         fun,
    input [OUT_WIDTH-1:0]  expected,
    input string           op_name
  );
    @(negedge CLK);
    A       = in_a;
    B       = in_b;
    ALU_FUN = fun;
    EN      = 1;
    
    @(posedge CLK);
    #1;
    
    if (OUT_VALID && ALU_OUT == expected) begin
      $display("[PASS] %s: A=0x%0h, B=0x%0h, Result=0x%0h", 
               op_name, in_a, in_b, ALU_OUT);
      passed++;
    end
    else begin
      $display("[FAIL] %s: A=0x%0h, B=0x%0h, Expected=0x%0h, Got=0x%0h, Valid=%0b",
               op_name, in_a, in_b, expected, ALU_OUT, OUT_VALID);
      failed++;
    end
    
    @(negedge CLK);
    EN = 0;
  endtask
  
  task test_disabled(
    input [OPER_WIDTH-1:0] in_a,
    input [OPER_WIDTH-1:0] in_b,
    input alu_op_e         fun
  );
    @(negedge CLK);
    A       = in_a;
    B       = in_b;
    ALU_FUN = fun;
    EN      = 0;
    
    @(posedge CLK);
    #1;
    
    if (!OUT_VALID) begin
      $display("[PASS] Disabled: OUT_VALID=0 when EN=0");
      passed++;
    end
    else begin
      $display("[FAIL] Disabled: OUT_VALID=%0b when EN=0 (should be 0)", OUT_VALID);
      failed++;
    end
  endtask

endmodule