module CLKDIV_MUX #(parameter int WIDTH = 8) (
  input  logic [5:0]       IN,
  output logic [WIDTH-1:0] OUT
);

  always_comb begin
    case(IN) 
      6'b100000: OUT = 'd1;
      6'b010000: OUT = 'd2;
      6'b001000: OUT = 'd4;
      6'b000100: OUT = 'd8;
      default:   OUT = 'd1;
    endcase
  end
  
endmodule