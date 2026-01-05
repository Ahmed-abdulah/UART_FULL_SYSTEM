module start_clk (
  input  logic  CLK,
  input  logic  RST,
  input  logic  sampled_bit,
  input  logic  Enable, 
  output logic  strt_glitch
);

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      strt_glitch <= 1'b0;
    end
    else if (Enable) begin
      strt_glitch <= sampled_bit;
    end
  end

endmodule 