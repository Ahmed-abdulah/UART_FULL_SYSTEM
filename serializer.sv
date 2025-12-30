module serializer #(
    parameter int WIDTH = 8
) (
    input  logic             CLK,
    input  logic             RST,
    input  logic [WIDTH-1:0] DATA,
    input  logic             Enable,
    input  logic             Busy,
    input  logic             Data_Valid,
    output logic             ser_out,
    output logic             ser_done
);

    logic [WIDTH-1:0] data_reg;
    logic [2:0]       ser_count;

    always_ff @(posedge CLK or negedge RST) begin
        if (!RST) begin
            data_reg <= '0;
        end else if (Data_Valid && !Busy) begin
            data_reg <= DATA;
        end else if (Enable) begin
            data_reg <= data_reg >> 1;
        end
    end

    always_ff @(posedge CLK or negedge RST) begin
        if (!RST) begin
            ser_count <= '0;
        end else begin
            if (Enable) begin
                ser_count <= ser_count + 1'b1;
            end else begin
                ser_count <= '0;
            end
        end
    end

    assign ser_done = (ser_count == 3'b111);
    assign ser_out  = data_reg[0];

endmodule