/*PROGRAM TO READ ENCODER number 2 DATA AND CONVERT IT TO DEGRRES*/
#include <stdio.h>
int s=53;
int i=80;
int dup=40;
int A=18;
int B=19;
int Voltage;
volatile int count = 0;
volatile int theta;

void setup() {
	DDRH=DDRH|B00111000; /* DDRH|=(1<<PH6)|(1<<PH5); */
	 TCCR4A|=(1<<COM4A1)|(1<<WGM40);
          TCCR4B|=(1<<CS41)|(1<<CS40);
        pinMode(s,INPUT);
	TCCR4A|=(1<<COM4A1)|(1<<WGM40);
	TCCR4B|=(1<<CS41)|(1<<CS40);
  pinMode(dup,OUTPUT);
  pinMode(A, INPUT);
 digitalWrite(A,HIGH); 
  pinMode(B, INPUT); 
  digitalWrite(B,HIGH);
// encoder pin on interrupt 5 (pin 18)
  attachInterrupt(4, doA, CHANGE);
// encoder pin on interrupt 4 (pin 19)
  attachInterrupt(5, doB, CHANGE);  
  Serial.begin (9600); Serial.println("START READING");

}
void loop ()
{
  theta=int(count*(360.0/10000.0));
 serialData();
 
        Voltage=125;
       OCR4A=Voltage;
 if(digitalRead(s)==HIGH)
  {    
	motor_CCW();
delay(250);
	motorStop();
delay(250);
	motor_CW();
delay(250);
	motorStop();
delay(250);
}
  else  {
    motorStop();
        }
}
void doA(){

  // look for a low-to-high on channel A
  if (digitalRead(A) == HIGH) { 
  
      digitalWrite(dup,HIGH);
    // check channel B to see which way encoder is turning
    if (digitalRead(B) == LOW) {  
      count = count + 1;         // CW
    } 
    else {
      count = count - 1;         // CCW
    }
  }
  else   // must be a high-to-low edge on channel A                                       
  { 
   digitalWrite(dup,LOW);
    
    // check channel B to see which way encoder is turning  
    if (digitalRead(B) == HIGH) {   
      count = count + 1;          // CW
    } 
    else {
      count = count - 1;          // CCW
    }
  }

}
void doB(){
  // look for a low-to-high on channel B
  if (digitalRead(B) == HIGH) {   
   // check channel A to see which way encoder is turning
    if (digitalRead(A) == HIGH) {  
      count = count + 1;         // CW
    } 
    else {
      count = count - 1;         // CCW
    }
  }
  // Look for a high-to-low on channel B
  else { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(A) == LOW) {   
      count = count + 1;          // CW
    } 
    else {
      count = count - 1;          // CCW
    }
  }
}
void serialData()
{
 Serial.print("pos2 = ");
 Serial.print(theta);
 Serial.println(); 
   Serial.print(" count = ");
  Serial.print(count);
  Serial.print("  ");
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
