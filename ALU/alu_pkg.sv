package alu_pkg;

  typedef enum logic [3:0] {
    ADD    = 4'b0000,
    SUB    = 4'b0001,
    MUL    = 4'b0010,
    DIV    = 4'b0011,
    AND    = 4'b0100,
    OR     = 4'b0101,
    NAND   = 4'b0110,
    NOR    = 4'b0111,
    XOR    = 4'b1000,
    XNOR   = 4'b1001,
    EQ     = 4'b1010,
    GT     = 4'b1011,
    LT     = 4'b1100,
    SHR    = 4'b1101,
    SHL    = 4'b1110
  } alu_op_e;

endpackage