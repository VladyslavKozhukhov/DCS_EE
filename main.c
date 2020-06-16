#include  <msp430xG46x.h>

char menu[271] ="Menu \n\r 1. Blink RGB LED, color by color with delay of X[ms] \n\r 2. RLC 16 LEDs with delay of X[ms] \n\r 3. RRC 16 LEDs with delay of X[ms] \n\r 4. Get delay time X[ms]: \n\r 5. LAB2 task  part1 \n\r 6. LAB2 task  part2 \n\r 7. Clear all LEDs \n\r 8. Sleep\n\r\0";
void printMenu();
int Xms = 500;
void wait(int ms);
char selection = '0';
int flagNewX = 0;
unsigned int ADCResult = 0;
int counter = 0;
void config();
void main(void)
{
  volatile unsigned int i;

  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
  FLL_CTL0 |= XCAP14PF;                     // Configure load caps

  do
  {
  IFG1 &= ~OFIFG;                           // Clear OSCFault flag
  for (i = 0x47FF; i > 0; i--);             // Time for flag to set
  }
  while ((IFG1 & OFIFG));                   // OSCFault flag still set?

  P1SEL &= ~BIT4;                           // IO
  P1DIR &= ~BIT4;                           // Input
  P1IES &= ~BIT4;                           // interrupt rising edge
  P1IE |= BIT4;                             // P1.4 Interrupt enable
  
  PBDIR = 0xffff;
  P3DIR |=BIT0+BIT1+BIT2;                    //OUTPUT
    
  
  P4SEL |= 0x03;                            // P4.1,0 = USART1 TXD/RXD
  ME2 |= UTXE1 + URXE1;                     // Enable USART1 TXD/RXD
  U1CTL |= CHAR;                            // 8-bit character
  U1TCTL |= SSEL0;                          // UCLK = ACLK
  U1BR0 = 0x03;                             // 32k/9600 - 3.41
  U1BR1 = 0x00;                             //
  U1MCTL = 0x4A;                            // Modulation
  U1CTL &= ~SWRST;                          // Initialize USART state machine
 //E2 |=UTXIE1;                            // Enable USART1 RX interrupt
// URXIE1+
  config();
  _BIS_SR(LPM3_bits + GIE);                 // Enter LPM3 w/ interrupt
}

#pragma vector=USART1RX_VECTOR
__interrupt void USART1_rx (void)
{ 

  if(!flagNewX){
      while (!(IFG2 & UTXIFG1));                // USART1 TX buffer ready?
      selection = RXBUF1;                          // RXBUF1 to TXBUF1
    switch(selection){
    case '1' :
        wait(Xms);
        P3OUT = 1;
        for(int j=0;j<3;j++){
          wait(Xms);
          P3OUT = P3OUT<<1;                       // shift left
        }
        P3OUT = 0;
      break;
     case '2' :
        PBOUT = 1;
        for(int j=0;j<16;j++){
          wait(Xms);
          PBOUT = PBOUT<<1;                       // shift left
        }
      break;
     case '3' :
        PBOUT = 0x8000;
        for(int j=0;j<16;j++){
          wait(Xms);
          PBOUT = PBOUT>>1;                       // shift left
        }
      break;
     case '4' :
      flagNewX = 1;
       IE2 |= URXIE1;
       Xms = 0;
             break;

     case '5' :
        ADC12CTL0 &= ~ADC12SC;
        CCTL0 &= ~CCIE;                        // TA0 CCTL0
        P2IE &= ~BIT3;
        PBOUT = 0;
        TAR = 0;
        TACTL |= TAIE;
        CCTL0 = CCIE;                        // TA0 CCTL0
        P2IE |= BIT3;
        P1IFG &= ~BIT4;                           // P1.4 IFG Cleared
        break;
     case '6' :
        ADC12CTL0 &= ~ADC12SC;
        CCTL0 &= ~CCIE;                        // TA0 CCTL0
        P2IE &= ~BIT3;
        PBOUT = 0;
        ADC12CTL0 |= ADC12SC;                   // Start conversions
        break;
     case '7' :
      
      break;
     case '8' :
      
      break;
   
    }
  }
    else{
      while (!(IFG2 & UTXIFG1));
      if (RXBUF1==0x0D)
        flagNewX = 0;
      else if (RXBUF1>='0' && RXBUF1<='9')
        Xms = Xms*10 + RXBUF1-'0';

    }
}
      
    
    



#pragma vector=PORT1_VECTOR
__interrupt void Port1_ISR (void)
{
  if (P1IFG & BIT4){
    IE2 &= ~UTXIE1;
    printMenu();
    IE2 |= URXIE1;                            // Enable USART1 RX interrupt
    P1IFG &= ~BIT4;
  }
}

void printMenu(){
  IE2 |= UTXIE1;
  for(int i =0; i<269;++i){
     while (!(IFG2 & UTXIFG1));
     TXBUF1 = menu[i];
  }
  IE2 &= ~UTXIE1;
}
/*
#pragma vector=USART1TX_VECTOR
__interrupt void USART1_tx (void)
{
  while (!(IFG2 & UTXIFG1));                // USART1 TX buffer ready?
  //TXBUF1 = RXBUF1;                          // RXBUF1 to TXBUF1
}
*/
void wait(int ms) {
  for(int i=0; i<ms; i++)
    for(int j=0; j<256; j++);     
}

void config()
{

  P3SEL |= BIT4;                           // P3 option select
  P3DIR |= BIT4;                           // P3 outputs



  
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
/*
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
}*/

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
  PBOUT = (long)(tmp);
  TAR = 0;                             // reset timer A
  counter=0;
  P2IFG &= ~BIT3;
}
