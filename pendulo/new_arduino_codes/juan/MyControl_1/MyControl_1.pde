/*PROGRAM TO CONTROL A FURUTA PENDULUM*/
#include <stdio.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <LiquidCrystal.h>
LiquidCrystal lcd(48, 49, 45, 44, 43, 42);
/*encoder pins*/
int A_2=18;
int B_2=19;
int A_1=20;
int B_1=21;
const int s=53;
volatile float count_2 =0.0;
volatile float count_1=0.0;
/*PID variables*/
volatile float error2,V,Int_E,AInt_E,Area,Der_E,lastE,alpha,error1;
volatile float theta;
const float dt=0.001024; /*sample time*/
/*PID gains*/
const float kp=50;//35;//35.0;//75.0;//36.0;
const float ki=0.01;//1;//1.0;//5.6;//14.7;//0.0710;
const float kd=0.25;//1;//0.0;//0.044;//0.017;//0.01775;

float setpoint_theta=180;

ISR(TIMER2_OVF_vect)
{
  digitalWrite(22,HIGH);
  double_control ();
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
  //message();
//  Serial.begin(9600);
}
void loop()
{
 ///* 
  if (digitalRead(s)==HIGH)
 {
 lcd.clear();
 lcd_prints();
 } lcd.clear();
// Serial.print("theta= ");
// Serial.println(theta);
//*/
}
void double_control ()
{ 
  if (digitalRead(s)==HIGH)
  {  theta=count_2*(360.0/10000.0);
     alpha=count_1*(360.0/(800.0));

     theta=theta-alpha/12;

     error2=setpoint_theta-theta;
     Area=(lastE+error2)*dt/2;
     Int_E=(Area+Int_E);
     Der_E=(lastE-error2)/dt;
     
     V=kp*Abs(error2)+ki*Abs(Int_E)+kd*Abs(Der_E);
        if(V>255.0){V=255.0;}
    if (theta<180.0 && theta>=160.0)
    {  motor_CW();
       OCR4A=255.0-V;
     }
    if (theta>180.0 && theta<=200.0)
     { motor_CCW();
       OCR4A=255.0-V;
       }
    if (theta<160 || theta >200){
      motorStop();
    }
    if (theta==180){
    motorStop();
    }
       lastE=error2;

  //    if(Int_E>255.0){Int_E=255.0;}
  //     if(Int_E<-255.0){Int_E=-255.0;}
  
  }else{
    motorStop();
    Int_E=0;
}
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
void lcd_prints()
{
  lcd.setCursor(0,0);
  lcd.print("alpha");
  lcd.setCursor(0,1);
  lcd.print("theta=");
  lcd.setCursor(6, 0);
  lcd.print(alpha);
  lcd.setCursor(6,1);
  lcd.print(theta);
  lcd.setCursor(13,1);
  lcd.print(setpoint_theta);
  delay(150);
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

float Abs(float x){
if(x<0){
x=-x;
}
return x;
}

