// Kleber Sobrinho
// Pisca-pisca com reset, congelar e mudar sentido

// DESCRIPTION: Verilator: Systemverilog example module
// with interface to switch buttons, LEDs, LCD and register display

parameter divide_by=100000000;  // divisor do clock de referência
// A frequencia do clock de referencia é 50 MHz.
// A frequencia de clk_2 será de  50 MHz / divide_by

parameter NBITS_INSTR = 32;
parameter NBITS_TOP = 8, NREGS_TOP = 32, NBITS_LCD = 64;
module top(input  logic clk_2,
           input  logic [NBITS_TOP-1:0] SWI,
           output logic [NBITS_TOP-1:0] LED,
           output logic [NBITS_TOP-1:0] SEG,
           output logic [NBITS_LCD-1:0] lcd_a, lcd_b,
           output logic [NBITS_INSTR-1:0] lcd_instruction,
           output logic [NBITS_TOP-1:0] lcd_registrador [0:NREGS_TOP-1],
           output logic [NBITS_TOP-1:0] lcd_pc, lcd_SrcA, lcd_SrcB,
             lcd_ALUResult, lcd_Result, lcd_WriteData, lcd_ReadData, 
           output logic lcd_MemWrite, lcd_Branch, lcd_MemtoReg, lcd_RegWrite);

   always_comb begin
      lcd_WriteData <= SWI;
      lcd_pc <= 'h12;
      lcd_instruction <= 'h34567890;
      lcd_SrcA <= 'hab;
      lcd_SrcB <= 'hcd;
      lcd_ALUResult <= 'hef;
      lcd_Result <= 'h11;
      lcd_ReadData <= 'h33;
      lcd_MemWrite <= SWI[0];
      lcd_Branch <= SWI[1];
      lcd_MemtoReg <= SWI[2];
      lcd_RegWrite <= SWI[3];
      for(int i=0; i<NREGS_TOP; i++)
         if(i != NREGS_TOP/2-1) lcd_registrador[i] <= i+i*16;
         else                   lcd_registrador[i] <= ~SWI;
      lcd_a <= {56'h1234567890ABCD, SWI};
      lcd_b <= {SWI, 56'hFEDCBA09876543};
   end

   // Constantes utilizadas no sistema
   parameter NBITS_INPUT = 1;
   parameter NBITS_OUTPUT = 8;
   parameter START_RIGHT = 'b10000000; 
   parameter START_LEFT = 'b00000001; 

   // Declaração e atribuição da saída e das chaves de entrada
   logic [NBITS_OUTPUT-1:0] _output; 
   logic [NBITS_INPUT-1:0] reset; 
   logic [NBITS_INPUT-1:0] freeze; 
   logic [NBITS_INPUT-1:0] way;

   always_comb begin
      reset <= SWI[0];
      freeze <= SWI[1]; 
      way <= SWI[2]; // Para o valor 0 o pisca pisca segue vai da esquerda para a direita, e quando o valor é 1 segue o sentido oposto
   end

   // Manipulação da saída
   always_ff @(posedge clk_2 ) begin
      if ((_output == 0 || reset == 1) && way == 0) _output <= START_RIGHT; 
      else if ((_output == 0 || reset == 1) && way == 1) _output <= START_LEFT; 
      else if (freeze == 1) _output <= _output; 
      else if (way == 1) _output <= _output * 2; 
      else _output <= _output / 2;
   end

   // Atribuindo o valor da saída aos LEDs
   always_comb begin 
      LED <= _output; 
   end

endmodule

