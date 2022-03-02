;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
    ; Set GPIO P1.0 to be an output (P1DIR bit 0 == 1)
           BIS.B      #1, &P1DIR
           ; Set GPIO P1.1 to be an input (P1DIR bit 1 == 0)
           BIC.B      #2, &P1DIR
           ; Set GPIO P1.1 to be pulled up or down (P1REN bit 1 == 1)
           BIS.B      #2, &P1REN
           ; Set GPIO P1.1 as a pull-up resistor (P1OUT bit 1 == 1)
           BIS.B      #2, &P1OUT

           ; Set interrupt on high-to-low transition of P1.1
           BIS.B      #2, &P1IES
           ; Clear any interrupts that happened when changing P1IES
           BIC.B      #2, &P1IFG
           ; Enable P1.1 interrupts
           BIS.B      #2, &P1IE

           ; Enable interrupts
           NOP ; the user’s guide recommends a NOP before setting #GIE
           BIS #GIE, SR
           NOP ; the user’s guide recommends a NOP after setting #GIE

MainLoop:  ; infinite loop that does nothing

           JMP MainLoop
           NOP

PORT1_ISR:
           ; Clear the interrupt flag.
           BIC #2, &P1IFG

           ; Toggle GPIO P1.0
           XOR.B      #1, &P1OUT

           RETI

                                            

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            .sect ".int47"
            .short PORT1_ISR
