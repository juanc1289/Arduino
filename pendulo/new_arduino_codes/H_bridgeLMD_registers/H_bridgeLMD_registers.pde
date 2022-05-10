
/*PH5=dir pin*/
/*PH4=brake pin*/
/*PH3=pwm pin*/

#include <stdio.h>
int s=53;
int i=255;

void setup()
{
	
	DDRH=DDRH|B00111000; /* DDRH|=(1<<PH6)|(1<<PH5); */
	pinMode(s,INPUT);
	TCCR4A|=(1<<COM4A1)|(1<<WGM40);
	TCCR4B|=(1<<CS41)|(1<<CS40);
}

void loop()
{
  if(digitalRead(s)==HIGH)
  {
	motor_CCW();
delay(250);
	motorStop();
delay(100);
	motor_CW();
delay(250);
	motorStop();
delay(100);
}
  else  {motorStop();
        }
}
void motor_CCW()
{
	PORTH=B00101000;
	OCR4A=i;
}
void motor_CW()
{
	PORTH=B00001000;
	OCR4A=i;
}
void motorStop()
{
	PORTH=B00010000;
}
