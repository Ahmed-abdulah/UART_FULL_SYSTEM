module mux2X1 (
  input  logic IN_0,
  input  logic IN_1,
  input  logic SEL,
  output logic OUT
);

  assign OUT = SEL ? IN_1 : IN_0;

endmodule