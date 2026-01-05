module mux (
    input  logic       CLK,
    input  logic       RST,
    input  logic       IN_0,
    input  logic       IN_1,
    input  logic       IN_2,
    input  logic       IN_3,
    input  logic [1:0] SEL,
    output logic       OUT
);

    logic mux_out;

    always_comb begin
        unique case (SEL)
            2'b00:   mux_out = IN_0;
            2'b01:   mux_out = IN_1;
            2'b10:   mux_out = IN_2;
            2'b11:   mux_out = IN_3;
            default: mux_out = 1'b1;
        endcase
    end

    always_ff @(posedge CLK or negedge RST) begin
        if (!RST) begin
            OUT <= 1'b0;
        end else begin
            OUT <= mux_out;
        end
    end

endmodule