/* proportional control to keep balancing a pendulum on an inverted position*/
#define A_2 18
#define B_2 19
#define dir 8
#define pwm 7
#define brake 6
#define fm 5
volatile double count_2 = 0.0;
//double Kp;
double setpoint;

void setup()
{ //TCCR4B=0x01;
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  pinMode (dir, OUTPUT);
  pinMode (pwm, OUTPUT);
  pinMode (brake, OUTPUT); 
  attachInterrupt(5, doA2, CHANGE);
  attachInterrupt(4, doB2, CHANGE);  
  Serial.begin (19200); Serial.println("START READING");
}
void loop()
{
double angle_2=count_2*(360.0/10000.0); 
double pos2=angle_2;
setpoint=180.0;
double error2= setpoint - pos2;
analogWrite(5,error2);
Serial.print(" pos2 = ");
  Serial.print(pos2);
  Serial.print(", error2 = ");
  Serial.print(error2);
  Serial.print(", fm = ");
  Serial.print(fm);
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

