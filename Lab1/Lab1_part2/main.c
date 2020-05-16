#include  <msp430xG46x.h>

void wait(int ms);

void main(void)
{
  WDTCTL = WDTPW+WDTHOLD;                   // Stop WDT
  P2DIR &= ~(BIT0+BIT1+BIT2+BIT3);          // P2.0-P2.3 input
  P2IE  |= (BIT0+BIT1+BIT2+BIT3);           // P2.0-P2.3 Interrupt enabled
  P2IES |= (BIT0+BIT1+BIT2+BIT3);           // P2.0-P2.3 hi/low edge
  P2IFG &= ~(BIT0+BIT1+BIT2+BIT3);          // P2.0-P2.3 IFG Cleared
  PBDIR = 0xffff;                           // PB output - P9-LEDs_A, P10-LEDs_B
  
  _BIS_SR(LPM4_bits + GIE);                 // LPM4, enable interrupts
}

// Port 2 interrupt service routine
#pragma vector=PORT2_VECTOR
__interrupt void Port2_ISR (void)
{
  int i, j;
  
//---------------------------------------------------------------
//                  PB0 - Counter LEDs
//---------------------------------------------------------------  
  
  if ((P2IFG & BIT0)) {                       //P2.0 interruped
    for(i=0;i<20;i++){
      PBOUT++;
      wait(500);
    }
    P2IFG &= ~BIT0;                           // P2.0 IFG Cleared
  }
  
//---------------------------------------------------------------
//                  PB1 - Shift left LEDs
//--------------------------------------------------------------- 
  
  else if (P2IFG & BIT1) {                    //P2.1 interruped
    for(i=0;i<5;i++){
      PBOUT=0;
      wait(500);
      PBOUT = 1;
      for(j=0;j<16;j++){
      wait(500);
      PBOUT = PBOUT<<1;                       // shift left
      }
      wait(500);
    }
    P2IFG &= ~BIT1;                           // P2.1 IFG Cleared
  }
  
//---------------------------------------------------------------
//                  PB2 - Shift left + +1 LEDs
//---------------------------------------------------------------
  
  else if (P2IFG & BIT2) {                    //P2.2 interruped
    for(i=0;i<5;i++){
      PBOUT =0;
      for(j=0;j<=16;j++){
        wait(500);
        PBOUT = (PBOUT<<1) + 1;               // shift left, add 1
      }
    }
    P2IFG &= ~BIT2;                           // P2.2 IFG Cleared
  }
  
//---------------------------------------------------------------
//                  PB3 - Reset LEDs
//---------------------------------------------------------------
  
   if (P2IFG & BIT3) {                        //P2.3 interruped
    PBOUT = 0;                                // Reset LEDs
    P2IFG &= ~BIT3;                           // P2.3 IFG Cleared
  }
  
}


//---------------------------------------------------------------
//                  Wait function
//---------------------------------------------------------------
void wait(int ms) {
  for(int i=0; i<ms; i++)
    for(int j=0; j<1048; j++);     
}
