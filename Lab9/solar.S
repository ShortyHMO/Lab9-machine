#CONSTANTS
      ;motor AND SWITCHES
      ; portB setup
      .set PORTB,0x05
      .set DDIRB,0x04
      .set MOTDATA,0
      .set MOTLATCH,4
      .set M1ENABLE,3
      .set BOARDLED, 5
      .set PINB,0x03 
      .set  SWITCH2,2 
      .set  SWITCH1,2
      .set SDA,4
      .set SCL,5
      .set DIDR0, 0x007E
      .set ADCH,  0x0079
      .set ADCSRA,0x007A
      .set ADMUX, 0x007C

    
      ; portD setup
      .set PORTD,0x0B
      .set DDIRD,0x0A
      .set MOTCLOCK,4
      .set M2ENABLE,3
      .set M4ENABLE,6
      .set M3ENABLE,5     


      ;lightsensor  
      ; portc setup
      .set PORTC,0x08
      .set DDIRC,0x07
      .set PINC, 0x06
      .set SDA,4
      .set SCL,5
      .set DIDR0, 0x007E
      .set ADCH,  0x0079
      .set ADCSRA,0x007A
      .set ADMUX, 0x007C
      


      .extern delay
      
      .data

      .text
      .global operatePanel, initializePanel, returnPanel, resetPanel, parkPanel, queryPanel

initializePanel:
      ldi r20 ,0xff
      out DDIRB, r20
      out DDIRD, r20
      ldi   r17,    0b00111111
      sts   DIDR0,  r17
      ldi   r17,    0b10000111
      sts   ADCSRA, r17
      cbi   DDIRB,SWITCH2   ; make pin 2 an input pin            
      sbi   PORTB,SWITCH2   ; turn on pullup resistor for pin 2         
      call  delay1          ; give pull-up time to settle 
      cbi   DDIRB,SWITCH1   ; make pin 2 an input pin            
      sbi   PORTB,SWITCH1   ; turn on pullup resistor for pin 2         
      call  delay1 
      ldi r29,0
lightloop:
      call lighton
      call delay2
      call lightoff
      inc r29
      cpi r29,3
      Brne lightloop
      ret
      
//      clr   r25
//      ldi   r24, 1
//      ret

//operatePanel:
//      call rotateforward
//      call delay1
//      clr   r25
//      ldi   r24, 1
//      ret

      ;array passed in with r25:24
Delays:
delay1:
      ldi   r22, 0x0a
      ldi   r23, 0x00
      ldi   r24, 0
      ldi   r25, 0
      call  delay
      ret
delay2:
      ldi   r22, 0xD0
      ldi   r23, 0x07
      ldi   r24, 0
      ldi   r25, 0
      call  delay
      ret

delayLong:     
      ldi   r22, 0xe8
      ldi   r23, 0x13
      ldi   r24, 0
      ldi   r25, 0
      call  delay     
      ret





Switch:
switchloop:
  //sbis  PINB, SWITCH2
 // rjmp  reset



LED:

lighton:
  ldi r17, 0xff  
  ldi r18,  0xff 
  out  0x04, r17   ;init portb for output
  out  0x05, r18

ret
lightoff:
  Ldi r17, 0xff  
  ldi r18,  0x00  
  out  0x04, r17   ;init portb for output
  out  0x05, r18

ret


Motor:



Roateforward:
      ldi   r24, 0b11011000   ; all motors 1 direction
      call  sendMotorByte
      sbi   PORTB, BOARDLED       ; turn on arduino board LED
      ret

rotatebackward:
      ldi   r24, 0b00100111   ; then all motors opposite dir
      call  sendMotorByte
      cbi   PORTB, BOARDLED       ; turn off arduino board LED
      ret
Stoprotation:    
     ldi   r24, 0b00000000
     call  sendMotorByte
     ret
  
MotorBitCode:
#  1 bit transmission
motorOneBit:
      cbi   PORTD, MOTCLOCK    ; set clock low
      call  delay1          ; leave clock high long enough
      sbi   PORTB, MOTDATA   ; set data bit high (this causes the transition)
      sbi   PORTD, MOTCLOCK   ; set clock high
      call  delay1       ; keep clock high for a while
      cbi   PORTD, MOTCLOCK   ; set clock low
      call  delay1       ; keep clock high for a while
      ret

# 0 bit transmission
motorZeroBit:
      cbi   PORTD, MOTCLOCK    ; set clock low
      call  delay1       ; leave clock high long enough
      cbi   PORTB, MOTDATA    ; set data bit high (this causes the transition)
      sbi   PORTD, MOTCLOCK   ; set clock high
      call  delay1       ; leave clock high long enough
      cbi   PORTD, MOTCLOCK   ; set clock low
      call  delay1       ; keep clock high for a while
      ret     

#
# latch now should be enabled (one) in order to release 
# the control pattern to the motor driver chips 
#
latchData:
      sbi   PORTB,MOTLATCH
      call  delay1
      ; make sure PWM outputs are on
      sbi   PORTB, M1ENABLE
      sbi   PORTD, M2ENABLE
      sbi   PORTD, M3ENABLE
      sbi   PORTD, M4ENABLE
      ret

# latch should be zero in order to send the control 
# pattern to shift register    
latchReset: 
      cbi   PORTB,MOTLATCH
      call  delay1
      ret

sendMotorByte:
      push  r15
      push  r16
      mov   r15, r24
      call  latchReset
      ldi   r16, 8
smbloop:
      lsl   r15
      brcs  smbone
      call  motorZeroBit   
      rjmp  smbdone
smbone:
      call  motorOneBit
smbdone:
      dec   r16
      brne  smbloop
      call  latchData
      call  latchReset
      pop   r16
      pop   r15
      ret
     
