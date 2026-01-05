module edge_bit_counter (
  input  logic       CLK,
  input  logic       RST,
  input  logic       Enable,
  input  logic [5:0] Prescale, 
  output logic [3:0] bit_count,
  output logic [5:0] edge_count
);

  logic edge_count_done;

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      edge_count <= '0;
    end
    else if (Enable) begin
      if (edge_count_done) begin
        edge_count <= '0;
      end
      else begin
        edge_count <= edge_count + 6'd1;
      end
    end
    else begin
      edge_count <= '0;
    end
  end

  assign edge_count_done = (edge_count == (Prescale - 6'd1));

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      bit_count <= '0;
    end
    else if (Enable) begin
      if (edge_count_done) begin
        bit_count <= bit_count + 4'd1;
      end
    end
    else begin
      bit_count <= '0;
    end
  end

endmodule