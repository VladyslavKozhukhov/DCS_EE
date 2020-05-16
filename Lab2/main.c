#include  <msp430xG46x.h>

void wait(int ms);

void main(void)
{
  WDTCTL = WDTPW+WDTHOLD;                   // Stop WDT
  
  // Configure PBs
  P1DIR &= ~(BIT0+BIT1+BIT2);          		// P1.0-P1.3 input
  P1IE  |= (BIT0+BIT1+BIT2);           		// P1.0-P1.3 Interrupt enabled
  P1IES |= (BIT0+BIT1+BIT2);           		// P1.0-P1.3 hi/low edge
  P1IFG &= ~(BIT0+BIT1+BIT2);          		// P1.0-P1.3 IFG Cleared
  
  // Configure LEDs
  PBDIR = 0xffff;                           // PB output - P9-LEDs_A, P10-LEDs_B
  
  // Configure P2.3 as TB2 (Input capture)
  /*
  
  */
  
  // Configure P3.4 as TB3 (Compare mode)
  /*
  
  */
  
  // Configure P6.3 as A3
  P6SEL |= BIT3;
  
  
  // MCLK = SMCLK = 8MHz - from msp430xG46x_fll_02.c
  FLL_CTL0 |= DCOPLUS + XCAP18PF;           // DCO+ set, freq = xtal x D x N+1
  SCFI0 |= FN_4;                            // x2 DCO freq, 8MHz nominal DCO
  SCFQCTL = 121;                            // (121+1) x 32768 x 2 = 7.99 MHz
  
  
  _BIS_SR(LPM4_bits + GIE);                 // LPM4, enable interrupts
}

// Port 1 interrupt service routine
#pragma vector=PORT1_VECTOR
__interrupt void Port1_ISR (void)
{
  
//---------------------------------------------------------------
//                  PB0 - Frequancy counter
//---------------------------------------------------------------  
  
  if ((P1IFG & BIT0)) {                       //P1.0 interruped
	/*
	
	
	*/
    P1IFG &= ~BIT0;                           // P1.0 IFG Cleared
  }
  
//---------------------------------------------------------------
//                  PB1 - Derivative detector
//--------------------------------------------------------------- 
  
  else if (P1IFG & BIT1) {                    //P1.1 interruped
	/*
	
	
	*/
    P1IFG &= ~BIT1;                           // P1.1 IFG Cleared
  }
  
//---------------------------------------------------------------
//                  PB2 - Clear LEDs
//---------------------------------------------------------------
  
  else if (P1IFG & BIT2) {                    	//P1.2 interruped
	PBOUT = 0x0000;								// Clear LEDs
    P1IFG &= ~BIT2;                           	// P1.2 IFG Cleared
  }
  
}