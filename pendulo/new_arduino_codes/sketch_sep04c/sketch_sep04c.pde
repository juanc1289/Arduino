#include <PID_v1.h>
#include <stdio.h>
int A_2=18; /*encoder channel A*/
int B_2=19;/*encoder channel B*/

#define s 53/*switch (just to say to arduino 
              that execute the program if switch is turned on)*/
volatile double count_2 = 0.0; /*variable to store encoder pulses*/
double Input,Output;
double Setpoint=180.0;
double Kp=12.5;
double Ki=0.0;
double Kd=0.0;
PID Furuta(&Input,&Output,&Setpoint,Kp,Ki,Kd,DIRECT);
void setup()
{Serial.begin (9600);
  /*channels A and B as inputs*/
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  /*pins to H-bridge as outputs*/
  DDRH=DDRH|B00111000;//PH5,PH4,PH3
  TCCR4A|=(1<<COM4A1)|(1<<WGM40);
  TCCR4B|=(1<<CS41)|(1<<CS40);
 /*for the switch and LED*/ 
  pinMode(s,INPUT);
  /*to read encoder*/
  attachInterrupt(5, doA2, CHANGE);
  attachInterrupt(4, doB2, CHANGE);  
  Furuta.SetMode(AUTOMATIC);
  Furuta.SetOutputLimits(-255.0,255.0);
  Furuta.SetSampleTime(1);
  Furuta.SetControllerDirection(DIRECT);  
  Serial.println("START READING");}
void loop()
{Input=count_2*(360.0/10000.0);
  if(digitalRead(s)==HIGH)
{if((Input<=160.0)||(Input>=200.0))
{motorStop();
}if(Input<Setpoint)
{motor_CW();
OCR4A=255.0-Output;
}
if (Input>Setpoint)
  {  
      /*motor spins counter-clockwise direction*/
    if(Output<0)
      {motor_CCW ();
       Output=Output*(-1.0);
       OCR4A=255.0-Output;
   }else{
         motor_CCW();
         OCR4A=Output*(-1.0);
        }
  }
}else{motorStop();}
serialData();
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
void motor_CCW ()/* motor spins clockwise direction*/
{
  PORTH=0x10; //B00010000;
}
void motor_CW ()/*motor spins counter clockwise direction*/
{
  PORTH=0x30; //B00110000;
}
void motorStop ()/*motor brakes*/
{
  PORTH=0x28; //B00101000;
}
void serialData()
{
  Serial.print("IN = ");
  Serial.print(Input);
  Serial.print(", OUT=");
  Serial.print(Output);
  Serial.print(", kp=");
  Serial.print(Kp);
  Serial.print(", Ki=");
  Serial.print(Ki);
  Serial.print(", Kd=");
  Serial.print(Kd);
  Serial.print(", OCR4A=");
  Serial.print(OCR4A);
  Serial.println();
}

