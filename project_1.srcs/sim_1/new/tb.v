`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2025 11:39:38
// Design Name: 
// Module Name: tb
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



module tb;

    // Entradas
    reg [31:0] a, b;
    reg [3:0]  ALUControl;

    // Salidas
    wire [31:0] Result;
    wire [3:0]  ALUFlags;

    // Instancia del módulo top
    top uut (
        .a(a),
        .b(b),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

    // Proceso de prueba
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        $display("=== INICIO DE TEST ALU/FPU ===");
        
        // ---------------- ALU Tests ----------------

        // ADD
        ALUControl = 3'b000;
        a = 32'd10; b = 32'd5;
        #10 $display("ADD: %d + %d = %d | Flags=%b", a, b, Result, ALUFlags);

        // SUB
        ALUControl = 3'b001;
        a = 32'd15; b = 32'd7;
        #10 $display("SUB: %d - %d = %d | Flags=%b", a, b, Result, ALUFlags);

       
        // ---------------- FPU Tests ----------------
      

        // FADD: 4.5 + 2.0
        ALUControl = 4'b1101;
        a = 32'h4900;  // 4.5 (half)
        b = 32'h4000;  // 2.0 (half)
        #10 $display("FADD (half): 4.5 + 2.0 -> A=%h, B=%h, Result=%h", a[15:0], b[15:0], Result[15:0]);
        
        // FMUL: 4.5 * 2.0
        ALUControl = 4'b1100;
        a = 32'h4900;  // 4.5
        b = 32'h4000;  // 2.0
        #10 $display("FMUL (half): 4.5 * 2.0 -> A=%h, B=%h, Result=%h", a[15:0], b[15:0], Result[15:0]);
        
        $display("=== FIN DE TEST ===");
        $finish;
    end

endmodule

