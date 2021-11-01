// Kleber Sobrinho
// Caça-níquel

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
  end

   // Constantes utilizadas no sistema
   parameter COUNT = 4;
   parameter INCREMENT = 1;
   parameter LIMIT = 6;
   parameter START = 0;
   parameter END_1 = 3;
   parameter END_2 = 7;
   parameter END_3 = 11;

   // Contadores utilizados no sistema
   logic [COUNT-1:0] count1;
   logic [COUNT-1:0] count2;
   logic [COUNT-1:0] count3;
   
   // Declaração e atribuição das chaves de entrada
   logic reset, freeze_1, freeze_2, freeze_3;

   always_comb begin
      reset <= SWI[0];

      freeze_1 <= SWI[1];
      freeze_2 <= SWI[2];
      freeze_3 <= SWI[3];
   end

   // Manipulação dos contadores
   always_ff@(posedge clk_2) begin
      if(reset) begin
         count1 <= START;
         count2 <= START;
         count3 <= START;
      end else begin
         if(~freeze_1 && count1 < LIMIT) count1 <= count1 + INCREMENT;
         else if(~freeze_1 && count1 == LIMIT) count1 <= START;
         else count1 <= count1;

         if(~freeze_2 && count2 < LIMIT) count2 <= count2 + INCREMENT;
         else if(~freeze_2 && count2 == LIMIT) count2 <= START;
         else count2 <= count2;

         if(~freeze_3 && count3 < LIMIT) count3 <= count3 + INCREMENT;
         else if(~freeze_3 && count3 == LIMIT) count3 <= START;
         else count3 <= count3;
      end
   end

   // Relacionando a saída ao diplay LCD
   always_comb begin
      lcd_a[END_1:0] <= count1;
      lcd_a[END_2:4] <= count2;
      lcd_a[END_3:8] <= count3;
   end

endmodule
