/*Program to calculate and print error on encoder 2*/
#define A 18
#define B 19
volatile float count = 0.0;

void setup()
{
  pinMode(A, INPUT); 
  pinMode(B, INPUT); 
  attachInterrupt(5, doA, CHANGE);
  attachInterrupt(4, doB, CHANGE);  
  Serial.begin (9600); Serial.println("START READING");
}
void loop()
{
   volatile float angle=count*(360.0/10000.0);
   volatile int pos=int(angle);
   int theta= 180 - pos ;
   Serial.print("theta = ");
   Serial.print(theta);
   //Serial.print(", error = ");
   //Serial.print(error);
   Serial.println();
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
