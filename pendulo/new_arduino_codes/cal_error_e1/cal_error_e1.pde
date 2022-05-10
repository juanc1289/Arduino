/*Program to calculate and print error on encoder 1*/
#define A 20
#define B 21
volatile float count = 0;
const int S=10;

void setup() {
  pinMode(A, INPUT); 
  pinMode(B, INPUT);
  pinMode(S,INPUT); 
// encoder pin on interrupt 3 (pin 20)
  attachInterrupt(3, doA, CHANGE);
// encoder pin on interrupt 2 (pin 21)
  attachInterrupt(2, doB, CHANGE);  
  Serial.begin (19200); Serial.println("START READING");
}

void loop()
{
  if(digitalRead(S)==HIGH)
  {
  float angle=count*(360.0/(400.0*18.0));
  int pos=int(angle);
   int error= 120 - pos ;
   Serial.print("P1 = ");
   Serial.print(pos);
   Serial.print(", E1 = ");
   Serial.print(error);
   Serial.println(); 
  }
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

