module UART_TB;

    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD = 10;
    parameter TX_CLK_PERIOD = 8680;
    parameter RX_CLK_PERIOD = 8680;
    
    logic                    RST;
    logic                    TX_CLK;
    logic                    RX_CLK;
    logic                    RX_IN_S;
    logic [DATA_WIDTH-1:0]   RX_OUT_P;
    logic                    RX_OUT_V;
    logic [DATA_WIDTH-1:0]   TX_IN_P;
    logic                    TX_IN_V;
    logic                    TX_OUT_S;
    logic                    TX_OUT_V;
    logic [5:0]              Prescale;
    logic                    parity_enable;
    logic                    parity_type;
    logic                    parity_error;
    logic                    framing_error;

    UART #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .RST(RST),
        .TX_CLK(TX_CLK),
        .RX_CLK(RX_CLK),
        .RX_IN_S(RX_IN_S),
        .RX_OUT_P(RX_OUT_P),
        .RX_OUT_V(RX_OUT_V),
        .TX_IN_P(TX_IN_P),
        .TX_IN_V(TX_IN_V),
        .TX_OUT_S(TX_OUT_S),
        .TX_OUT_V(TX_OUT_V),
        .Prescale(Prescale),
        .parity_enable(parity_enable),
        .parity_type(parity_type),
        .parity_error(parity_error),
        .framing_error(framing_error)
    );

    initial begin
        TX_CLK = 0;
        forever #(TX_CLK_PERIOD/2) TX_CLK = ~TX_CLK;
    end

    initial begin
        RX_CLK = 0;
        forever #(RX_CLK_PERIOD/2) RX_CLK = ~RX_CLK;
    end

    initial begin
        RST = 1;
        TX_IN_V = 0;
        TX_IN_P = 0;
        RX_IN_S = 1;
        Prescale = 32;
        parity_enable = 1;
        parity_type = 0;

        #(TX_CLK_PERIOD);
        RST = 0;
        #(TX_CLK_PERIOD);
        RST = 1;

        #(TX_CLK_PERIOD * 2);
        TX_IN_P = 8'hA5;
        TX_IN_V = 1;
        #(TX_CLK_PERIOD);
        TX_IN_V = 0;

        wait(!TX_OUT_V);
        #(TX_CLK_PERIOD * 5);

        TX_IN_P = 8'h3C;
        TX_IN_V = 1;
        #(TX_CLK_PERIOD);
        TX_IN_V = 0;

        wait(!TX_OUT_V);
        #(TX_CLK_PERIOD * 20);

        $stop;
    end

    initial begin
        RX_IN_S = 1;
        #(RX_CLK_PERIOD * 10);
        
        RX_IN_S = 0;
        #(RX_CLK_PERIOD * 32);
        
        RX_IN_S = 1;
        #(RX_CLK_PERIOD * 32);
        RX_IN_S = 0;
        #(RX_CLK_PERIOD * 32);
        RX_IN_S = 1;
        #(RX_CLK_PERIOD * 32);
        RX_IN_S = 0;
        #(RX_CLK_PERIOD * 32);
        RX_IN_S = 0;
        #(RX_CLK_PERIOD * 32);
        RX_IN_S = 1;
        #(RX_CLK_PERIOD * 32);
        RX_IN_S = 0;
        #(RX_CLK_PERIOD * 32);
        RX_IN_S = 1;
        #(RX_CLK_PERIOD * 32);
        
        RX_IN_S = 0;
        #(RX_CLK_PERIOD * 32);
        
        RX_IN_S = 1;
        #(RX_CLK_PERIOD * 32);
    end

endmodule