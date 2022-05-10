/*program to read encoder 1 (attached on the motor)*/
#define A 20
#define B 21
volatile float count = 0;
volatile int alpha;


void setup() 
{Serial.begin (9600);
  pinMode(A, INPUT); 
  pinMode(B, INPUT);
// encoder pin on interrupt 0 (pin 2)
  attachInterrupt(3, doA, CHANGE);
// encoder pin on interrupt 1 (pin 3)
  attachInterrupt(2, doB, CHANGE);  
   Serial.println("START READING");
}
void loop()
{
 
alpha=int(count*(360.0/(400.0*18.5)));
Serial.print("alpha = ");
Serial.println(alpha);
Serial.println(); 
}
void doA(){
  // look for a low-to-high on channel A
  if (digitalRead(A) == HIGH) { 
    // check channel B to see which way encoder is turning
    if (digitalRead(B) == LOW) {  
      count = count + 1;
            // CW
    } 
    else {
      count = count - 1; 
           // CCW
    }
  }
  else   // must be a high-to-low edge on channel A                                       
  { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(B) == HIGH) {   
      count = count + 1;
             // CW
    } 
    else {
      count = count - 1; 
              // CCW
    }
  }
}
void doB(){
  // look for a low-to-high on channel B
  if (digitalRead(B) == HIGH) {   
   // check channel A to see which way encoder is turning
    if (digitalRead(A) == HIGH) {  
      count = count + 1; 
          // CW
    } 
    else {
      count = count - 1;
              // CCW
    }
  }
  // Look for a high-to-low on channel B
  else { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(A) == LOW) {   
      count = count + 1;
            // CW
    } 
    else {
      count = count - 1; 
              // CCW
    }
  }
}

