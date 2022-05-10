/* Rotary Inverted Pendulum PID controller
  using PID library*/

#include <PID_v1.h>
#include <stdio.h>
int A_2=18; /*encoder channel A*/
int B_2=19;/*encoder channel B*/
#define S 53/*switch (just to say to arduino 
              that execute the program if switch is turned on)*/
volatile double count_2 = 0.0; /*variable to store encoder pulses*/
double Setpoint,Input,Output,theta;
PID Furuta(&Input,&Output,&Setpoint,10.0,0.0,0.0,DIRECT);

void setup()
{ Serial.begin (9600);
  /*channels A and B as inputs*/
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  /*pins to H-bridge as outputs*/
  DDRB=DDRB|B00100000;
	DDRH=DDRH|B01100000;
TCCR4A|=(1<<COM4C1)|(1<<WGM40);
	TCCR4B|=(1<<CS41)|(1<<CS40);
 /*for the switch and LED*/ 
  pinMode(S,INPUT);
  /*to read encoder*/
  attachInterrupt(5, doA2, CHANGE);
  attachInterrupt(4, doB2, CHANGE);  
  Furuta.SetMode(AUTOMATIC);
  Furuta.SetOutputLimits(-255.0,255.0);
  Furuta.SetSampleTime(1);
  Furuta.SetControllerDirection(DIRECT);
  Setpoint=180.0;
  Serial.println("START READING");
}
void loop()
{if(digitalRead(S)==HIGH)
{   /*variable to convert pulses to mechanical degrees*/
   theta=count_2*(360.0/10000.0);/* 10000.0=2500*4 
                                        (2500 counts per revolution
                                        encoder resolution)*/ 
  Input = theta ;
  Furuta.Compute();
  if (Input==Setpoint)
  {          
     motorStop ();
  }
  if (Input<Setpoint)
  {
    motor_CW ();/* motor spins clockwise direction*/
	OCR4C=Output;
  }
  if (Input>Setpoint)
  {  
      motor_CCW ();/*motor spins counter-clockwise direction*/
      
      if(Output<0)
      {Output=Output*(-1.0);
    	OCR4C=Output;
      }else
        {OCR4C=Output;
        }
    }
  if(Input<=160.0||Input>=200.0)
  {
    motorStop ();
  } 
  serialData();
  
}else{motorStop();}
}
  
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
void motor_CCW()
{
	PORTB=B00100000;
	PORTH=B00100000;
	
}
void motor_CW()
{
	PORTB=B00000000;
	PORTH=B00100000;
	
}
void motorStop()
{
	PORTH=B01000000;
}
void serialData()
{
  Serial.print(" Input = ");
  Serial.print(Input);
  Serial.print(", Output=");
  Serial.print(Output);
  Serial.println();
}
