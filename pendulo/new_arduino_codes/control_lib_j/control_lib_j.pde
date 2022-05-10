/* Rotary Inverted Pendulum PID controller
  using PID library*/

#include <PID_v1.h>
#define A_2 18
#define B_2 19
const int s=53;
double kp=1.0;
double kd=0.0;
double ki=0.0;
#define S 53/*switch (just to say to arduino that executes the program if switch is turned on)*/
volatile double count_2 = 0.0; /*variable to store encoder pulses*/
double Setpoint,Input,Output,theta;
int inByte = 0;         // incoming serial byte
    float numero=0;
PID Furuta(&Input,&Output,&Setpoint,kp,ki,kd,DIRECT);

void setup()
{ 
  Serial.begin (9600);
  /*channels A and B as inputs*/
 DDRH=DDRH|B00111000; /* DDRH|=(1<<PH6)|(1<<PH5); */
  TCCR4A|=(1<<COM4A1)|(1<<WGM40);
  TCCR4B|=(1<<CS41)|(1<<CS40);
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  pinMode(s,INPUT); 
 /*for the switch and LED*/ 
  /*to read encoder*/
  attachInterrupt(4, doA2, CHANGE);
  attachInterrupt(5, doB2, CHANGE); 
  Furuta.SetMode(AUTOMATIC);
  Furuta.SetOutputLimits(-255.0,255.0);
  Furuta.SetSampleTime(1);
  Furuta.SetControllerDirection(DIRECT);
  Setpoint=180.0;
  Serial.begin (9600); Serial.println("START READING");
}
void loop()
{if(digitalRead(S)==HIGH)
{   /*variable to convert pulses to mechanical degrees*/
   theta=count_2*(360.0/10000.0);/* 10000.0=2500*4 
                                        (2500 counts per revolution
                                        encoder resolution)*/ 
  Input = theta ;
  Furuta.Compute();

 if (Input<Setpoint)
  {
    motor_CW ();/* motor spins clockwise direction*/
  // Furuta.Compute();
OCR4A=255.0-Output;
  }
  if (Input>Setpoint)
  {  
      motor_CCW ();/*motor spins counter-clockwise direction*/
      
      if(Output<0)
      {Output=Output*(-1.0);
      OCR4A=255.0-Output;
      }else
        {OCR4A=255.0-Output;
        }
    }
  if(Input<=160.0||Input>=200.0)
  {
    motorStop ();
  } 
  serialData();
  
}else{motorStop();
kp= leer_numero()*0.1;
Furuta.SetTunings(kp,ki,kd);
}
}
float leer_numero(void){
      int in_arr[8]={0,0,0,0,0,0,0,0};
      int prod=1,numero=0,point=0,i;
      
      // Recepcion y almacenamiento de la trama serial.
      while(1){
        if (Serial.available() > 0) {
          inByte = Serial.read();
          if (inByte==0x0A){
            break;
          }else{
            in_arr[point]=inByte-0x30;
            point++;
          }
        }
      }
      
      // Conversion de ASCCI a binario.
      for(i=point-1;i>=0;i--){
        numero = numero + in_arr[i]*prod;
        prod*=10;
      }
      
      return numero;}
  
void doA2(){
  // look for a low-to-high on channel A
  if (digitalRead(A_2) == HIGH) { 
    // check channel B to see which way encoder is turning
    if (digitalRead(B_2) == LOW) {  
      count_2 = count_2 + 1;         // CW
    } 
    else {
      count_2 = count_2 - 1;         // CCW
    }
  }
  else   // must be a high-to-low edge on channel A                                       
  { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(B_2) == HIGH) {   
      count_2 = count_2 + 1;          // CW
    } 
    else {
      count_2 = count_2 - 1;          // CCW
    }
  }

}
void doB2(){
  // look for a low-to-high on channel B
  if (digitalRead(B_2) == HIGH) {   
   // check channel A to see which way encoder is turning
    if (digitalRead(A_2) == HIGH) {  
      count_2 = count_2 + 1;         // CW
    } 
    else {
      count_2 = count_2 - 1;         // CCW
    }
  }
  // Look for a high-to-low on channel B
  else { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(A_2) == LOW) {   
      count_2 = count_2 + 1;          // CW
    } 
    else {
      count_2 = count_2 - 1;          // CCW
    }
  }
}
void motor_CCW ()/* motor spins clockwise direction*/
{
	PORTH=B00110000;    //PORTH=B00001000; 
}
void motor_CW ()/*motor spins counter clockwise direction*/
{
        PORTH=B00010000;    //PORTH=B00101000;
}
void motorStop ()/*motor brakes*/
{
	PORTH=B00101000;    //PORTH=B00010000;
}
void serialData()
{
  Serial.print(" I = ");
  /*erial.print(Input);
  //Serial.print(" Output= ");
  //Serial.print(Output);
  Serial.print(" count= ");
  Serial.print(count_2);
  Serial.print(" theta = ");
  Serial.print(theta);
  Serial.print(" kp = ");
  Serial.print(kp);
  Serial.print(" ki = ");
  Serial.print(ki);
  Serial.print(" kd = ");
  Serial.print(kd);
  Serial.print(" pwm = ");
  Serial.print(Output);
  Serial.println();*/

}

 
    
    // Lee un numero de trama serial.
    
    /*int inByte = 0;         // incoming serial byte
    float numero=0;
    
    float leer_numero(void){
      int in_arr[8]={0,0,0,0,0,0,0,0};
      int prod=1,numero=0,point=0,i;
      
      // Recepcion y almacenamiento de la trama serial.
      while(1){
        if (Serial.available() > 0) {
          inByte = Serial.read();
          if (inByte==0x0A){
            break;
          }else{
            in_arr[point]=inByte-0x30;
            point++;
          }
        }
      }
      
      // Conversion de ASCCI a binario.
      for(i=point-1;i>=0;i--){
        numero = numero + in_arr[i]*prod;
        prod*=10;
      }
      
      return numero;
    }*/
    
