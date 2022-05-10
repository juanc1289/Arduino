/*Furuta Pendulum PID controller */
#include <avr/interrupt.h>
#include <avr/io.h>


const int S=10;/*switch*/
const int led1=2;
const int led2=13;
int t=0;

ISR(TIMER2_OVF_vect)
  {
    if(t%2==0){
    digitalWrite(led1,HIGH);
    }
    else{
    digitalWrite(led1,LOW);
    }
    t++;
  }
  
void setup() 
{ //TCCR4B=B00000001 ;
  //TCCR4A=B00100001;
  TCCR2B=0x06;
  TCCR2A=0x00;
  ASSR=0x00;
  TIMSK2=0x01;
  TCNT2=0X00;
  TIFR2=0x01;
  SREG=0x80;
  sei();
  pinMode(led1,OUTPUT);
  pinMode(led2,OUTPUT);
}

void loop()
{  
  if(digitalRead(S)==HIGH){
  digitalWrite(led2,HIGH);
  delay(1000);
  digitalWrite(led2,LOW);
  delay(1000);
}
}


