/*PROGRAM TO READ ENCODER number 2 DATA AND CONVERT IT TO DEGRRES*/
int A=18;
int B=19;
volatile float count = 0;
volatile int theta;

void setup() {
  pinMode(A, INPUT); 
  pinMode(B, INPUT); 
// encoder pin on interrupt 5 (pin 18)
  attachInterrupt(5, doA, CHANGE);
// encoder pin on interrupt 4 (pin 19)
  attachInterrupt(4, doB, CHANGE);  
  Serial.begin (9600); Serial.println("START READING");

}
void loop ()
{
  theta=int(count*(360.0/10000.0));
 serialData();
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
void serialData()
{
 Serial.print("pos2 = ");
 Serial.print(theta);
 Serial.println(); 
}

