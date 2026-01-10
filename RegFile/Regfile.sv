module RegFile #(
  parameter int WIDTH = 8,
  parameter int DEPTH = 16,
  parameter int ADDR  = 4
)(
  input  logic                 CLK,
  input  logic                 RST,
  input  logic                 WrEn,
  input  logic                 RdEn,
  input  logic [ADDR-1:0]      Address,
  input  logic [WIDTH-1:0]     WrData,
  output logic [WIDTH-1:0]     RdData,
  output logic                 RdData_Valid,
  output logic [WIDTH-1:0]     REG0,
  output logic [WIDTH-1:0]     REG1,
  output logic [WIDTH-1:0]     REG2,
  output logic [WIDTH-1:0]     REG3
);

  logic [WIDTH-1:0] regArr [DEPTH];
  
  always_ff @(posedge CLK or negedge RST) begin
    if (!RST) begin
      RdData_Valid <= '0;
      RdData     <= '0;
      
      foreach (regArr[i]) begin
        if (i == 2)
          regArr[i] <= 8'b10000001;  
        else if (i == 3)
          regArr[i] <= 8'b0010_0000; 
        else
          regArr[i] <= '0;
      end
    end
    else begin
      RdData_Valid <= '0;
      
      if (WrEn && !RdEn) begin
        regArr[Address] <= WrData;
      end
      else if (RdEn && !WrEn) begin
        RdData     <= regArr[Address];
        RdData_Valid <= '1;
      end
    end
  end
  
  assign REG0 = regArr[0];
  assign REG1 = regArr[1];
  assign REG2 = regArr[2];
  assign REG3 = regArr[3];

endmodule