module ClkDiv #(
  parameter int RATIO_WD = 8
)(
  input  logic                  i_ref_clk,
  input  logic                  i_rst,
  input  logic                  i_clk_en,
  input  logic [RATIO_WD-1:0]   i_div_ratio,
  output logic                  o_div_clk
);

  logic [RATIO_WD-2:0] count;
  logic [RATIO_WD-2:0] edge_flip_half;
  logic [RATIO_WD-2:0] edge_flip_full;
  logic                div_clk;
  logic                odd_edge_tog;
  logic                is_one;
  logic                is_zero;
  logic                clk_en;
  logic                is_odd;

  always_ff @(posedge i_ref_clk or negedge i_rst) begin
    if (!i_rst) begin
      count <= '0;
      div_clk <= '0;
      odd_edge_tog <= 1'b1;
    end else if (clk_en) begin
      if (!is_odd && (count == edge_flip_half)) begin
        count <= '0;
        div_clk <= ~div_clk;
      end else if ((is_odd && (count == edge_flip_half) && odd_edge_tog) || 
                   (is_odd && (count == edge_flip_full) && !odd_edge_tog)) begin
        count <= '0;
        div_clk <= ~div_clk;
        odd_edge_tog <= ~odd_edge_tog;
      end else begin
        count <= count + 1'b1;
      end
    end
  end

  assign is_odd = i_div_ratio[0];
  assign edge_flip_half = ((i_div_ratio >> 1) - 1);
  assign edge_flip_full = (i_div_ratio >> 1);
  assign is_zero = ~|i_div_ratio;
  assign is_one = (i_div_ratio == 1'b1);
  assign clk_en = i_clk_en & !is_one & !is_zero;
  assign o_div_clk = clk_en ? div_clk : i_ref_clk;

endmodule