#include <avr/interrupt.h>
float angle_2,error2,V,Int_E,Area,Der_E,lastE;
const float dt=0.001024; /*sample time*/
const float kp=100.0;
const float ki=0.0;
const float kd=0.0;
ISR(TIMER2_OVF_vect)
{
  digitalWrite(22,HIGH);
  Area=(error2+lastE)*dt/2;
  Int_E=(Area+Int_E);
  Der_E=(lastE-error2)/dt;
  lastE=error2;
  V=kp*error2+ki*Int_E+kd*Der_E;
  digitalWrite(22,LOW);
}
void setup()
{
  pinMode(22,OUTPUT);
   TCCR2B=0x04;
   TCCR2A=0x00;
   ASSR=0x00;
  TIMSK2=0x01;
  TCNT2=0x00;  
  sei();
}
void loop()
{}
