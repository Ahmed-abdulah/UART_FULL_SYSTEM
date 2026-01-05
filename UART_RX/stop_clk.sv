module stop_clk (
  input  logic  CLK,
  input  logic  RST,
  input  logic  sampled_bit,
  input  logic  Enable, 
  output logic  stp_err
);

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      stp_err <= 1'b0;
    end
    else if (Enable) begin
      stp_err <= 1'b1 ^ sampled_bit;
    end
  end

endmodule