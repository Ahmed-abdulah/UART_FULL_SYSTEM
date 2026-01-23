module Async_fifo #(
  parameter int D_SIZE = 16,
  parameter int F_DEPTH = 8,
  parameter int P_SIZE = 4
)(
  input  logic                i_w_clk,
  input  logic                i_w_rstn,
  input  logic                i_w_inc,
  input  logic                i_r_clk,
  input  logic                i_r_rstn,
  input  logic                i_r_inc,
  input  logic [D_SIZE-1:0]   i_w_data,
  output logic [D_SIZE-1:0]   o_r_data,
  output logic                o_full,
  output logic                o_empty
);

  logic [P_SIZE-2:0] r_addr, w_addr;
  logic [P_SIZE-1:0] w2r_ptr, r2w_ptr;
  logic [P_SIZE-1:0] gray_w_ptr, gray_rd_ptr;

  fifo_mem #(
    .F_DEPTH(F_DEPTH),
    .D_SIZE(D_SIZE),
    .P_SIZE(P_SIZE)
  ) u_fifo_mem (
    .w_clk(i_w_clk),
    .w_rstn(i_w_rstn),
    .w_inc(i_w_inc),
    .w_full(o_full),
    .w_addr(w_addr),
    .r_addr(r_addr),
    .w_data(i_w_data),
    .r_data(o_r_data)
  );

  fifo_rd #(.P_SIZE(P_SIZE)) u_fifo_rd (
    .r_clk(i_r_clk),
    .r_rstn(i_r_rstn),
    .r_inc(i_r_inc),
    .sync_wr_ptr(w2r_ptr),
    .rd_addr(r_addr),
    .gray_rd_ptr(gray_rd_ptr),
    .empty(o_empty)
  );

  BIT_SYNC #(
    .NUM_STAGES(2),
    .BUS_WIDTH(P_SIZE)
  ) u_w2r_sync (
    .CLK(i_r_clk),
    .RST(i_r_rstn),
    .ASYNC(gray_w_ptr),
    .SYNC(w2r_ptr)
  );

  fifo_wr #(.P_SIZE(P_SIZE)) u_fifo_wr (
    .w_clk(i_w_clk),
    .w_rstn(i_w_rstn),
    .w_inc(i_w_inc),
    .sync_rd_ptr(r2w_ptr),
    .w_addr(w_addr),
    .gray_w_ptr(gray_w_ptr),
    .full(o_full)
  );

  BIT_SYNC #(
    .NUM_STAGES(2),
    .BUS_WIDTH(P_SIZE)
  ) u_r2w_sync (
    .CLK(i_w_clk),
    .RST(i_w_rstn),
    .ASYNC(gray_rd_ptr),
    .SYNC(r2w_ptr)
  );

endmodule

module fifo_mem #(
  parameter int D_SIZE = 16,
  parameter int F_DEPTH = 8,
  parameter int P_SIZE = 4
)(
  input  logic                w_clk,
  input  logic                w_rstn,
  input  logic                w_full,
  input  logic                w_inc,
  input  logic [P_SIZE-2:0]   w_addr,
  input  logic [P_SIZE-2:0]   r_addr,
  input  logic [D_SIZE-1:0]   w_data,
  output logic [D_SIZE-1:0]   r_data
);

  logic [D_SIZE-1:0] FIFO_MEM [F_DEPTH-1:0];

  always_ff @(posedge w_clk or negedge w_rstn) begin
    if (!w_rstn) begin
      foreach(FIFO_MEM[i]) FIFO_MEM[i] <= '0;
    end else if (!w_full && w_inc) begin
      FIFO_MEM[w_addr] <= w_data;
    end
  end

  assign r_data = FIFO_MEM[r_addr];

endmodule

