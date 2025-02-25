#include "msp430xG46x.h"
#include <stdint.h>
#include <stdio.h>

char menu[] ="Menu\r\n1. Calculated Temperature\r\n2. Read the measured Temperature, Counter, Slope\r\n3. Sleep\r\n\0";
void wait(int ms);
void printStr();
void initUart();
void Button();
unsigned char *PTxData;  // Pointer to TX data
unsigned char *PRxData;// Pointer to RX data
unsigned char TXByteCtr,RxByteCtr, ConReg,WRITE=1;
unsigned int delay=0;
unsigned char TxData[] ={0xAC};              // Table of data to transmit
//uint8_t *PTxData;                     // Pointer to TX data
//uint8_t *PRxData;                     // Pointer to RX data
int selection =0;
unsigned char send_init[] = {0xAC,0x02,0xEE};
unsigned char send_AA_temp[] = {0xAA};
unsigned char send_A9_slope[] = {0xA9};
unsigned char send_A8_counter[] = {0xA8};
unsigned char buffer_1byte[1] ;
unsigned char buffer_2byte[2] ;
unsigned char send_TH[] = {0xAC,0x02,0xA1,0x28,0x00,0xA2,0x0A,0x00,0xEE};
unsigned char send_TL[] = {0xA2,0x0A,0x00};
unsigned char params[4];
void ReadAllParam();

uint8_t TxByteCtr;
uint8_t RxByteCtr;
void initI2C();
void I2C_write(uint8_t ByteCtr, uint8_t *TxDat);
void I2C_read(uint8_t ByteCtr, unsigned char *RxDat);

void main(void)
{
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
  FLL_CTL0 |= DCOPLUS + XCAP18PF;           // DCO+ set, freq = xtal x D x N+1
  SCFI0 |= FN_4;                            // x2 DCO freq, 8MHz nominal DCO
  SCFQCTL = 121;  
  initI2C();
 // IE2 |= UCB0TXIE + UCB0RXIE;                           // Enable TX interrupt
  Button();
  initUart();

  /*while (1)
  {
    if(WRITE){
       IE2 |= UCB0TXIE;
       UCB0CTL1 |= UCTR + UCTXSTT;             // I2C TX, start condition
       __bis_SR_register(CPUOFF + GIE);        // Enter LPM0 w/ interrupts
    } 
    else{ 
       
       UCB0CTL1 &= ~UCTR;
       UCB0CTL1 |= UCTXSTT;
               // Enter LPM0 w/ interrupts
    }
                                            // Remain in LPM0 until all data
                                            // is TX'd
    
  }*/
  
   __bis_SR_register(CPUOFF + GIE);
}
void Button(){
  P1SEL &= ~BIT4;                           // IO
  P1DIR &= ~BIT4;                           // Input
  P1IES &= ~BIT4;                           // interrupt rising edge
  P1IE |= BIT4;                             // P1.4 Interrupt enable 
  IE2 |= UTXIE1;

}
void initUart(){
  P4SEL |= 0x03;                            // P4.1,0 = USART1 TXD/RXD
  ME2 |= UTXE1 + URXE1;                     // Enable USART1 TXD/RXD
  U1CTL |= CHAR;                            // 8-bit character
  U1TCTL |= SSEL0;                          // UCLK = ACLK
  U1BR0 = 0x03;                             // 32k/9600 - 3.41
  U1BR1 = 0x00;                             //
  U1MCTL = 0x4A;                            // Modulation
  U1CTL &= ~SWRST;                          // Initialize USART state machine
}
void initI2C(){
  P3SEL |= 0x06;                            // Assign I2C pins to USCI_B0 - P3.1=SDA,P3.2=SCL
  UCB0CTL1 |= UCSWRST;                      // Enable SW reset
  UCB0CTL0 = UCMST + UCMODE_3 + UCSYNC;     // Master,I2C,synchronous mode
  UCB0CTL1 = UCSSEL_2 + UCSWRST;            // Use SMCLK, keep SW reset
  UCB0BR0 = 88;                             // fSCL = SMCLK/11 = 95.3kHz
  UCB0BR1 = 0;
  UCB0I2CSA = 0x48;                         // Slave Address is 048h
  UCB0CTL1 &= ~UCSWRST;                     // Clear SW reset, resume operation  
}


