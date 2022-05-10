/* Rotary Inverted Pendulum PID controller
  using PID library*/
  /*P=0.6kcr
    I=0.5Pcr
    D=0.125Pcr*/

#include <PID_v1.h>
#include <stdio.h>
#include <LiquidCrystal.h>
LiquidCrystal lcd(48, 49, 45, 44, 43, 42);
int A_2=18; /*encoder channel A*/
int B_2=19;/*encoder channel B*/
#define s 53/*switch (just to say to arduino 
            that execute the program if switch is turned on)*/
volatile double count_2 = 0.0; /*variable to store encoder pulses*/
double Input,Output;
double Setpoint=180.0;
PID Furuta(&Input,&Output,&Setpoint,60.0,0.0,0.0,DIRECT);

void setup()
{//Serial.begin (9600);
  /*channels A and B as inputs*/
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  //pinMode(13,OUTPUT);
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
  //Setpoint=180.0;
  lcd.begin(16,2);
  message();
 //Serial.println("START READING");
}
void loop()
{if (digitalRead(s)==HIGH)
{     /*variable to convert pulses to mechanical degrees*/
   Input= count_2*(360.0/10000.0);/* 10000.0=2500*4 
                                        (2500 counts per revolution
                                        encoder resolution)*/ 
 //Furuta.Compute();

 if (Input<Setpoint && Input>=160.0)
  {
    Furuta.Compute();
    motor_CW ();/* motor spins clockwise direction*/
  //
OCR4A=255.0-Output;
  }
  else if (Input>Setpoint && Input<=200.0)
  {  //digitalWrite(13,HIGH);
    Furuta.Compute();
    //digitalWrite(13,LOW);
      motor_CCW ();/*motor spins counter-clockwise direction*/
      
      if(Output<0)
      {Output=Output*(-1.0);
      OCR4A=255.0-Output;
      }else
        {OCR4A=255.0-Output;
        }
    }
    else if(Input==Setpoint){
    motorStop ();
    }
  else
  {
    motorStop ();
  }lcd.clear();lcd_prints();
  //serialData();
  
}else{motorStop();lcd.clear();}
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
	PORTH=0x10;
}
void motor_CW()
{
	PORTH=0x30;
}
void motorStop()
{
	PORTH=0x28;
}
/*void serialData()
{
  Serial.print("count2=");
  Serial.print(count_2);
  Serial.print(", Input = ");
  Serial.print(Input);
  Serial.print(", Output=");
  Serial.print(Output);
  Serial.println();
}*/
void lcd_prints()
{
  lcd.setCursor(0,0);
  lcd.print("Vout=");
  lcd.setCursor(0,1);
  lcd.print("theta=");
  lcd.setCursor(6, 0);
  lcd.print(Output);
  lcd.setCursor(6,1);
  lcd.print(Input);
  delay(100);
}
void message()
{
  lcd.setCursor(2,0);
  lcd.print("WELLCOME TO");
  delay(1500);
  lcd.clear();
  lcd.setCursor(1,1);
  lcd.print("CONTROL LAB OF");
  delay(1500);
  lcd.clear();
  lcd.setCursor(1,0);
  lcd.print("FURUTA PENDULUM");
  delay(1500);
  
}
