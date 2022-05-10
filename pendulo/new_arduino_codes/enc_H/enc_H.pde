/*PB5= dir pin*/
/*PH5=pwm pin*/
/*PH6=brake pin*/
/*PB0= s pin*/

#include <stdio.h>
#define A_2 18
#define B_2 19
volatile float count_2 = 0;
int s=53;
int i=80;
int theta;

void setup()
{
	
  DDRH=DDRH|B00111000; /* DDRH|=(1<<PH6)|(1<<PH5); */
  TCCR4A|=(1<<COM4A1)|(1<<WGM40);
  TCCR4B|=(1<<CS41)|(1<<CS40);
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  pinMode(s,INPUT);
  attachInterrupt(5, doA2, CHANGE);
  attachInterrupt(4, doB2, CHANGE);  
  Serial.begin (9600); Serial.println("START READING");
}

void loop()
{
  if(digitalRead(s)==HIGH)
  {theta=int (count_2*(360.0/10000.0));
	motor_CCW();
delay(250);
	motorStop();
delay(110);
	motor_CW();
delay(250);
	motorStop();
delay(100);
}
  else  {motorStop();
        }
  Serial.print(" theta = ");
  Serial.print(theta);
  Serial.println();
}
void doA2(){
  // look for a low-to-high on channel A
  if (digitalRead(A_2) == HIGH) { 
    // check channel B to see which way encoder is turning
    if (digitalRead(B_2) == LOW) {  
      count_2 = count_2 + 1;         // CW
    } 
    else {
      count_2 = count_2 - 1;         // CCW
    }
  }
  else   // must be a high-to-low edge on channel A                                       
  { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(B_2) == HIGH) {   
      count_2 = count_2 + 1;          // CW
    } 
    else {
      count_2 = count_2 - 1;          // CCW
    }
  }

}
void doB2(){
  // look for a low-to-high on channel B
  if (digitalRead(B_2) == HIGH) {   
   // check channel A to see which way encoder is turning
    if (digitalRead(A_2) == HIGH) {  
      count_2 = count_2 + 1;         // CW
    } 
    else {
      count_2 = count_2 - 1;         // CCW
    }
  }
  // Look for a high-to-low on channel B
  else { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(A_2) == LOW) {   
      count_2 = count_2 + 1;          // CW
    } 
    else {
      count_2 = count_2 - 1;          // CCW
    }
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
