module data_sampling (
  input  logic        CLK,
  input  logic        RST,
  input  logic        S_DATA,
  input  logic [5:0]  Prescale,
  input  logic [5:0]  edge_count,
  input  logic        Enable, 
  output logic        sampled_bit
);

  logic [2:0] Samples;
  logic [4:0] half_edges, half_edges_p1, half_edges_n1;

  assign half_edges    = (Prescale >> 1) - 5'd1;
  assign half_edges_p1 = half_edges + 5'd1;
  assign half_edges_n1 = half_edges - 5'd1;

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      Samples <= '0;
    end
    else begin
      if (Enable) begin
        if (edge_count == half_edges_n1) begin
          Samples[0] <= S_DATA;
        end
        else if (edge_count == half_edges) begin
          Samples[1] <= S_DATA;
        end
        else if (edge_count == half_edges_p1) begin
          Samples[2] <= S_DATA;
        end
      end
      else begin
        Samples <= '0;
      end
    end
  end

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      sampled_bit <= 1'b0;
    end
    else begin
      if (Enable) begin
        unique case (Samples)
          3'b000: sampled_bit <= 1'b0;
          3'b001: sampled_bit <= 1'b0;
          3'b010: sampled_bit <= 1'b0;
          3'b011: sampled_bit <= 1'b1;
          3'b100: sampled_bit <= 1'b0;
          3'b101: sampled_bit <= 1'b1;
          3'b110: sampled_bit <= 1'b1;
          3'b111: sampled_bit <= 1'b1;
        endcase
      end
      else begin
        sampled_bit <= 1'b0;
      end
    end
  end

endmodule 