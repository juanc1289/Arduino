/*
  Program by Carlos Borras. Copyrigth  2011
  to read and write data using an optical encoder
 */

 
unsigned int dataE1;  // public variable//
unsigned int dataE2;
const byte CS0 =  29; // activa el pin nO 13
const byte CS1 =  28;  // ACTIVA EL PIN 12 PARA EL otro encoder
 
 void setup() 
 {   
 Serial.begin(9600); // config com speed//
  DDRG=(1<<PG5);
  TCCR0A=(1<<COM0B0)|(1<<WGM01);
  TCCR0B=(1<<CS01);
 DDRC= 0x00; //B00000000 Config PORTC as an input to read data from encoders//
 DDRL= 0xE7; //B11100111 Config PORTL as output control de las dos quadraturas.
            // OE1 RST1 SEL1 0 0 OE2 RST2 SEL2//
 delay(1);
 digitalWrite(CS0,HIGH);
 digitalWrite(CS1,HIGH);
 PORTL=0x00;
 delay(5);
 PORTL=0x42; //B01000010  initialize the counter in both quadrature.
 delay(1);
  Serial.println("Program by C Borras to read encoder"); 
  }


  unsigned int read_encoder_1(void) {
  //unsigned char Hbyte, Lbyte;
  byte Hbyte, Lbyte;
  PORTL=0x42; // Read HByte
  digitalWrite(CS0, LOW);
  Hbyte=PINC;
  digitalWrite(CS0, HIGH);
  delay(1);
  PORTL=0x62; // read LByte
  digitalWrite(CS0, LOW);
  Lbyte=PINC;
  digitalWrite(CS0, HIGH);
  PORTL=0xE7; // Complete the secuence//
  dataE1=Hbyte*256+Lbyte;
  return (dataE1);
}

  unsigned int read_encoder_2(void) {
  //unsigned char Hbyte, Lbyte;
  byte Hbyte, Lbyte;
  digitalWrite(CS1, LOW);
  Hbyte=PINC;
  digitalWrite(CS1, HIGH);
  delay(1);
  digitalWrite(CS1, LOW);
  Lbyte=PINC;
  digitalWrite(CS1, HIGH);
  dataE2=Hbyte*256+Lbyte;
  return (dataE2);
}



void loop() {
  
 dataE1=read_encoder_1();  // read data from encoder
 delay(1000);   // wait for a second
 dataE2=read_encoder_2();
 delay(1000);
 Serial.print(dataE1);
Serial.print(" ");
Serial.println(dataE2);
}
