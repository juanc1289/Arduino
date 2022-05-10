#include <LiquidCrystal.h>
#define A 18
#define B 19
volatile float count = 0;
LiquidCrystal lcd(46, 47, 45, 44, 43, 42);/*(RS,E,D4-D7)*/
float angle;
float error;
void setup() 
{
  pinMode(A, INPUT); 
  pinMode(B, INPUT); 
  attachInterrupt(5, doA, CHANGE);
  attachInterrupt(4, doB, CHANGE);
  lcd.begin(16, 2);
  lcd.print("P2=");
  lcd.setCursor(0,1);
  lcd.print("E2=");
  
}
void loop()
{
   angle=count*(360.0/10000.0);
   error= 180.0 - angle ;
   prints();
   delay(300);
   lcd.clear();
  
} 
void doA(){
  // look for a low-to-high on channel A
  if (digitalRead(A) == HIGH) { 
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
void prints()
{
  lcd.setCursor(3, 0);
  lcd.print(int(angle));
  lcd.setCursor(3,1);
  lcd.print(int(error));
  lcd.setCursor(0,0);
  lcd.print("P2=");
  lcd.setCursor(0,1);
  lcd.print("E2=");
}

