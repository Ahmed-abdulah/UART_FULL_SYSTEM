module RST_SYNC #(
  parameter int NUM_STAGES = 2
)(
  input  logic RST,
  input  logic CLK,
  output logic SYNC_RST
);

  logic [NUM_STAGES-1:0] sync_reg;

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      sync_reg <= '0;
    end else begin
      sync_reg <= {sync_reg[NUM_STAGES-2:0], 1'b1};
    end
  end

  assign SYNC_RST = sync_reg[NUM_STAGES-1];

endmodule