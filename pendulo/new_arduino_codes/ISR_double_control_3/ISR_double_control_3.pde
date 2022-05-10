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
volatile float count_2 = 0.0,count_1;
float theta,error2,V2,Int_E2,Area2,Der_E2,lastE2;
float alpha,error1,V1,Int_E1,Area1,Der_E1,lastE1;
const float dt=0.001024; /*sample time*/
const float kp=36.0;
const float ki=0.0710;
const float kd=0.01775;
const float kpa=50.0;
const float setpoint2=180.0;
const float setpoint1=0.0;

ISR(TIMER2_OVF_vect)
{
  digitalWrite(22,HIGH);
  theta=count_2*(360.0/10000.0);
  error2=setpoint2-theta;
  Area2=(error2+lastE2)*dt/2;
  lastE2=error2;
  Int_E2=(Area2+Int_E2);
  Der_E2=(lastE2-error2)/dt;
  V2=kp*error2+ki*Int_E2+kd*Der_E2;
  constrain((kp*error2),-255.0,255.0);
  constrain(Int_E2,-255.0,255.0);
  constrain(Der_E2,-255.0,255.0);
  constrain(V2,-255.0,255.0);
  constrain((kpa*error1),-255.0,255.0);
  control_theta();
  digitalWrite(22,LOW);
}
ISR(TIMER0_OVF_vect)
{
  alpha=count_1*(360.0/(400.0*18.5));
  error1=setpoint1-alpha;
  V1=kpa*error1;
  constrain(V1,-255.0,255.0);
  control_alpha();
}
void setup()
{//Serial.begin(9600);
  pinMode(s,INPUT);
  pinMode(2,OUTPUT);
  pinMode(22,OUTPUT);
  //pinMode(13,OUTPUT);
  //pinMode(50,INPUT);
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
  //lcd.begin(16,2);
  /*pins to H-bridge as outputs*/
  DDRH=DDRH|B00111000;//PH5=D PH4=B PH3=P
  TCCR4A|=(1<<COM4A1)|(1<<WGM40);
  TCCR4B|=(1<<CS41)|(1<<CS40);
  /*to set TIMER2*/
  TCCR2B=0x04;
  TCCR2A=0x00;
  ASSR=0x00;
  TIMSK2=0x01;
  TCNT2=0x00;
  /*to set TIMER0*/
  TCCR0A=(1<<WGM01);
  TCCR0B=(1<<CS02);
  TIMSK0=(1<<TOIE0);  
  sei();
}
void loop()
{
 //lcd_prints();
 //lcd.clear();
}
void control_theta()
{/*if(digitalRead(50)==LOW)
{Int_E=0;digitalWrite(13,HIGH);}
else{digitalWrite(13,LOW);}*/
  if (digitalRead(s)==HIGH)
{     /*variable to convert pulses to mechanical degrees*/
 // Furuta.Compute();

 if (error2>0.0 && error2<=20.0)
  {
    motor_CW ();/* motor spins clockwise direction*/
  OCR4A=255.0-V2;
  }
  else if (error2<0.0 && error2>=-20.0)
  {  
      motor_CCW ();/*motor spins counter-clockwise direction*/
      if(V2<0)
      {V2=V2*(-1.0);
      OCR4A=255.0-V2;
      }else
        {OCR4A=255.0-V2;
        }
    }
    else if(error2==0.0){
    motorStop ();
    }
  else
  {
    motorStop ();
  }     
}else{motorStop();}
}
void control_alpha ()
{
  if(error1>0.0 && error1<60.0)
    {
      motor_CW();
      OCR4A=255.0-V1;
    }else if(error1<0.0 && error1>-60.0)
         {
           motor_CCW();
           if(V1<0)
           {V1=(-1)*V1;
            OCR4A=255.0-V1;
           }
           else{OCR4A=255.0-V1;}
         } else{motorStop();}
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
  lcd.print("P2=");
  lcd.setCursor(0,1);
  lcd.print("V =");
  lcd.setCursor(9,0);
  lcd.print("P1=");
  lcd.setCursor(9,1);
  lcd.print("E1=");
  lcd.setCursor(3, 0);
  lcd.print(theta);
  lcd.setCursor(3,1);
  lcd.print(OCR4A);
  delay(10);
}