void I2C_write(uint8_t ByteCtr, unsigned char* TxDat) {
    __disable_interrupt();
    IE2 &= ~UCB0RXIE;                              // Disable RX interrupt
    IE2 |= UCB0TXIE;                               // Enable TX interrupt
    PTxData = TxDat;                               // TX array start address
    TxByteCtr = ByteCtr;                           // Load TX byte counter
    UCB0CTL1 |= UCTR + UCTXSTT;                    // I2C TX, start condition
    __bis_SR_register(CPUOFF + GIE);               // Enter LPM0 w/ interrupts
    while (UCB0CTL1 & UCTXSTP);
}
void I2C_read(uint8_t ByteCtr, unsigned char *RxDat) {
    __disable_interrupt();
    IE2 &= ~UCB0TXIE;                              // Disable TX interrupt
    UCB0CTL1 = UCSSEL_2 + UCSWRST;                 // Use SMCLK, keep SW reset
    UCB0CTL1 &= ~UCSWRST;                          // Clear SW reset, resume operation
    IE2 |= UCB0RXIE;                               // Enable RX interrupt
    PRxData =  RxDat;                              // Start of RX buffer
    RxByteCtr = ByteCtr;                           // Load RX byte counter
    if(RxByteCtr == 1){
        UCB0CTL1 |= UCTXSTT;                       // I2C start condition
        while (UCB0CTL1 & UCTXSTT);                // Start condition sent?
        UCB0CTL1 |= UCTXSTP;                       // I2C stop condition
        __enable_interrupt();
    } else {
        UCB0CTL1 |= UCTXSTT;                       // I2C start condition
    }

    __bis_SR_register(CPUOFF + GIE);               // Enter LPM0 w/ interrupts
    while (UCB0CTL1 & UCTXSTP);                    // Ensure stop condition got sent
}

//------------------------------------------------------------------------------
#pragma vector = USCIAB0TX_VECTOR
__interrupt void USCIAB0TX_ISR(void)
{
  if(IFG2 & UCB0RXIFG){                              // Receive In
  if (RxByteCtr == 1)
  {
     *PRxData = UCB0RXBUF;                           // Move final RX data to PRxData
     __bic_SR_register_on_exit(CPUOFF);              // Exit LPM0
  }
  else
  {
      *PRxData++ = UCB0RXBUF;                        // Move RX data to address PRxData
      if (RxByteCtr == 2)                            // Check whether byte is second to last to be read to send stop condition
      UCB0CTL1 |= UCTXSTP;
      __no_operation();
  }
  RxByteCtr--;                                       // Decrement RX byte counter
  }

  else{                                              // Master Transmit
      if (TxByteCtr)                                 // Check TX byte counter
  {
    UCB0TXBUF = *PTxData;                            // Load TX buffer
    PTxData++;
    TxByteCtr--;                                     // Decrement TX byte counter
  }
  else
  {
    UCB0CTL1 |= UCTXSTP;                             // I2C stop condition
    IFG2 &= ~UCB0TXIFG;                              // Clear USCI_B0 TX int flag
    __bic_SR_register_on_exit(CPUOFF);               // Exit LPM0
  }
 }
}

#pragma vector=USART1RX_VECTOR
__interrupt void USART1_rx (void)
{ 
   while (!(IFG2 & UTXIFG1));                // USART1 TX buffer ready?
   selection = RXBUF1;                          // RXBUF1 to TXBUF1
    switch(selection){
    case '1' :
      ReadAllParam();
      __disable_interrupt();
      char str_option1[13];
      sprintf(str_option1,"temp: %.2f\r\n",(double)params[0]+0.5*(double)params[1]-0.25+((double)params[3]-(double)params[2])/(double)params[3]);
      printStr(sizeof(str_option1),str_option1);
      __enable_interrupt();
      break;
     case '2' :
       ReadAllParam();
        __disable_interrupt();
      char str_option2[64];
      sprintf(str_option2,"temperatureMSB: %02d, temperatureLSB: %02d, counter: %02d, slope: %02d\r\n",params[0],params[1],params[2],params[3]);
      printStr(sizeof(str_option2),str_option2);
      __enable_interrupt();
      break;
     case '3' :
       IE2 &= ~URXIE1;
      break;
  

  }
}
#pragma vector=PORT1_VECTOR
__interrupt void Port1_ISR (void)
{
  wait(10);
  if (P1IFG & BIT4){
    IE2 &= ~URXIE1;
    printStr(sizeof(menu),menu);
    IE2 |= URXIE1;                            // Enable USART1 RX interrupt
    P1IFG &= ~BIT4;
  }
IFG2=0;
}

void printStr(int size, char* str){
  IE2 |= UTXIE1;
  for(int i =0; i<size;++i){
     while (!(IFG2 & UTXIFG1));
     TXBUF1 = str[i];
  }
  IE2 &= ~UTXIE1;
}

void wait(int ms) {
  for(int i=0; i<ms; i++)
    for(int j=0; j<1048; j++);     
}

void ReadAllParam(){
  I2C_write(2,send_TH);
  I2C_write(3,&send_TH[2]);
  I2C_write(3,&send_TH[5]);
  I2C_write(1,&send_TH[8]);
  I2C_write(1,send_AA_temp);
  I2C_read(2,params);
  I2C_write(1,send_A8_counter);
  I2C_read(1,&params[2]);
  I2C_write(1,send_A9_slope);
  I2C_read(1,&params[3]);
}
