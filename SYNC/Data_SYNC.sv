module DATA_SYNC #(
  parameter int NUM_STAGES = 2,
  parameter int BUS_WIDTH = 8
)(
  input  logic                  CLK,
  input  logic                  RST,
  input  logic [BUS_WIDTH-1:0]  unsync_bus,
  input  logic                  bus_enable,
  output logic [BUS_WIDTH-1:0]  sync_bus,
  output logic                  enable_pulse_d
);

  logic [NUM_STAGES-1:0] sync_reg;
  logic                  enable_flop;
  logic                  enable_pulse;
  logic [BUS_WIDTH-1:0]  sync_bus_c;

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      sync_reg <= '0;
    end else begin
      sync_reg <= {sync_reg[NUM_STAGES-2:0], bus_enable};
    end
  end

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      enable_flop <= 1'b0;
    end else begin
      enable_flop <= sync_reg[NUM_STAGES-1];
    end
  end

  assign enable_pulse = sync_reg[NUM_STAGES-1] && !enable_flop;

  assign sync_bus_c = enable_pulse ? unsync_bus : sync_bus;

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      sync_bus <= '0;
    end else begin
      sync_bus <= sync_bus_c;
    end
  end

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      enable_pulse_d <= 1'b0;
    end else begin
      enable_pulse_d <= enable_pulse;
    end
  end

endmodule