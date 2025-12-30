module UART_TX #(
    parameter int DATA_WIDTH = 8
) (
    input  logic                     CLK,
    input  logic                     RST,
    input  logic [DATA_WIDTH-1:0]    P_DATA,
    input  logic                     Data_Valid,
    input  logic                     parity_enable,
    input  logic                     parity_type,
    output logic                     TX_OUT,
    output logic                     busy
);

    logic                seriz_en;
    logic                seriz_done;
    logic                ser_data;
    logic                parity;
    logic [1:0]          mux_sel;

    tx_fsm u_fsm (
        .CLK            (CLK),
        .RST            (RST),
        .Data_Valid     (Data_Valid),
        .parity_enable  (parity_enable),
        .ser_done       (seriz_done),
        .Ser_enable     (seriz_en),
        .mux_sel        (mux_sel),
        .busy           (busy)
    );

    serializer #(
        .WIDTH(DATA_WIDTH)
    ) u_serializer (
        .CLK         (CLK),
        .RST         (RST),
        .DATA        (P_DATA),
        .Busy        (busy),
        .Enable      (seriz_en),
        .Data_Valid  (Data_Valid),
        .ser_out     (ser_data),
        .ser_done    (seriz_done)
    );

    parity_calc #(
        .WIDTH(DATA_WIDTH)
    ) u_parity_calc (
        .CLK            (CLK),
        .RST            (RST),
        .parity_enable  (parity_enable),
        .parity_type    (parity_type),
        .DATA           (P_DATA),
        .Busy           (busy),
        .Data_Valid     (Data_Valid),
        .parity         (parity)
    );

    mux u_mux (
        .CLK   (CLK),
        .RST   (RST),
        .IN_0  (1'b0),
        .IN_1  (ser_data),
        .IN_2  (parity),
        .IN_3  (1'b1),
        .SEL   (mux_sel),
        .OUT   (TX_OUT)
    );

endmodule