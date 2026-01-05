import UART_rx_pkg::*;

module uart_rx_fsm #(
  parameter int DATA_WIDTH = 8
) (
  input  logic       CLK,
  input  logic       RST,
  input  logic       S_DATA,
  input  logic [5:0] Prescale,  
  input  logic       parity_enable, 
  input  logic [3:0] bit_count,
  input  logic [5:0] edge_count,
  input  logic       par_err,
  input  logic       stp_err, 
  input  logic       strt_glitch,
  output logic       start_chk_en,  
  output logic       edge_bit_en, 
  output logic       deser_en, 
  output logic       parity_chk_en, 
  output logic       stop_chk_en,
  output logic       dat_samp_en,
  output logic       data_valid
);

  fsm_state_e current_state, next_state;

  logic [5:0] check_edge;
  logic [5:0] error_check_edge;

  assign check_edge = Prescale - 6'd1;
  assign error_check_edge = Prescale - 6'd2;

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      current_state <= IDLE;
    end
    else begin
      current_state <= next_state;
    end
  end

  always_comb begin
    next_state = current_state;
    
    unique case (current_state)
      IDLE: begin
        if (!S_DATA) begin
          next_state = START;
        end
      end
      
      START: begin
        if (bit_count == 4'd0 && edge_count == check_edge) begin
          if (!strt_glitch) begin
            next_state = DATA;
          end
          else begin
            next_state = IDLE;
          end
        end
      end
      
      DATA: begin
        if (bit_count == 4'd8 && edge_count == check_edge) begin
          if (parity_enable) begin
            next_state = PARITY;
          end
          else begin
            next_state = STOP;
          end
        end
      end
      
      PARITY: begin
        if (bit_count == 4'd9 && edge_count == check_edge) begin
          next_state = STOP;
        end
      end
      
      STOP: begin
        if (parity_enable) begin
          if (bit_count == 4'd10 && edge_count == error_check_edge) begin
            next_state = ERR_CHK;
          end
        end
        else begin
          if (bit_count == 4'd9 && edge_count == error_check_edge) begin
            next_state = ERR_CHK;
          end
        end
      end
      
      ERR_CHK: begin
        if (!S_DATA) begin
          next_state = START;
        end
        else begin
          next_state = IDLE;
        end
      end
      
      default: begin
        next_state = IDLE;
      end
    endcase
  end

  always_comb begin
    edge_bit_en = 1'b0;
    dat_samp_en = 1'b0;
    deser_en    = 1'b0;
    parity_chk_en  = 1'b0;
    stop_chk_en  = 1'b0;
    data_valid  = 1'b0;
    start_chk_en = 1'b0;
    
    unique case (current_state)
      IDLE: begin
        if (!S_DATA) begin
          edge_bit_en = 1'b1;
          start_chk_en = 1'b1;
          dat_samp_en = 1'b1;
        end
      end
      
      START: begin
        start_chk_en = 1'b1;
        edge_bit_en = 1'b1;
        dat_samp_en = 1'b1;
      end
      
      DATA: begin
        edge_bit_en = 1'b1;
        deser_en    = 1'b1;
        dat_samp_en = 1'b1;
      end
      
      PARITY: begin
        edge_bit_en = 1'b1;
        parity_chk_en  = 1'b1;
        dat_samp_en = 1'b1;
      end
      
      STOP: begin
        edge_bit_en = 1'b1;
        stop_chk_en  = 1'b1;
        dat_samp_en = 1'b1;
      end
      
      ERR_CHK: begin
        dat_samp_en = 1'b1;
        if (par_err | stp_err) begin
          data_valid = 1'b0;
        end
        else begin
          data_valid = 1'b1;
        end
      end
      
      default: begin
      end
    endcase
  end

endmodule 