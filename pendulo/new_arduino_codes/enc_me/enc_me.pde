#include <stdio.h>

unsigned int dataE1;
unsigned int dataE2;
const byte CS0=28;
const byte CS1=29;
void setup()
{
  Serial.begin(9600);
  DDRC=0x00;
  PORTC=0x00;
  pinMode(CS0,OUTPUT);
  digitalWrite(CS0,HIGH);
  pinMode(CS1,OUTPUT);
  digitalWrite(CS1,HIGH);
  DDRL=DDRL|B11100111;/*SEL1 OE1 RST1  RST2 OE2 SEL2*/
                    /*PL7  PL6 PL5   PL2  PL1 PL0*/
  PORTL=PORTL|B00100100;
  Serial.println("y ahora q");
  DDRG=(1<<PG5);/*to use as output CLK signal*/
  TCCR0A=(1<<COM0B0)|(1<<WGM01);/*enable OC0B pin*/
  TCCR0B=(1<<CS00);
}
void loop()
{
 dataE1=read_encoder_1();
 dataE2=read_encoder_2(); 
 serial_data(); 
}
unsigned int read_encoder_1 (void)
{
  byte Hbyte,Lbyte;
  PORTL=B00100100;
  digitalWrite(CS0,LOW);
  Hbyte=PINC;
  digitalWrite(CS0,HIGH);
  PORTL=B10100100;
  digitalWrite(CS0,LOW);
  Lbyte=PINC;
  digitalWrite(CS0,HIGH);
  PORTL=B11100111;
  dataE1=Hbyte*256+Lbyte;
  return(dataE1);
}
unsigned int read_encoder_2(void)
{
  byte Hbyte,Lbyte;
  PORTL=B00100100;
  digitalWrite(CS1,LOW);
  Hbyte=PINC;
  digitalWrite(CS1,HIGH);
  PORTL=B00100101;
  digitalWrite(CS1,LOW);
  Lbyte=PINC;
  digitalWrite(CS1,HIGH);
  PORTL=B11100111;
  dataE2=Hbyte*256+Lbyte;
  return(dataE2);
}
void serial_data()
{
 /*Serial.print("alpha= ");
 Serial.print(dataE1);*/
 Serial.print(", theta=");
 Serial.println(double(dataE2*360.0/10000.0));
}
