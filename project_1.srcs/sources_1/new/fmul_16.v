`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2025 11:39:00
// Design Name: 
// Module Name: fmul_16
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


module fmul_16 (
    input [15:0] A,
    input [15:0] B,
    output reg [15:0] result
);
    reg[21:0] manT;
    reg[9:0] manR;
    reg[4:0] expR;
    
    wire signA = A[15], signB = B[15];
    wire [4:0] expA = A[14:10], expB = B[14:10];
    wire [9:0] fracA = A[9:0], fracB = B[9:0];
    
    wire [10:0] manA = (expA != 0) ? {1'b1, fracA} : {1'b0, fracA};
    wire [10:0] manB = (expB != 0) ? {1'b1, fracB} : {1'b0, fracB};
        
    parameter N = 21;
    integer i;
    
    always @(*) begin
        if (expA == 5'd0 || expB == 5'd0)
            result = 16'd0;
        else  begin
            // 1. Getting new exp
            expR = expA + expB - 15;
            // 2. Multiply mants
            manT = manA * manB;
            
            // 3. Normalize if it's necessary
            if(manT[21] == 0) begin
                for (i = 0; i < N; i = i + 1) begin
                    if (manT[21] == 0) begin
                        manT = manT << 1;
                    end 
                end
                manR = manT[20:11];
            end 
            else begin 
                manR = manT[20:11];
                if(manT[10] == 1) begin
                    manR = manR + 1;
                end
                expR = expR + 1;
            end
    
        result = {A[15] ^ B[15], expR, manR[9:0]};

        end
    end    
endmodule
