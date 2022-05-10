#include <stdio.h>      
/*using PORT K*/
/*PK0=A_1;PK1=B_1;PK2=A_2;PK3=B_2*/
#include <avr/interrupt.h>
#include <avr/io.h>

volatile float count_1 = 0;
volatile float count_2 = 0;
volatile int alpha;
volatile int theta;
void setup()
{  Serial.begin(9600);
  /*to set Pin Change Interrupt*/
  DDRK=0x00;
  PCMSK2|=(1<<PCINT19)|(1<<PCINT18)|(1<<PCINT17)|(1<<PCINT16);  
  PCICR|=(1<<PCIE2);
  sei();Serial.println("START");
}
void loop ()
{
  alpha=int(count_1*(360.0/(400.0*18.0)));
  theta=int(count_2*(360.0/10000.0));
  Serial.print("alpha=");
  Serial.print(alpha);
  Serial.print(",theta=");
  Serial.println(theta);
}
ISR(PCINT2_vect)
{
  if (digitalRead(PK0) == HIGH) { 
    // check channel B to see which way encoder is turning
    if (digitalRead(PK1) == LOW) {  
      count_1 = count_1 + 1;         // CW
    } 
    else {
      count_1 = count_1 - 1;         // CCW
    }
  }
  else   // must be a high-to-low edge on channel A                                       
  { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(PK1) == HIGH) {   
      count_1 = count_1 + 1;          // CW
    } 
    else {
      count_1 = count_1 - 1;          // CCW
    }
  }


if (digitalRead(PK1) == HIGH) {   
   // check channel A to see which way encoder is turning
    if (digitalRead(PK0) == HIGH) {  
      count_1 = count_1 + 1;         // CW
    } 
    else {
      count_1 = count_1 - 1;         // CCW
    }
  }
  // Look for a high-to-low on channel B
  else { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(PK0) == LOW) {   
      count_1 = count_1 + 1;          // CW
    } 
    else {
      count_1 = count_1 - 1;          // CCW
    }
  }
  if (digitalRead(PK2) == HIGH) { 
    // check channel B to see which way encoder is turning
    if (digitalRead(PK3) == LOW) {  
      count_2 = count_2 + 1;         // CW
    } 
    else {
      count_2 = count_2 - 1;         // CCW
    }
  }
  else   // must be a high-to-low edge on channel A                                       
  { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(PK3) == HIGH) {   
      count_2 = count_2 + 1;          // CW
    } 
    else {
      count_2 = count_2 - 1;          // CCW
    }
  }
  if (digitalRead(PK3) == HIGH) {   
   // check channel A to see which way encoder is turning
    if (digitalRead(PK2) == HIGH) {  
      count_2 = count_2 + 1;         // CW
    } 
    else {
      count_2 = count_2 - 1;         // CCW
    }
  }
  // Look for a high-to-low on channel B
  else { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(PK2) == LOW) {   
      count_2 = count_2 + 1;          // CW
    } 
    else {
      count_2 = count_2 - 1;          // CCW
    }
  }
}



  
