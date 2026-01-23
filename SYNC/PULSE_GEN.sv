module PULSE_GEN (
  input  logic clk,
  input  logic rst,
  input  logic lvl_sig,
  output logic pulse_sig
);

  logic rcv_flop;
  logic pls_flop;

  always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
      rcv_flop <= 1'b0;
      pls_flop <= 1'b0;
    end else begin
      rcv_flop <= lvl_sig;
      pls_flop <= rcv_flop;
    end
  end

  assign pulse_sig = rcv_flop && !pls_flop;

endmodule