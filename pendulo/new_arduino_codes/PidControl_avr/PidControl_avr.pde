#include <avr/interrupt.h>
#include <avr/io.h>
void setup()
{ 
  DDRD=0x00;
  /*set external interrupts (0,1,2,3)*/ 
  PORTD|=B00001111;
  SREG|=(1<<I);
  EICRA|=(1<<ISC30)|(1<<ISC20)|(1<<ISC10)|(1<<ISC00);
  EIMSK|=(1<<INT3)|(1<<INT2)|(1<<INT1)|(1<<INT0);
  /*set PID ISR(OVF)*/
  TCCR2B|=(1<<CSS2)|(1<<CS21);
  TIMSK2|=(1<<TOIE2);
  TIFR2|=(1<<TOV2);
  Serial.begin(19200);
  Serial.println("Furuta Pendulum Control");
}
ISR(INT0_vect)
{
}
ISR(INT1_vect)
{}
ISR(INT2_vect)
{}
ISR(INT3_vect)
{}
ISR(TIMER2_OVF_vect)
{}
