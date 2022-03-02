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


; Main loop here
;-------------------------------------------------------------------------------

       	; Set GPIO P1.0 to be an output (DIR bit == 1)
       	BIS.B  	#1, &P1DIR
       	; Set GPIO P2.1 to be an input (DIR bit == 0)
       	BIC.B  	#2, &P2DIR
       	; Set GPIO P1.1 with pull up or pull down
       	BIS.B   #2, &P2REN
       	BIS.B   #2, &P2OUT

MainLoop:
       	; Test if GPIO P1.1 input voltage is 0 or 1
       	BIT.B  #2, &P2IN

       	; If P1.1 == 0, button is pushed: turn on the LED on P1.0
       	JZ TurnOffLED

       	; Button is not pushed if we get here.
       	; P1.1 == 1 if we get here, so turn off the LED on P1.0
       	BIS.B #1, &P1OUT

       	JMP AfterLEDSet

TurnOffLED:
        ; We jumped here because the button is pressed.
        ; Turn on LED and fall through to AfterLEDSet
       	BIC.B #1, &P1OUT

AfterLEDSet:

       	JMP MainLoop
       	NOP

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
            
