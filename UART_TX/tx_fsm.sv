module tx_fsm (
    input  logic       CLK,
    input  logic       RST,
    input  logic       Data_Valid,
    input  logic       ser_done,
    input  logic       parity_enable,
    output logic       Ser_enable,
    output logic [1:0] mux_sel,
    output logic       busy
);

    typedef enum logic [2:0] {
        IDLE   = 3'b000,
        START  = 3'b001,
        DATA   = 3'b011,
        PARITY = 3'b010,
        STOP   = 3'b110
    } state_t;

    state_t current_state, next_state;
    logic   busy_comb;

    always_ff @(posedge CLK or negedge RST) begin
        if (!RST) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        next_state = current_state;
        
        unique case (current_state)
            IDLE: begin
                if (Data_Valid)
                    next_state = START;
            end
            
            START: begin
                next_state = DATA;
            end
            
            DATA: begin
                if (ser_done) begin
                    if (parity_enable)
                        next_state = PARITY;
                    else
                        next_state = STOP;
                end
            end
            
            PARITY: begin
                next_state = STOP;
            end
            
            STOP: begin
                next_state = IDLE;
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_comb begin
        Ser_enable = 1'b0;
        mux_sel    = 2'b00;
        busy_comb  = 1'b0;
        
        unique case (current_state)
            IDLE: begin
                Ser_enable = 1'b0;
                mux_sel    = 2'b11;
                busy_comb  = 1'b0;
            end
            
            START: begin
                Ser_enable = 1'b0;
                mux_sel    = 2'b00;
                busy_comb  = 1'b1;
            end
            
            DATA: begin
                Ser_enable = !ser_done;
                mux_sel    = 2'b01;
                busy_comb  = 1'b1;
            end
            
            PARITY: begin
                Ser_enable = 1'b0;
                mux_sel    = 2'b10;
                busy_comb  = 1'b1;
            end
            
            STOP: begin
                Ser_enable = 1'b0;
                mux_sel    = 2'b11;
                busy_comb  = 1'b1;
            end
            
            default: begin
                Ser_enable = 1'b0;
                mux_sel    = 2'b00;
                busy_comb  = 1'b0;
            end
        endcase
    end

    always_ff @(posedge CLK or negedge RST) begin
        if (!RST) begin
            busy <= 1'b0;
        end else begin
            busy <= busy_comb;
        end
    end

endmodule