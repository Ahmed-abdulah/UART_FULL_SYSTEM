module parity_calc #(
    parameter int WIDTH = 8
) (
    input  logic             CLK,
    input  logic             RST,
    input  logic             parity_enable,
    input  logic             parity_type,
    input  logic             Busy,
    input  logic [WIDTH-1:0] DATA,
    input  logic             Data_Valid,
    output logic             parity
);

    logic [WIDTH-1:0] data_reg;

    always_ff @(posedge CLK or negedge RST) begin
        if (!RST) begin
            data_reg <= '0;
        end else if (Data_Valid && !Busy) begin
            data_reg <= DATA;
        end
    end

    always_ff @(posedge CLK or negedge RST) begin
        if (!RST) begin
            parity <= 1'b0;
        end else if (parity_enable) begin
            unique case (parity_type)
                1'b0: parity <= ^data_reg;
                1'b1: parity <= ~^data_reg;
            endcase
        end
    end

endmodule