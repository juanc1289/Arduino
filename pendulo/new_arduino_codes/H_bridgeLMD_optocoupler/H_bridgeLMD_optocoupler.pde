//H-bridge using optocouplers
/*PH5=dir pin*/
/*PH4=brake pin*/
/*PH3=pwm pin*/

#include <stdio.h>
int s=53;
int i=80;

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
        delay(500);
        motorStop();
        delay(1000);
        motor_CW();
        delay(500);
        motorStop();
        delay(1000);
}
  else  {motorStop();
        }
}
void motor_CCW()
{
	PORTH=0x10;//B00010000;
	OCR4A=255-i;
}
void motor_CW()
{
	PORTH=0x30;//B00110000;
	OCR4A=255-i;
}
void motorStop()
{
	PORTH=0x28;//B00101000;
}
