#include  <msp430xG46x.h>

void wait(int ms);
int flag = 0;
int R5  = 0;
int R4 = 0;
void main(void)
{
  WDTCTL = WDTPW+WDTHOLD;                   // Stop WDT
  
 
  
  // Configure PBs
  P1DIR &= ~(BIT4+BIT5+BIT6);          		// P1.4-P1.6 input
  P1IE  |= (BIT4+BIT5+BIT6);           		// P1.4-P1.6 Interrupt enabled
  P1IES |= (BIT4+BIT5+BIT6);           		// P1.4-P1.6 hi/low edge
  P1IFG &= ~(BIT4+BIT5+BIT6);          		// P1.4-P1.6 IFG Cleared
  
  // Configure LEDs
  PBDIR = 0xffff;                           // PB output - P9-LEDs_A, P10-LEDs_B
  
  // Configure P2.3 as TB2 (Input capture)
  P2SEL |= BIT3;                            
  P2DIR |= ~BIT3;       // P2.3/TB2 Input Capture                   
  
  
  // Configure P3.4 as TB3 (Compare mode)
  P3SEL |= BIT4;                            
  P3DIR |= BIT4;   
  
  // Configure P6.3 as A3
  P6SEL |= BIT3;
  
  // Config capture on rising clock +MLCK+triger enable 
	TBCCTL2|=CM_1+SCS+CAP+CCIE;
	//TBCTL |=TBSSEL_1+MC_2;  //ACLK,continus mode up to 0xffff ????????????

  // MCLK = SMCLK = 8MHz - from msp430xG46x_fll_02.c
  FLL_CTL0 |= DCOPLUS + XCAP18PF;           // DCO+ set, freq = xtal x D x N+1
  SCFI0 |= FN_4;                            // x2 DCO freq, 8MHz nominal DCO
  SCFQCTL = 121;                            // (121+1) x 32768 x 2 = 7.99 MHz
  
  
  _BIS_SR(LPM4_bits + GIE);                 // LPM4, enable interrupts
  

  int h = SCFQCTL*2;
}

// Port 1 interrupt service routine
#pragma vector=PORT1_VECTOR

__interrupt void Port1_ISR (void)
{
  
//---------------------------------------------------------------
//                  PB0 - Frequancy counter
//---------------------------------------------------------------  
  
  if ((P1IFG & BIT4)) {                       //P1.4 interruped
	if(flag){
		flag = 1;
		R4 = TBCCR2;						//get current value	
		R4 = R4 - R5;						//sub between prev value and current value
		PBDIR = R4*TASSEL_2 ;				//set LEDs (DIFF * SMCLK)
	}
	else{
		flag = 0;
		R5 = TBCCR2;						//get current value	
		R5 = R5 - R4;						//sub between prev value and current value
		PBDIR = R5 * TASSEL_2 ;				//set LEDs (DIFF * SMCLK)
	}
    P1IFG &= ~BIT4;                           // P1.4 IFG Cleared
  }
  
//---------------------------------------------------------------
//                  PB1 - Derivative detector
//--------------------------------------------------------------- 
  
  else if (P1IFG & BIT5) {                    //P1.5 interruped
	/*
	
	
	*/
    P1IFG &= ~BIT5;                           // P1.5 IFG Cleared
  }
  
//---------------------------------------------------------------
//                  PB2 - Clear LEDs
//---------------------------------------------------------------
  
  else if (P1IFG & BIT6) {                    	//P1.6 interruped
	PBOUT = 0x0000;								// Clear LEDs
    P1IFG &= ~BIT6;                           	// P1.6 IFG Cleared
  }
  
}