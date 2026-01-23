module UART #(
    parameter DATA_WIDTH = 8
) (
    input  logic                     RST,
    input  logic                     TX_CLK,
    input  logic                     RX_CLK,
    input  logic                     RX_IN_S,
    output logic [DATA_WIDTH-1:0]    RX_OUT_P, 
    output logic                     RX_OUT_V,
    input  logic [DATA_WIDTH-1:0]    TX_IN_P, 
    input  logic                     TX_IN_V, 
    output logic                     TX_OUT_S,
    output logic                     TX_OUT_V,  
    input  logic [5:0]               Prescale, 
    input  logic                     parity_enable,
    input  logic                     parity_type,
    output logic                     parity_error,
    output logic                     framing_error
);

    UART_TX #(
        .DATA_WIDTH(DATA_WIDTH)
    ) UART_TX_inst (
        .CLK            (TX_CLK),
        .RST            (RST),
        .P_DATA         (TX_IN_P),
        .Data_Valid     (TX_IN_V),
        .parity_enable  (parity_enable),
        .parity_type    (parity_type), 
        .TX_OUT         (TX_OUT_S),
        .busy           (TX_OUT_V)
    );
 
    UART_RX #(
        .DATA_WIDTH(DATA_WIDTH)
    ) UART_RX_inst (
        .CLK            (RX_CLK),
        .RST            (RST),
        .RX_IN          (RX_IN_S),
        .Prescale       (Prescale),
        .parity_enable  (parity_enable),
        .parity_type    (parity_type),
        .P_DATA         (RX_OUT_P), 
        .data_valid     (RX_OUT_V),
        .parity_error   (parity_error),
        .framing_error  (framing_error)
    );

endmodule
