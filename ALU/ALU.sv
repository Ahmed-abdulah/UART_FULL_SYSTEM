module ALU 
  import alu_pkg::*;
#(
  parameter int OPER_WIDTH = 8,
  parameter int OUT_WIDTH  = OPER_WIDTH * 2
)(
  input  logic [OPER_WIDTH-1:0] A,
  input  logic [OPER_WIDTH-1:0] B,
  input  logic                  EN,
  input  alu_op_e               ALU_FUN,
  input  logic                  CLK,
  input  logic                  RST,
  output logic [OUT_WIDTH-1:0]  ALU_OUT,
  output logic                  OUT_VALID
);

  logic [OUT_WIDTH-1:0] ALU_OUT_Comb;
  logic                 OUT_VALID_Comb;
  
  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      ALU_OUT   <= '0;
      OUT_VALID <= '0;
    end
    else begin
      ALU_OUT   <= ALU_OUT_Comb;
      OUT_VALID <= OUT_VALID_Comb;
    end
  end
  
  always_comb begin
    OUT_VALID_Comb = '0;
    ALU_OUT_Comb   = '0;
    
    if (EN) begin
      OUT_VALID_Comb = '1;
      
      case (ALU_FUN)
        ADD:  ALU_OUT_Comb = A + B;
        SUB:  ALU_OUT_Comb = A - B;
        MUL:  ALU_OUT_Comb = A * B;
        DIV:  ALU_OUT_Comb = A / B;
        AND:  ALU_OUT_Comb = A & B;
        OR:   ALU_OUT_Comb = A | B;
        NAND: ALU_OUT_Comb = {8'b0 , ~(A & B)};
        NOR:  ALU_OUT_Comb = {8'b0 , ~(A | B)};
        XOR:  ALU_OUT_Comb = {8'b0 , A ^ B};
        XNOR: ALU_OUT_Comb = {8'b0 , ~(A ^ B)};
        EQ:   ALU_OUT_Comb = (A == B) ? 1'b1 :1'b0;
        GT:   ALU_OUT_Comb = (A > B)  ? 'd2 : '0;
        LT:   ALU_OUT_Comb = (A < B)  ? 'd3 : '0;
        SHR:  ALU_OUT_Comb = A >> 1;
        SHL:  ALU_OUT_Comb = A << 1;
        default: ALU_OUT_Comb = '0;
      endcase
    end
    else begin
      OUT_VALID_Comb = '0;
    end
  end

