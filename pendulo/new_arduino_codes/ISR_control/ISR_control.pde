/*P=0.6kcr
    I=0.5Pcr
    D=0.125Pcr*/
#include<stdio.h>
#include<avr/io.h>
#include <avr/interrupt.h>
#include <LiquidCrystal.h>
LiquidCrystal lcd(48, 49, 45, 44, 43, 42);
int A_2=18;
int B_2=19;
int A_1=20;
int B_1=21;
const int s=53;
volatile float count_2=0.0;
volatile float count_1=0.0;
float theta,error2,V,Int_E,Area,Der_E,lastE,alpha,error1;
const float dt=0.001024; /*sample time*/
const float kp=150.0;//75.0;//36.0;
const float ki=0.0;//14.7;//0.0710;
const float kd=0.0;//0.017;//0.01775;
const float setpoint=180.0;

ISR(TIMER2_OVF_vect)
{
  digitalWrite(22,HIGH);
  theta=count_2*(360.0/10000.0);
  alpha=count_1*(360.0/(400.0*18.5));
  error2=setpoint-theta;
  //error1=0.0-alpha;
  Area=(error2+lastE)*dt/2;
  Int_E=(Area+Int_E);
  Der_E=(lastE-error2)/dt;
  V=kp*error2+ki*Int_E+kd*Der_E;
  if(V>255.0){V=255.0;}
  lastE=error2;
  Int_E=(Area+Int_E);
  if(Int_E>255.0){Int_E=255.0;}
  if(Int_E<-255.0){Int_E=-255.0;}
  if(Der_E>255.0){Der_E=255.0;}
  if(Der_E<-255.0){Der_E=-255.0;}
  control();
  digitalWrite(22,LOW);
}
void setup()
{//Serial.begin(9600);
  pinMode(s,INPUT);
  pinMode(22,OUTPUT);
  /*channels A and B as inputs*/
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  pinMode(A_1, INPUT); 
  pinMode(B_1, INPUT);
  /*to read encoder*/
  attachInterrupt(5, doA2, CHANGE);
  attachInterrupt(4, doB2, CHANGE);
  attachInterrupt(3, doA1, CHANGE);
  attachInterrupt(2, doB1, CHANGE);
  lcd.begin(16,2);
  /*pins to H-bridge as outputs*/
  DDRH=DDRH|B00111000;//PH5=D PH4=B PH3=P
  TCCR4A|=(1<<COM4A1)|(1<<WGM40);
  TCCR4B|=(1<<CS41)|(1<<CS40);
  /*to set ISR*/
  TCCR2A=0x00;
  TCCR2B=(1<<CS22);
  TIMSK2=(1<<TOIE2);
  ASSR=0x00;  
  sei();
  message();
  
}
void loop()
{if (digitalRead(s)==HIGH)
 {
 lcd.clear();
 lcd_prints();
 } lcd.clear();
}
void control()
{/*if(digitalRead(50)==LOW)
{Int_E=0;digitalWrite(13,HIGH);}
else{digitalWrite(13,LOW);}*/
  if (digitalRead(s)==HIGH)
{     /*variable to convert pulses to mechanical degrees*/

 if (error2>0.0 && error2<=20.0)
  {
    motor_CW ();/* motor spins clockwise direction*/
  OCR4A=255.0-V;
  }
  else if (error2<0.0 && error2>=-20.0)
  {  
      motor_CCW ();/*motor spins counter-clockwise direction*/
      if(V<0)
      {V=V*(-1.0);
      OCR4A=255.0-V;
      }else
        {OCR4A=255.0-V;
        }
    }
    else if(error2==0.0){
    motorStop ();
    }
  else
  {
    motorStop ();
  }//lcd_prints(); lcd.clear();
 // serialData();
  
}else{motorStop();}
}
void doA1(){
  // look for a low-to-high on channel A
  if (digitalRead(A_1) == HIGH) { 
    // check channel B to see which way encoder is turning
    if (digitalRead(B_1) == LOW) {  
      count_1 = count_1 + 1;         // CW
    } 
    else {
      count_1 = count_1 - 1;         // CCW
    }
  }
  else   // must be a high-to-low edge on channel A                                       
  { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(B_1) == HIGH) {   
      count_1 = count_1 + 1;          // CW
    } 
    else {
      count_1 = count_1 - 1;          // CCW
    }
  }
}
void doB1(){
  // look for a low-to-high on channel B
  if (digitalRead(B_1) == HIGH) {   
   // check channel A to see which way encoder is turning
    if (digitalRead(A_1) == HIGH) {  
      count_1 = count_1 + 1;         // CW
    } 
    else {
      count_1 = count_1 - 1;         // CCW
    }
  }
  // Look for a high-to-low on channel B
  else { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(A_1) == LOW) {   
      count_1 = count_1 + 1;          // CW
    } 
    else {
      count_1 = count_1 - 1;          // CCW
    }
  }
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
  Serial.print(theta);
  Serial.print(", Output=");
  Serial.print(V);
  Serial.println();
}*/
void lcd_prints()
{
  lcd.setCursor(0,0);
  lcd.print("Int_E=");
  lcd.setCursor(0,1);
  lcd.print("theta=");
  lcd.setCursor(6, 0);
  lcd.print(Int_E);
  lcd.setCursor(6,1);
  lcd.print(theta);
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
