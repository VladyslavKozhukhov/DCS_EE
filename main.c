#include  <msp430xG46x.h>
char menu[271] ="Menu \n\r 1. Blink RGB LED, color by color with delay of X[ms] \n\r 2. RLC 16 LEDs with delay of X[ms] \n\r 3. RRC 16 LEDs with delay of X[ms] \n\r 4. Get delay time X[ms]: \n\r 5. LAB2 task  part1 \n\r 6. LAB2 task  part2 \n\r 7. Clear all LEDs \n\r 8. Sleep\n\r\0";
void printMenu();
int Xms = 500;
void wait(int ms);
char selection = '0';
int flagNewX = 0;
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
      
      break;
     case '6' :
      
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
