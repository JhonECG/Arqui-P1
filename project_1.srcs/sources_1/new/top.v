`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2025 11:36:29
// Design Name: 
// Module Name: top
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

module top(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  ALUControl,
    output wire [31:0] Result,
    output wire [3:0]  ALUFlags
);

    // Señales internas
    wire [31:0] alu_result, fpu_result;
    wire [3:0]  alu_flags;

    // Instancia de la ALU entera
    alu alu_u (
        .a(a),
        .b(b),
        .ALUControl(ALUControl),
        .Result(alu_result),
        .ALUFlags(alu_flags)
    );

    // Instancia de la FPU (solo usa los 16 bits inferiores)
    fpu fpu_u (
        .a(a[15:0]),
        .b(b[15:0]),
        .ALUControl(ALUControl),
        .Result(fpu_result)
    );

    // Mux: selecciona resultado de ALU o FPU según ALUControl
    // 110x = FPU
    assign Result   = (ALUControl[3:2] == 2'b11) ? {16'b0, fpu_result[15:0]} : alu_result;
    assign ALUFlags = (ALUControl[3:2] == 2'b11) ? 4'b0000 : alu_flags;

endmodule

