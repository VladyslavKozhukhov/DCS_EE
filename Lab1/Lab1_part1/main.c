#include  <msp430xG46x.h> /* include peripheral declarations */
#define T 8
#define M 5 
#define max(x,y) x>y ? x : y


void f(int Mat[T][M], int matAvg[N-2][M-2]);
void FillMatrix(int Mat[T][M]);
void getMaxMatAdd(int matAvg[T-2][M-2],int* x, int* y);//,int** maxMatAddr);
//va
//-------------- Global variables ------------
  int maxTrace,maxDiag;
//--------------------------------------------
void main(){
  WDTCTL = WDTPW | WDTHOLD;     // Stop WDT
  int Mat[T][M];
  int matAvg[T-2][M-2];
  int Selector=0;
  int x,y;
  int* maxMatAdd;

  FillMatrix(Mat);



  while(1) {  	   
	   
  switch(Selector){
    case 0: 
          *maxMatAdd = 0; 
      break;  
      
    case 1: 
      f(Mat,matAvg);
      Selector = 0;
          *maxMatAdd = 0; 
      break;
    case 2: 
      f(Mat,matAvg);
      getMaxMatAdd(matAvg,&x,&y);
     maxMatAdd = &(*(*(Mat+x+1)+y+1)); 
     Selector = 0;
      break;
  }
 }	
}
//---------------------------------------------------------------
//                  Compute matAvg
//---------------------------------------------------------------
void f(int Mat[T][M], int matAvg[T-2][M-2]){
    for(int i=1 ; i<T-1 ; i++){
      for(int j=1 ; j<M-1 ; j++){
	matAvg[i-1][j-1] = (Mat[i-1][j]+Mat[i][j-1]+Mat[i][j+1]+Mat[i+1][j])/4;
	}
    }
}
//---------------------------------------------------------------
//                  computeMatAdd
//---------------------------------------------------------------
void getMaxMatAdd(int matAvg[T-2][M-2],int* x, int* y){//,int** maxMatAddr){
  int mx = 0;
      for(int i=0 ; i<T-2 ; i++){
         for(int j=0 ; j<M -2; j++){
              if(matAvg[i][j]>mx){
                  mx = matAvg[i][j];
                  *x=i;
                  *y=j;
              }
         }
      } 
 // return mx;
}

//---------------------------------------------------------------
//                  Fill Matrix
//---------------------------------------------------------------
void FillMatrix(int Mat[T][M]){
	int i,j;
	for(i=0 ; i<T ; i++){
		for(j=0 ; j<M ; j++){
                  if(i*T+j > 99){
                    Mat[i][j] = 99;
                  }
                  else{
			Mat[i][j] = i*T+j;		
		}
	} 
         
}
}
