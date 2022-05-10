/* Rotary Inverted Pendulum PID controller
  using PID library*/

#include <PID_v1.h>
#include <stdio.h>
#include <LiquidCrystal.h>
LiquidCrystal lcd(46, 47, 45, 44, 43, 42);
int A_2=18; /*encoder channel A*/
int B_2=19;/*encoder channel B*/
#define s 53/*switch (just to say to arduino 
              that execute the program if switch is turned on)*/
volatile double count_2 = 0.0; /*variable to store encoder pulses*/
double Setpoint,Input,Output,theta;
PID Furuta(&Input,&Output,&Setpoint,8.0,0.0,0.0,DIRECT);

void setup()
{ Serial.begin (9600);
  /*channels A and B as inputs*/
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  /*pins to H-bridge as outputs*/
  DDRH=DDRH|B00111000;//PH5=D PH4=B PH3=P
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
  Setpoint=180.0;
  lcd.begin(16,2);
 //Serial.println("START READING");
}
void loop()
{
  if(digitalRead(s)==HIGH)
    {
      theta=count_2*(360.0/10000.0);
      Input = theta ;
      Furuta.Compute();
    if(Input==Setpoint)
   {motorStop();
   }
  else if((Input<160.0)||(Input>200.0))
   {motorStop();
   } 
  else if((Input>160.0)||(Input<Setpoint))
    {
      motor_CW();
      OCR4A=Output;
    }
   else if((Input>Setpoint)||(Input<200.0))
     {
       if(Output<0.0)
       {
         Output=Output*(-1);
         motor_CCW();
         OCR4A=Output;
       }
       motor_CCW();
       OCR4A=Output;
     }
      lcd_prints(); lcd.clear();
    /*serialData();*/ }
  else  {motorStop();}
 
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
	PORTH=B00101000;
}
void motor_CW()
{
	PORTH=B00001000;
}
void motorStop()
{
	PORTH=B00010000;
}
/*void serialData()
{
  Serial.print(" Input = ");
  Serial.print(Input);
  Serial.print(", Output=");
  Serial.print(Output);
  Serial.println();
}*/
void lcd_prints()
{
  lcd.setCursor(0,0);
  lcd.print("P2=");
  lcd.setCursor(0,1);
  lcd.print("V =");
  lcd.setCursor(9,0);
  lcd.print("P1=");
  lcd.setCursor(9,1);
  lcd.print("E1=");
  lcd.setCursor(3, 0);
  lcd.print(int(Input));
  lcd.setCursor(3,1);
  lcd.print(int(Output));
  delay(10);
}
