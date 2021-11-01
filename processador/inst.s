/* Kleber Sobrinho */
/* executar o código Assembly na placa FPGA */

.section .text
.globl main
main:
        addi    a2,zero,55
	add	a3,a2,a1
/* Iremos usar o registrador sp para fazer acessos à memória.
   Spike supõe RAM a partir do endereço 0x80000000.
   A instrução lui coloca este valor em sp.
   Não precisa usar esta instrução para a implementação FPGA. */
        lui     sp,0x80000
	addi	sp,sp,0x40
pula:
	lw	a1,8(sp)
        sw      a3,16(sp)
        bne     a2,a3,pula
fim:
.skip  0x20 - (fim -main)  /* cria espaço ate o endereço 0x20 */
        lw   t4, 48(s0)    /* esta instrução ficará no endereço 0x20 */