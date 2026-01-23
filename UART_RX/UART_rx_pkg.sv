package UART_rx_pkg;
  
  parameter DATA_WIDTH = 8;
  
  typedef enum logic [2:0] {
    IDLE     = 3'b000,
    START    = 3'b001,
    DATA     = 3'b011,
    PARITY   = 3'b010,
    STOP     = 3'b110,
    ERR_CHK  = 3'b111
  } fsm_state_e;
  
  typedef enum logic {
    EVEN_PARITY = 1'b0,
    ODD_PARITY  = 1'b1
  } parity_type_e;
  
endpackage 