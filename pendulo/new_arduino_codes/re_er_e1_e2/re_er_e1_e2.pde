/*Program to read and calculate both data and error 
  from encoders 1 and 2 */
#define A_1 20
#define B_1 21
#define A_2 18
#define B_2 19
volatile float count_1 = 0;
volatile float count_2 = 0;

void setup()
{
  pinMode(A_1, INPUT); 
  pinMode(B_1, INPUT); 
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  attachInterrupt(3, doA1, CHANGE);
  attachInterrupt(2, doB1, CHANGE);
  attachInterrupt(5, doA2, CHANGE);
  attachInterrupt(4, doB2, CHANGE);
  Serial.begin (9600); Serial.println("START READING");
}

void loop()
{ 
  float angle_1=count_1*(360.0/(400.0*18.5));
  int pos1=int(angle_1);
  int error1= 120 - pos1 ;
  float angle_2=count_2*(360.0/10000.0);
  int pos2=int(angle_2);
  int error2= 180 - pos2 ;
  
  Serial.print("pos1 = ");
  Serial.print(pos1);
  Serial.print(", error1 = ");
  Serial.print(error1);
  Serial.print(" pos2 = ");
  Serial.print(pos2);
  Serial.print(", error2 = ");
  Serial.print(error2);
  Serial.println();
  
  
  
}

void doA1(){
  // look for a low-to-high on channel A
  if (digitalRead(A_1) == HIGH) { 
    // check channel B to see which way encoder is turning
    if (digitalRead(B_1) == LOW) {  
      count_1 = count_1 + 1;         // CW
    } 
    else {
      count_1 = count_1 - 1;         // CCW
    }
  }
  else   // must be a high-to-low edge on channel A                                       
  { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(B_1) == HIGH) {   
      count_1 = count_1 + 1;          // CW
    } 
    else {
      count_1 = count_1 - 1;          // CCW
    }
  }
}
void doB1(){
  // look for a low-to-high on channel B
  if (digitalRead(B_1) == HIGH) {   
   // check channel A to see which way encoder is turning
    if (digitalRead(A_1) == HIGH) {  
      count_1 = count_1 + 1;         // CW
    } 
    else {
      count_1 = count_1 - 1;         // CCW
    }
  }
  // Look for a high-to-low on channel B
  else { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(A_1) == LOW) {   
      count_1 = count_1 + 1;          // CW
    } 
    else {
      count_1 = count_1 - 1;          // CCW
    }
  }
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
