int s=53;

void setup()
{
  DDRH=DDRH|B00111000; /* DDRH|=(1<<PH6)|(1<<PH5); */
  TCCR4A|=(1<<COM4A1)|(1<<WGM40);
  TCCR4B|=(1<<CS41)|(1<<CS40);
  pinMode(s,INPUT);
}
void loop()
{if(digitalRead(s)==HIGH)
{
  /*for(int i=0;i<255;i++)
  {motor_CW();
  OCR4A=255-i;
  delay(50);
  }*/
  motorStop();
  delay(200);
  for(int i=255;i>0;i--)
  {motor_CCW();
  OCR4A=255-i;
  delay(50);}
}else{motorStop();}
}
void motor_CCW()
{
	PORTH=B00010000;
}
void motor_CW()
{
	PORTH=B00110000;
}
void motorStop()
{
	PORTH=B00101000;
}
