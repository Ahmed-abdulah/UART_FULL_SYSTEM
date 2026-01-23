module SYS_CTRL #(
  parameter WIDTH = 8,
  parameter ADDR = 4
)(
  input  logic                CLK,
  input  logic                RST,
  input  logic [WIDTH-1:0]    RF_RdData,
  input  logic                RF_RdData_VLD,
  input  logic [WIDTH*2-1:0]  ALU_OUT,
  input  logic                ALU_OUT_VLD,
  input  logic [WIDTH-1:0]    UART_RX_DATA,
  input  logic                UART_RX_VLD,
  input  logic                FIFO_FULL,
  output logic                ALU_EN,
  output logic [3:0]          ALU_FUN,
  output logic                CLKG_EN,
  output logic                CLKDIV_EN,
  output logic                RF_WrEn,
  output logic                RF_RdEn,
  output logic [ADDR-1:0]     RF_Address,
  output logic [WIDTH-1:0]    RF_WrData,
  output logic [WIDTH-1:0]    UART_TX_DATA,
  output logic                UART_TX_VLD
);

  typedef enum logic [3:0] {
    IDLE                = 4'b0000,
    WRITE_ADD_S         = 4'b0001,
    WRITE_DAT_S         = 4'b0011,
    READ_ADD_S          = 4'b0110,
    SEND_RF_RD_DAT_S    = 4'b0100,
    ALU_WP_OPA_S        = 4'b1000,
    ALU_WP_OPB_S        = 4'b1001,
    ALU_OP_FUN_S        = 4'b1100,
    ALU_OUT_STORE_S     = 4'b1110,
    ALU_WAIT_1st_byte_S = 4'b1111,
    ALU_WAIT_2nd_byte_S = 4'b1101
  } state_t;

  localparam logic [7:0] RF_WRITE_CMD  = 8'hAA;
  localparam logic [7:0] RF_READ_CMD   = 8'hBB;
  localparam logic [7:0] ALU_W_OP_CMD  = 8'hCC;
  localparam logic [7:0] ALU_WN_OP_CMD = 8'hDD;

  state_t current_state, next_state;

  logic [7:0]          RF_ADDR_REG;
  logic [2*WIDTH-1:0]  ALU_OUT_REG;
  logic                RF_ADDR_SAVE;
  logic                ALU_OUT_SAVE;

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  always_comb begin
    case (current_state)
      IDLE: begin
        if (UART_RX_VLD) begin
          case (UART_RX_DATA)
            RF_WRITE_CMD:  next_state = WRITE_ADD_S;
            RF_READ_CMD:   next_state = READ_ADD_S;
            ALU_W_OP_CMD:  next_state = ALU_WP_OPA_S;
            ALU_WN_OP_CMD: next_state = ALU_OP_FUN_S;
            default:       next_state = IDLE;
          endcase
        end else begin
          next_state = IDLE;
        end
      end

      WRITE_ADD_S: begin
        next_state = UART_RX_VLD ? WRITE_DAT_S : WRITE_ADD_S;
      end

      WRITE_DAT_S: begin
        next_state = UART_RX_VLD ? IDLE : WRITE_DAT_S;
      end

      READ_ADD_S: begin
        next_state = UART_RX_VLD ? SEND_RF_RD_DAT_S : READ_ADD_S;
      end

      SEND_RF_RD_DAT_S: begin
        next_state = RF_RdData_VLD ? IDLE : SEND_RF_RD_DAT_S;
      end

      ALU_WP_OPA_S: begin
        next_state = UART_RX_VLD ? ALU_WP_OPB_S : ALU_WP_OPA_S;
      end

      ALU_WP_OPB_S: begin
        next_state = UART_RX_VLD ? ALU_OP_FUN_S : ALU_WP_OPB_S;
      end

      ALU_OP_FUN_S: begin
        next_state = UART_RX_VLD ? ALU_OUT_STORE_S : ALU_OP_FUN_S;
      end

      ALU_OUT_STORE_S: begin
        next_state = ALU_OUT_VLD ? ALU_WAIT_1st_byte_S : ALU_OUT_STORE_S;
      end

      ALU_WAIT_1st_byte_S: begin
        next_state = ALU_WAIT_2nd_byte_S;
      end

      ALU_WAIT_2nd_byte_S: begin
        next_state = IDLE;
      end

      default: begin
        next_state = IDLE;
      end
    endcase
  end

  always_comb begin
    ALU_EN       = 1'b0;
    ALU_FUN      = 4'b0;
    CLKG_EN      = 1'b0;
    CLKDIV_EN    = 1'b1;
    RF_WrEn      = 1'b0;
    RF_RdEn      = 1'b0;
    RF_Address   = '0;
    RF_WrData    = '0;
    UART_TX_DATA = '0;
    UART_TX_VLD  = 1'b0;
    ALU_OUT_SAVE = 1'b0;
    RF_ADDR_SAVE = 1'b0;

    case (current_state)
      IDLE: begin
        ALU_EN     = 1'b0;
        ALU_FUN    = 4'b0;
        CLKG_EN    = 1'b0;
        CLKDIV_EN  = 1'b1;
        RF_WrEn    = 1'b0;
        RF_RdEn    = 1'b0;
        RF_Address = '0;
        RF_WrData  = '0;
      end

      WRITE_ADD_S: begin
        RF_ADDR_SAVE = UART_RX_VLD;
      end

      WRITE_DAT_S: begin
        if (UART_RX_VLD) begin
          RF_WrEn    = 1'b1;
          RF_Address = RF_ADDR_REG[ADDR-1:0];
          RF_WrData  = UART_RX_DATA;
        end else begin
          RF_WrEn    = 1'b0;
          RF_Address = RF_ADDR_REG[ADDR-1:0];
          RF_WrData  = UART_RX_DATA;
        end
      end

      READ_ADD_S: begin
        if (UART_RX_VLD) begin
          RF_RdEn    = 1'b1;
          RF_Address = UART_RX_DATA[ADDR-1:0];
        end else begin
          RF_RdEn = 1'b0;
        end
      end

      SEND_RF_RD_DAT_S: begin
        if (RF_RdData_VLD && !FIFO_FULL) begin
          UART_TX_DATA = RF_RdData;
          UART_TX_VLD  = 1'b1;
        end else begin
          UART_TX_VLD = 1'b0;
        end
      end

      ALU_WP_OPA_S: begin
        if (UART_RX_VLD) begin
          RF_WrEn    = 1'b1;
          RF_Address = '0;
          RF_WrData  = UART_RX_DATA;
        end else begin
          RF_WrEn    = 1'b0;
          RF_Address = '0;
          RF_WrData  = UART_RX_DATA;
        end
      end

      ALU_WP_OPB_S: begin
        if (UART_RX_VLD) begin
          RF_WrEn    = 1'b1;
          RF_Address = 4'b0001;
          RF_WrData  = UART_RX_DATA;
        end else begin
          RF_WrEn    = 1'b0;
          RF_Address = 4'b0001;
          RF_WrData  = UART_RX_DATA;
        end
      end

      ALU_OP_FUN_S: begin
        CLKG_EN = 1'b1;
        if (UART_RX_VLD) begin
          ALU_EN  = 1'b1;
          ALU_FUN = UART_RX_DATA[3:0];
        end else begin
          ALU_EN  = 1'b0;
          ALU_FUN = UART_RX_DATA[3:0];
        end
      end

      ALU_OUT_STORE_S: begin
        CLKG_EN      = 1'b1;
        ALU_OUT_SAVE = ALU_OUT_VLD;
      end

      ALU_WAIT_1st_byte_S: begin
        CLKG_EN = 1'b1;
        if (!FIFO_FULL) begin
          UART_TX_DATA = ALU_OUT_REG[WIDTH-1:0];
          UART_TX_VLD  = 1'b1;
        end
      end

      ALU_WAIT_2nd_byte_S: begin
        CLKG_EN = 1'b1;
        if (!FIFO_FULL) begin
          UART_TX_DATA = ALU_OUT_REG[2*WIDTH-1:WIDTH];
          UART_TX_VLD  = 1'b1;
        end
      end

      default: begin
        ALU_EN     = 1'b0;
        ALU_FUN    = 4'b0;
        CLKG_EN    = 1'b0;
        CLKDIV_EN  = 1'b1;
        RF_WrEn    = 1'b0;
        RF_RdEn    = 1'b0;
        RF_Address = '0;
        RF_WrData  = '0;
      end
    endcase
  end

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      RF_ADDR_REG <= 8'b0;
    end else begin
      if (RF_ADDR_SAVE) begin
        RF_ADDR_REG <= UART_RX_DATA;
      end
    end
  end

  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      ALU_OUT_REG <= '0;
    end else begin
      if (ALU_OUT_SAVE) begin
        ALU_OUT_REG <= ALU_OUT;
      end
    end
  end

endmodule