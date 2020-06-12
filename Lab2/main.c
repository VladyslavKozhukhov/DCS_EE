#include  <msp430xG46x.h>
unsigned int ADCResult = 0;
int counter = 0;
void main(void)
{
  WDTCTL = WDTPW+WDTHOLD;                   // Stop WDT
  FLL_CTL0 |= XCAP14PF;                     // Configure load caps
// Configure PBs
  P1DIR &= ~(BIT4+BIT5+BIT6);          		// P1.4-P1.6 input
  P1IE  |= (BIT4+BIT5+BIT6);           		// P1.4-P1.6 Interrupt enabled
  P1IES |= (BIT4+BIT5+BIT6);           		// P1.4-P1.6 hi/low edge
  P1IFG &= ~(BIT4+BIT5+BIT6);          		// P1.4-P1.6 IFG Cleared
  
  P3SEL |= BIT4;                           // P3 option select
  P3DIR |= BIT4;                           // P3 outputs

  // Configure LEDs
  PBDIR = 0xffff;                           // PB output - P9-LEDs_A, P10-LEDs_B
  //********************************

  
  // Configure P6.3 as TB2 (Input capture)
  P2SEL &= ~BIT3;                            
  P2DIR &= ~BIT3;       // P2.3/TB2 Input Capture 
  P2IES &= ~BIT3; 

  P2IFG &= ~BIT3; 
  
    FLL_CTL0 |= DCOPLUS + XCAP18PF;           // DCO+ set, freq = xtal x D x N+1
    SCFI0 |= FN_4;                            // x2 DCO freq, 8MHz nominal DCO
    SCFQCTL = 121;                            // (121+1) x 32768 x 2 = 7.99 MHz
  
    TACTL = TASSEL_2 + MC_1;        // TA0 CTL = 1011 01000
    
    CCR0 = 32768;                        // CYCLES PER  1 SEC(CLOCK)
  //********************************
  
  TBCCTL3 = OUTMOD_7;
  TBCTL = TBSSEL_2+MC_1;
  
  P6SEL |= BIT3;
  ADC12CTL1 = SHP + CONSEQ_3; 
  ADC12CTL0 = SHT0_8 + MSC + ADC12ON;
  ADC12IE = 0x08;
  ADC12MCTL3 = INCH_3;
  ADC12CTL0 |= ENC;                       // Enable conversions
  
  _BIS_SR(LPM0_bits + GIE);                 // CPU off
}

#pragma vector=PORT1_VECTOR
__interrupt void Port1_ISR (void)
{
  ADC12CTL0 &= ~ADC12SC;
  CCTL0 &= ~CCIE;                        // TA0 CCTL0
    P2IE &= ~BIT3;
    PBOUT = 0;
    
  if ((P1IFG & BIT4)) {                       //P1.4 interruped
        TAR = 0;
        TACTL |= TAIE;
        CCTL0 = CCIE;                        // TA0 CCTL0
        P2IE |= BIT3;
        P1IFG &= ~BIT4;                           // P1.4 IFG Cleared
  }

 if (P1IFG & BIT5) {                    //P1.5 interruped
     
     ADC12CTL0 |= ADC12SC;                   // Start conversions
	
    P1IFG &= ~BIT5;                           // P1.5 IFG Cleared
  }
}

#pragma vector = ADC12_VECTOR
__interrupt void ADC12_ISR(void)
{
  if (ADC12MEM3 > ADCResult){               	// current sample is grater then before v'in > 1 => P3.4 = 1KHz
    TBCCR0 = 1024-1;                           // Set the period in the Timer B0 Capture/Compare 0 register to 4000 us = 4KHz.
    TBCCR3 = TBCCR0/2;				//The period in microseconds that the power is ON. It translates to a 50% duty cycle.
    counter++;
  }
  else if (ADC12MEM3 < ADCResult){				// current sample is smaller then before v'in < 1 => P3.4 = 4KHz
    TBCCR0 = 256-1;                           // Set the period in the Timer B0 Capture/Compare 0 register to 4000 us = 4KHz.
    TBCCR3 = TBCCR0/2;							//The period in microseconds that the power is ON. It translates to a 50% duty cycle.
  }
  else									// current sample is equal to before v'in = 0 => '0' => P3.4 = 0
    P3OUT &=~BIT4;
  
  ADCResult = ADC12MEM3;					// Store current sample
  ADC12CTL0 |= ADC12SC;
}

#pragma vector=TIMERB1_VECTOR
__interrupt void Timer_B (void)
{
 // P3OUT ^= BIT4;
  /*
  ADC12IE &= ~BIT3;
  P5OUT = counter;                            // Toggle P5.1
  TBCCTL0 &= ~CCIE;                           // TBCCR0 interrupt enabled
  */
 //TBR = 0;
  TBCCTL3 &= ~CCIFG;
}

#pragma vector=TIMERA0_VECTOR
__interrupt void TIMER_A(void) 
{
  counter++;
  P2IE |= BIT3;
  //TAR=0;
}

#pragma vector=PORT2_VECTOR
__interrupt void Port2_ISR (void)
{
  long tmp = (8000000/((counter*32768)+TAR)); //8388608
  PBOUT = (long)(tmp/1000);
  TAR = 0;                             // reset timer A
  counter=0;
  P2IFG &= ~BIT3;
}
