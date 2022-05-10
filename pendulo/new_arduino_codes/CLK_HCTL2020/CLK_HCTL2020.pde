/*PROGRAM TO GENERATE A CLK SIGNAL TO 
  HCTL-2020*/
void setup()
{
  DDRG=(1<<PG5);
  TCCR0A=(1<<COM0B0)|(1<<WGM01);
  TCCR0B=(1<<CS01);
 }
void loop()
{}
