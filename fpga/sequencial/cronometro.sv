// Kleber Sobrinho
// Cronômetro de 10 segundos com reset, congelamente e contagem crescente e decrescente

// DESCRIPTION: Verilator: Systemverilog example module
// with interface to switch buttons, LEDs, LCD and register display

// O valor do clock foi alterado para que ele mude a cada 1 segundo
parameter divide_by=50000000;  // divisor do clock de referência
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
   parameter NBITS_COUNT = 4;
   parameter NUMBER_0 = 'b00111111;
   parameter NUMBER_1 = 'b00000110;
   parameter NUMBER_2 = 'b01011011;
   parameter NUMBER_3 = 'b01001111;
   parameter NUMBER_4 = 'b01100110;
   parameter NUMBER_5 = 'b01101101;
   parameter NUMBER_6 = 'b01111101;
   parameter NUMBER_7 = 'b00000111;
   parameter NUMBER_8 = 'b01111111;
   parameter NUMBER_9 = 'b01100111;
   parameter NUMBER_10_A = 'b01110111; 
   parameter EMPTY = 'b00000000;

   parameter INC = 1;

   // Contador utilizado no sistema
   logic [NBITS_COUNT-1:0] counter;

   // Declaração e atribuição das chaves de entrada
   logic freeze, reset, reverse;

   always_comb begin
      reset <= SWI[0];
      freeze <= SWI[1];
      reverse <= SWI[2];
   end

   // Atribuição do contador ao display de 7 segmentos
   always_comb begin
      case (counter)
         0: SEG <= NUMBER_0;
         1: SEG <= NUMBER_1;
         2: SEG <= NUMBER_2;
         3: SEG <= NUMBER_3;
         4: SEG <= NUMBER_4;
         5: SEG <= NUMBER_5;
         6: SEG <= NUMBER_6;
         7: SEG <= NUMBER_7;
         8: SEG <= NUMBER_8;
         9: SEG <= NUMBER_9;
         10: SEG <= NUMBER_10_A;
         default: SEG <= EMPTY;
      endcase
   end
   
   // Manipulação do contador
   always_ff @(posedge clk_2 ) begin
      if (reset) counter <= 0; 
      else if (freeze) counter <= counter; 
      else if (reverse) counter <= counter - INC;
      else if (counter <= 10) counter <= counter + INC; 
      else counter <= 0;
   end

endmodule

