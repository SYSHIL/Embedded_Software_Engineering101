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
;-------------------------------------------------------------------------------
           ; Set GPIO P1.0 to be an output
           BIS.B      #1, &PADIR_L

           ; Enable interrupts
           NOP
           BIS #GIE, SR
           NOP

           ; Configure ACLK as the timer clock source, with both the
           ; ID is set to /2 and IDEX divider set to /1.
           ; ACLK runs at 32768 Hz
           ; once it passes through ID it is divided by 2 hence we get 16384 Hz
           ; one tick will take 1/16384 = 6.1 * 10^-5 seconds therefore for ticks to reach 0XFFFF(65536) it will take 4 seconds
           BIS #TASSEL_1, &TA0CTL   ; TASSEL == 1 selects ACLK
           BIS #ID_1, &TA0CTL       ; ID == 0 selects /2
           BIS #TAIDEX_0, &TA0EX0   ; IDEX == 0 selects /1

           ; Configure timer to interrupt on overflow.
           BIS #TAIE, &TA0CTL

           ; Configure timer in continuous mode.
           ; Setting MC to anything other than 0 also starts the timer, so we
           ; want to do this as the last timer configuration step.
           BIS #MC_2, &TA0CTL       ; MC == 2 selects continuous mode

MainLoop:  ; Do nothing, all action is in the interrupt
           JMP MainLoop
           NOP

TA0_ISR:
           ; Clear the interrupt flag.
           BIC #TAIFG, &TA0CTL

           ; Toggle GPIO P1.0
           XOR.B      #1, &PAOUT_L

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
            .sect   ".int52"
            .short  TA0_ISR
