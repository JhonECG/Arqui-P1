`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Simple TB estilo "a,b,ALUControl" para top (wrapper de fp_alu)
// - Pruebas en SINGLE y HALF
// - Muestra Result y ALUFlags
//////////////////////////////////////////////////////////////////////////////////

module tb;

    // Entradas
    reg [31:0] a, b;
    reg [3:0]  ALUControl;

    // Salidas
    wire [31:0] Result;
    wire [4:0]  ALUFlags;   // {OVF, UDF, DBZ, INV, INX}

    // Instancia del módulo top (wrapper)
    top uut (
        .a(a),
        .b(b),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

    // Helpers de impresión
    task show32(input [127:0] tag);
      $display("%s | A=0x%08h  B=0x%08h  -> Result=0x%08h  Flags=%b",
               tag, a, b, Result, ALUFlags);
    endtask

    task show16(input [127:0] tag);
      $display("%s | A=0x%04h  B=0x%04h  -> Result=0x%04h  Flags=%b",
               tag, a[15:0], b[15:0], Result[15:0], ALUFlags);
    endtask

    initial begin
        $display("=== INICIO DE TEST FP_ALU (formato estilo solicitado) ===");

        // Inicialización para no disparar start en reset/flanco
        a = 32'h0000_0000;
        b = 32'h0000_0000;
        ALUControl = 4'h0;

        // Espera a que el 'top' suelte reset (lo hace en #20) y evita flanco de 30 ns
        #31;

        // ------------ SINGLE (32-bit) ------------
        // 1000=FADD, 1001=FSUB, 1010=FMUL, 1011=FDIV

        // FADD: 1.5 + 2.0 = 3.5  (0x3FC00000 + 0x40000000 -> 0x40600000)
        ALUControl = 4'b1000;
        a = 32'h3FC0_0000; b = 32'h4000_0000;  // 1.5 , 2.0
        #25 show32("FADD (single) 1.5 + 2.0");

        // FSUB: 2.0 - 1.0 = 1.0
        ALUControl = 4'b1001;
        a = 32'h4000_0000; b = 32'h3F80_0000;  // 2.0 , 1.0
        #25 show32("FSUB (single) 2.0 - 1.0");

        // FMUL: 1.5 * 2.0 = 3.0
        ALUControl = 4'b1010;
        a = 32'h3FC0_0000; b = 32'h4000_0000;  // 1.5 , 2.0
        #25 show32("FMUL (single) 1.5 * 2.0");

        // FDIV: 1.0 / 2.0 = 0.5
        ALUControl = 4'b1011;
        a = 32'h3F80_0000; b = 32'h4000_0000;  // 1.0 , 2.0
        #25 show32("FDIV (single) 1.0 / 2.0");

        // Casos especiales (single)
        // DIV by zero -> +Inf y DBZ=1 (flags[2])
        ALUControl = 4'b1011;
        a = 32'h3F80_0000; b = 32'h0000_0000;  // 1.0 / 0.0
        #25 show32("FDIV (single) 1.0 / 0.0 (DBZ)");

        // 0 * +Inf -> NaN (INV)
        ALUControl = 4'b1010;
        a = 32'h0000_0000; b = 32'h7F80_0000;  // 0.0 * +Inf
        #25 show32("FMUL (single) 0.0 * +Inf (INV)");

        // ------------ HALF (16-bit) --------------
        // 1101=FADD, 1110=FSUB, 1100=FMUL, 1111=FDIV
        // Nota: se usan A[15:0] y B[15:0]; el resultado válido está en Result[15:0]

        // FADD: 1.0h + 2.0h = 3.0h  (1.0=0x3C00, 2.0=0x4000, 3.0=0x4200)
        ALUControl = 4'b1101;
        a = 32'h0000_3C00; b = 32'h0000_4000;
        #25 show16("FADD (half) 1.0h + 2.0h");

        // FSUB: 2.0h - 1.0h = 1.0h
        ALUControl = 4'b1110;
        a = 32'h0000_4000; b = 32'h0000_3C00;
        #25 show16("FSUB (half) 2.0h - 1.0h");

        // FMUL: 1.5h * 2.0h = 3.0h  (1.5h=0x3E00)
        ALUControl = 4'b1100;
        a = 32'h0000_3E00; b = 32'h0000_4000;
        #25 show16("FMUL (half) 1.5h * 2.0h");

        // FDIV: 1.0h / 2.0h = 0.5h (0.5h=0x3800)
        ALUControl = 4'b1111;
        a = 32'h0000_3C00; b = 32'h0000_4000;
        #25 show16("FDIV (half) 1.0h / 2.0h");

        // Casos especiales (half)
        // 1.0h / 0 -> +Infh y DBZ=1
        ALUControl = 4'b1111;
        a = 32'h0000_3C00; b = 32'h0000_0000;
        #25 show16("FDIV (half) 1.0h / 0 (DBZ)");

        // 0 * +Infh -> NaNh (INV)
        ALUControl = 4'b1100;
        a = 32'h0000_0000; b = 32'h0000_7C00;
        #25 show16("FMUL (half) 0 * +Infh (INV)");

        $display("=== FIN DE TEST ===");
        $finish;
    end

endmodule
