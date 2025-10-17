module alu (
  input [31:0] a, b,
  input [3:0] ALUControl,
  output reg [31:0] Result,
  output wire [3:0] ALUFlags

);

    wire neg, zero, carry, overflow;
    wire [31:0] condinvb;
    wire [32:0] sum; 
    
    assign condinvb = ALUControl[0] ? ~b : b; 
    assign sum = a + condinvb + ALUControl[0];

    wire [31:0] fadd, fmul;
    
    
    
    always @(*) begin
        
        casez (ALUControl)
            4'b000?: Result = sum;
            4'b0010: Result = a & b;
            4'b0011: Result = a | b;
            4'b0100: Result = a ^ b;
          endcase
    end
    
    assign neg = Result[31];
    assign zero = (Result == 32'b0);
    assign carry = ((ALUControl[1] == 1'b0) & sum[32]);
    assign overflow =(ALUControl[1] == 1'b0) & ~(a[31] ^ b[31] ^ ALUControl[0]) & (a[31] ^ sum[31]);
    assign ALUFlags = {neg, zero, carry, overflow};

endmodule
