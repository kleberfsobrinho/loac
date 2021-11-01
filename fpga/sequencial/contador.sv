// Kleber Sobrinho
// Contador 4 bits - Reset, Saturação, Congelamento, Incrimento de 3

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
   parameter INCREMENT_1 = 1;
  	parameter INCREMENT_3 = 3;
   parameter START = 0;
  	parameter END = 15;
	
   // Contador utilizado no sistema
   logic [COUNT-1:0] counter;
  	
   // Declaração e atribuição das chaves de entrada
   logic reset, decrement, increment_3, freeze, saturation;
   
	always_comb	begin
      reset <= SWI[0];
      decrement <= SWI[1];
      increment_3 <= SWI[2];
      freeze <= SWI[3];
      saturation <= SWI[4];
   end
	
   // Manipulação do contador
	always_ff@(posedge clk_2) begin
      if(~freeze) begin
         if(saturation && (counter == END || counter == START)) counter <= counter;
         else begin
            if(reset) counter <= START;
            else if(decrement) begin
               if(increment_3) counter <= counter - INCREMENT_3;
               else counter <=  counter - INCREMENT_1;
            end else begin 
               if(increment_3) counter <= counter + INCREMENT_3;
               else counter <=  counter + INCREMENT_1;			
            end
         end
      end else begin
         counter <= counter;
      end
	end
   
   // Saída do contador atribuída ao diplay LCD
	always_comb begin
      lcd_b = counter;
   end

endmodule
