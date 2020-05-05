#include  <msp430xG46x.h> /* include peripheral declarations */
#define N 8
#define M 5 
#define max(x,y) x>y ? x : y


void f(int Mat[N][M], int matAvg[N-2][M-2]);
void FillMatrix(int Mat[N][M]);
int computemaxMatAdd(int matAvg[N-2][M-2]);
//va
//-------------- Global variables ------------
  int maxTrace,maxDiag;
//--------------------------------------------
void main(){
  WDTCTL = WDTPW | WDTHOLD;     // Stop WDT
  int Mat[N][M];
  int maxMatAdd = 0;
  int matAvg[N-2][M-2];
  int Selector=0;
  
  FillMatrix(Mat);
  
  while(1) {  	   
	   
  switch(Selector){
    case 0: 
      break;     
    case 1: 
      f(Mat,matAvg);
      Selector = 0;
      break;
    case 2: 
      f(Mat,matAvg);
      maxMatAdd = computemaxMatAdd(matAvg);
      Selector = 0;
      break;
  }
 }	
}
//---------------------------------------------------------------
//                  Compute matAvg
//---------------------------------------------------------------
void f(int Mat[N][M], int matAvg[N-2][M-2]){
    for(int i=1 ; i<N-1 ; i++){
      for(int j=1 ; j<M-1 ; j++){
	matAvg[i-1][j-1] = (Mat[i-1][j]+Mat[i][j-1]+Mat[i][j+1]+Mat[i+1][j])/4;
	}
    }
}
//---------------------------------------------------------------
//                  computeMatAdd
//---------------------------------------------------------------
int computemaxMatAdd(int matAvg[N-2][M-2]){
  int mx = 0;
      for(int i=0 ; i<N-2 ; i++){
         for(int j=0 ; j<M -2; j++){
              if(matAvg[i][j]>mx){
                  mx = matAvg[i][j];
              }
         }
      } 
  return mx;
}

//---------------------------------------------------------------
//                  Fill Matrix
//---------------------------------------------------------------
void FillMatrix(int Mat[N][M]){
	int i,j;
	for(i=0 ; i<N ; i++){
		for(j=0 ; j<M ; j++){
			Mat[i][j] = i*N+j;		
		}
	} 
         
}
