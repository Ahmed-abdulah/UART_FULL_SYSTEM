module parity_clk #(
  parameter int DATA_WIDTH = 8
) (
  input  logic                   CLK,
  input  logic                   RST,
  input  logic                   parity_type, 
  input  logic                   sampled_bit,
  input  logic                   Enable,  
  input  logic [DATA_WIDTH-1:0]  P_DATA,
  output logic                   par_err
);

  logic parity;

  always_comb begin
    unique case (parity_type)
      1'b0: parity = ^P_DATA;
      1'b1: parity = ~^P_DATA;
    endcase
  end

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      par_err <= 1'b0;
    end
    else if (Enable) begin
      par_err <= parity ^ sampled_bit;
    end
  end

endmodule