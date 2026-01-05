module deserializer #(
  parameter int DATA_WIDTH = 8
) (
  input  logic                    CLK,
  input  logic                    RST,
  input  logic                    sampled_bit,
  input  logic                    Enable, 
  input  logic [5:0]              edge_count, 
  input  logic [5:0]              Prescale, 
  output logic [DATA_WIDTH-1:0]   P_DATA
);

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      P_DATA <= '0;
    end
    else if (Enable && edge_count == (Prescale - 6'd1)) begin
      P_DATA <= {sampled_bit, P_DATA[DATA_WIDTH-1:1]};
    end
  end

endmodule 