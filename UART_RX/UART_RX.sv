module UART_RX #(
  parameter int DATA_WIDTH = 8
) (
  input  logic                    CLK,
  input  logic                    RST,
  input  logic                    RX_IN,
  input  logic                    parity_enable,
  input  logic                    parity_type,
  input  logic [5:0]              Prescale, 
  output logic [DATA_WIDTH-1:0]   P_DATA, 
  output logic                    data_valid,
  output logic                    parity_error,
  output logic                    framing_error
);

  logic [3:0] bit_count;
  logic [5:0] edge_count;
  logic       edge_bit_en;
  logic       deser_en;
  logic       parity_chk_en;
  logic       stop_chk_en;
  logic       start_chk_en;
  logic       strt_glitch;
  logic       sampled_bit;
  logic       dat_samp_en;

  uart_rx_fsm #(
    .DATA_WIDTH(DATA_WIDTH)
  ) U0_uart_fsm (
    .CLK(CLK),
    .RST(RST),
    .S_DATA(RX_IN),
    .Prescale(Prescale),
    .bit_count(bit_count),
    .parity_enable(parity_enable),
    .edge_count(edge_count), 
    .strt_glitch(strt_glitch),
    .par_err(parity_error),
    .stp_err(framing_error), 
    .start_chk_en(start_chk_en),
    .edge_bit_en(edge_bit_en), 
    .deser_en(deser_en), 
    .parity_chk_en(parity_chk_en), 
    .stop_chk_en(stop_chk_en),
    .dat_samp_en(dat_samp_en),
    .data_valid(data_valid)
  );

  edge_bit_counter U0_edge_bit_counter (
    .CLK(CLK),
    .RST(RST),
    .Prescale(Prescale),
    .Enable(edge_bit_en),
    .bit_count(bit_count),
    .edge_count(edge_count) 
  );

  data_sampling U0_data_sampling (
    .CLK(CLK),
    .RST(RST),
    .S_DATA(RX_IN),
    .Prescale(Prescale),
    .Enable(dat_samp_en),
    .edge_count(edge_count),
    .sampled_bit(sampled_bit)
  );

  deserializer #(
    .DATA_WIDTH(DATA_WIDTH)
  ) U0_deserializer (
    .CLK(CLK),
    .RST(RST),
    .Prescale(Prescale),
    .sampled_bit(sampled_bit),
    .Enable(deser_en),
    .edge_count(edge_count), 
    .P_DATA(P_DATA)
  );

  start_clk U0_start_chk (
    .CLK(CLK),
    .RST(RST),
    .sampled_bit(sampled_bit),
    .Enable(start_chk_en), 
    .strt_glitch(strt_glitch)
  );

  parity_clk #(
    .DATA_WIDTH(DATA_WIDTH)
  ) U0_parity_chk (
    .CLK(CLK),
    .RST(RST),
    .parity_type(parity_type),
    .sampled_bit(sampled_bit),
    .Enable(parity_chk_en), 
    .P_DATA(P_DATA),
    .par_err(parity_error)
  );

  stop_clk U0_stop_chk (
    .CLK(CLK),
    .RST(RST),
    .sampled_bit(sampled_bit),
    .Enable(stop_chk_en), 
    .stp_err(framing_error)
  );

endmodule 