module fifo_rd #(
  parameter int P_SIZE = 4
)(
  input  logic                 r_clk,
  input  logic                 r_rstn,
  input  logic                 r_inc,
  input  logic [P_SIZE-1:0]    sync_wr_ptr,
  output logic [P_SIZE-2:0]    rd_addr,
  output logic                 empty,
  output logic [P_SIZE-1:0]    gray_rd_ptr
);

  logic [P_SIZE-1:0] rd_ptr;

  always_ff @(posedge r_clk or negedge r_rstn) begin
    if (!r_rstn) begin
      rd_ptr <= '0;
    end else if (!empty && r_inc) begin
      rd_ptr <= rd_ptr + 1'b1;
    end
  end

  assign rd_addr = rd_ptr[P_SIZE-2:0];

  always_ff @(posedge r_clk or negedge r_rstn) begin
    if (!r_rstn) begin
      gray_rd_ptr <= '0;
    end else begin
      case (rd_ptr)
        4'b0000: gray_rd_ptr <= 4'b0000;
        4'b0001: gray_rd_ptr <= 4'b0001;
        4'b0010: gray_rd_ptr <= 4'b0011;
        4'b0011: gray_rd_ptr <= 4'b0010;
        4'b0100: gray_rd_ptr <= 4'b0110;
        4'b0101: gray_rd_ptr <= 4'b0111;
        4'b0110: gray_rd_ptr <= 4'b0101;
        4'b0111: gray_rd_ptr <= 4'b0100;
        4'b1000: gray_rd_ptr <= 4'b1100;
        4'b1001: gray_rd_ptr <= 4'b1101;
        4'b1010: gray_rd_ptr <= 4'b1111;
        4'b1011: gray_rd_ptr <= 4'b1110;
        4'b1100: gray_rd_ptr <= 4'b1010;
        4'b1101: gray_rd_ptr <= 4'b1011;
        4'b1110: gray_rd_ptr <= 4'b1001;
        4'b1111: gray_rd_ptr <= 4'b1000;
      endcase
    end
  end

  assign empty = (sync_wr_ptr == gray_rd_ptr);

endmodule

module fifo_wr #(
  parameter int P_SIZE = 4
)(
  input  logic                 w_clk,
  input  logic                 w_rstn,
  input  logic                 w_inc,
  input  logic [P_SIZE-1:0]    sync_rd_ptr,
  output logic [P_SIZE-2:0]    w_addr,
  output logic [P_SIZE-1:0]    gray_w_ptr,
  output logic                 full
);

  logic [P_SIZE-1:0] w_ptr;

  always_ff @(posedge w_clk or negedge w_rstn) begin
    if (!w_rstn) begin
      w_ptr <= '0;
    end else if (!full && w_inc) begin
      w_ptr <= w_ptr + 1'b1;
    end
  end

  assign w_addr = w_ptr[P_SIZE-2:0];

  always_ff @(posedge w_clk or negedge w_rstn) begin
    if (!w_rstn) begin
      gray_w_ptr <= '0;
    end else begin
      case (w_ptr)
        4'b0000: gray_w_ptr <= 4'b0000;
        4'b0001: gray_w_ptr <= 4'b0001;
        4'b0010: gray_w_ptr <= 4'b0011;
        4'b0011: gray_w_ptr <= 4'b0010;
        4'b0100: gray_w_ptr <= 4'b0110;
        4'b0101: gray_w_ptr <= 4'b0111;
        4'b0110: gray_w_ptr <= 4'b0101;
        4'b0111: gray_w_ptr <= 4'b0100;
        4'b1000: gray_w_ptr <= 4'b1100;
        4'b1001: gray_w_ptr <= 4'b1101;
        4'b1010: gray_w_ptr <= 4'b1111;
        4'b1011: gray_w_ptr <= 4'b1110;
        4'b1100: gray_w_ptr <= 4'b1010;
        4'b1101: gray_w_ptr <= 4'b1011;
        4'b1110: gray_w_ptr <= 4'b1001;
        4'b1111: gray_w_ptr <= 4'b1000;
      endcase
    end
  end

  assign full = (sync_rd_ptr[P_SIZE-1] != gray_w_ptr[P_SIZE-1] &&
                 sync_rd_ptr[P_SIZE-2] != gray_w_ptr[P_SIZE-2] &&
                 sync_rd_ptr[P_SIZE-3:0] == gray_w_ptr[P_SIZE-3:0]);

endmodule

module BIT_SYNC #(
  parameter int NUM_STAGES = 2,
  parameter int BUS_WIDTH = 1
)(
  input  logic                    CLK,
  input  logic                    RST,
  input  logic [BUS_WIDTH-1:0]    ASYNC,
  output logic [BUS_WIDTH-1:0]    SYNC
);

  logic [NUM_STAGES-1:0] sync_reg [BUS_WIDTH-1:0];

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      foreach(sync_reg[i]) sync_reg[i] <= '0;
    end else begin
      foreach(sync_reg[i]) sync_reg[i] <= {sync_reg[i][NUM_STAGES-2:0], ASYNC[i]};
    end
  end

  always_comb begin
    foreach(SYNC[i]) SYNC[i] = sync_reg[i][NUM_STAGES-1];
  end

endmodule