/*code to make proportional control of R.I.P. 
using PID library, HCTL-2020 IC's to read optical 
encoders and an LMD18200 H-Bridge to motor control.
This code is made up two parts, DAQ system and motor control.
HCTL-2020 IC's reads data comming from the encoder*/
#include <PID_v1.h>
#include <stdio.h>
unsigned int dataE1;
unsigned int dataE2;
const byte CS0=28;
const byte CS1=29;
int s=53;
double Setpoint,Input,Output;
PID Furuta(&Input,&Output,&Setpoint,10.0,0.0,0.0,DIRECT);
void setup()
{
  //Serial.begin(9600);
  DDRC=0x00;
  PORTC=0x00;
  pinMode(CS0,OUTPUT);
  digitalWrite(CS0,HIGH);
  pinMode(CS1,OUTPUT);
  digitalWrite(CS1,HIGH);
  DDRL=DDRL|B11100111;/*SEL1 OE1 RST1  RST2 OE2 SEL2*/
                    /*PL7  PL6 PL5   PL2  PL1 PL0*/
  PORTL=PORTL|B00100100;
  /*to set LMD18200 pins*/
  DDRH=DDRH|B00111000;//PH5=D PH4=B PH3=P
  PORTH=0x00;
  TCCR4A|=(1<<COM4A1)|(1<<WGM40);
  TCCR4B|=(1<<CS41)|(1<<CS40);
 /*for the switch and LED*/ 
  pinMode(s,INPUT);
  Furuta.SetMode(AUTOMATIC);
  Furuta.SetOutputLimits(-255.0,255.0);
  Furuta.SetSampleTime(1);
  Furuta.SetControllerDirection(DIRECT);
  Setpoint=180.0;
 // Serial.println("DATA");
  DDRG=(1<<PG5);/*to use as output CLK signal*/
  TCCR0A=(1<<COM0B0)|(1<<WGM01);/*enable OC0B pin*/
  TCCR0B=(1<<CS01);
}
void loop()
{
  if (digitalRead(s)==HIGH)
  {
 dataE1=read_encoder_1();
 dataE2=read_encoder_2();
 Input=double(dataE2*360.0/10000.0);
 Furuta.Compute();
  if(Input==Setpoint)
   {motorStop();
   }
  else if((Input<160.0)||(Input>200.0))
   {motorStop();
   } 
  else if((Input>160.0)||(Input<Setpoint))
    {
      motor_CW();
      OCR4A=Output;
    }
   else if((Input>Setpoint)||(Input<200.0))
     {
       motor_CCW();
       OCR4A=Output; 
     }
// serial_data();
  }else {motorStop();}
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
void motor_CCW()
{
	PORTH=B00101000;/*0x28*/
}
void motor_CW()
{
	PORTH=B00001000;/*0x08*/
}
void motorStop()
{
	PORTH=B00010000;/*0x10*/
}
/*void serial_data()
{
  Serial.print(" Input = ");
  Serial.print(Input);
  Serial.print(", Output=");
  Serial.print(Output);
  Serial.println();
}*/
