#include  <msp430xG46x.h>

void wait(int ms);
int flag = 0;
int R5  = 0;
int R4 = 0;
void main(void)

unsigned int ADCResult = 0;

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
  TB0CCTL1 = OUTMOD_7;  
  TB0CTL = TBSSEL_2 + MC_1;	//TBSSEL_2 selects SMCLK as the clock source, and MC_1 tells it to count up to the value in TB0CCR0.
  
  
  // Configure ADC12
  P6SEL |= 0x08;		// Configure P6.3 as A3
  ADC12MCTL3 = INCH_3; 	// Analog input is A3, VR+=3.3v VR-=0v
  ADC12CTL0 = SHT0_2+ADC12ON;
  // 
  ADC12CTL1 = SHP+CSTARTADD_3+ADCSSEL1;	// Choose ACLK
  ADC12CTL0 |= ENC;
  
  
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
	
	// Not sure!
  ADC12CTL0 &= ~ADC12SC;					// Disable ADC12 sampling/conversion
  
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
  // Recommended sampling frequency is 2*max(fin) = 100Hz according to Nyquist.
  /* TODO:
	 if we choose aclk, divide by 8 => cycle = (1/4096) sec

	conversion  = 13 + n + tsync 
	SHP = 1
	SHT = 1001 = 384 = n

	conversion time = (13 + 384 + tsync)*(1/4096) = ~0.097 sec => ~100Hz
	
  */
  else if (P1IFG & BIT5) {                    //P1.5 interruped
  
	ADC12IE |= 0x0003;		// Enable ADC12 interrupt A3
	ADC12CTL0 |= ADC12SC; 	// Start sampling/conversion
	
	// Not sure!
	_BIS_SR(CPUOFF+GIE);	// LPM0, ADC12_ISR will force exit
	
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

#pragma vector = ADC12_VECTOR
__interrupt void ADC12_ISR(void)
{
  if (ADC12MEM3 > ADCResult){               	// current sample is grater then before v'in > 1 => P3.4 = 1KHz
    TB0CCR0 = 4000;                          // Set the period in the Timer B0 Capture/Compare 0 register to 4000 us = 4KHz.
	TB0CCR3 = 2000;							//The period in microseconds that the power is ON. It translates to a 50% duty cycle.
  }
  else (ADC12MEM3 < ADCResult){				// current sample is smaller then before v'in < 1 => P3.4 = 4KHz
    TB0CCR0 = 1000;                          // Set the period in the Timer B0 Capture/Compare 0 register to 1000 us = 1KHz.
	TB0CCR3 = 500;							//The period in microseconds that the power is ON. It translates to a 50% duty cycle.
  }
	else									// current sample is equal to before v'in = 0 => '0' => P3.4 = 0
		P3OUT &=~BIT4;
	ADCResult = ADC12MEM3;					// Store current sample
}
