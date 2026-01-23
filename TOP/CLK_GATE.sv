module CLK_GATE (
  input  logic CLK_EN,
  input  logic CLK,
  output logic GATED_CLK
);

  logic latch_en;

  always_latch begin
    if (!CLK)
      latch_en = CLK_EN;
  end

  assign GATED_CLK = CLK & latch_en;

endmodule