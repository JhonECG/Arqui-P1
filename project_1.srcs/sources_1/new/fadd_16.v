`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2025 11:38:27
// Design Name: 
// Module Name: fadd_16
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fadd_16 (
  input  [15:0] A,
  input  [15:0] B,
  output wire [15:0] result
);
  wire signA, signB;
  wire [4:0] expA, expB;
  wire [10:0] manA, manB;
  wire [4:0] expDiff, expAligned;
  wire [10:0] manA_shifted, manB_shifted;

  assign signA = A[15];
  assign signB = B[15];
  assign expA = A[14:10];
  assign expB = B[14:10];
  assign manA = (expA != 0) ? {1'b1, A[9:0]} : {1'b0, A[9:0]};
  assign manB = (expB != 0) ? {1'b1, B[9:0]} : {1'b0, B[9:0]};
  assign expDiff = (expA > expB) ? (expA - expB) : (expB - expA);
  assign manA_shifted = (expA > expB) ? manA : (manA >> expDiff);
  assign manB_shifted = (expB > expA) ? manB : (manB >> expDiff);
  assign expAligned = (expA > expB) ? expA : expB;

  reg [11:0] mantissaSum;
  reg resultSign;

  always @(*) begin
    if (signA == signB) begin
      mantissaSum = manA_shifted + manB_shifted;
      resultSign = signA;
    end else begin
      if (manA_shifted > manB_shifted) begin
        mantissaSum = manA_shifted - manB_shifted;
        resultSign = signA;
      end else begin
        mantissaSum = manB_shifted - manA_shifted;
        resultSign = signB;
      end
    end
  end

  reg [4:0] finalExp;
  reg [10:0] finalMan;

  always @(*) begin
    finalExp = expAligned;
    finalMan = mantissaSum[10:0];

    if (mantissaSum[11]) begin
      finalMan = mantissaSum[11:1];
      finalExp = finalExp + 1;
    end else begin
      while (finalMan[10] == 0 && finalExp > 1) begin
        finalMan = finalMan << 1;
        finalExp = finalExp - 1;
      end
    end
  end

  wire [9:0] finalFrac = finalMan[9:0];
  assign result = (mantissaSum == 0) ? 16'b0 : {resultSign, finalExp, finalFrac};

endmodule


