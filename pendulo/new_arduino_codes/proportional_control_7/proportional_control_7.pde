/* proportional control to keep balancing a pendulum on an inverted position*/
#define A_2 18
#define B_2 19
const int s=53;
volatile double count_2 = 0;
const double kp=2.0;
double theta,error2;
const double setpoint=180.0;

void setup()
{ Serial.begin (9600);
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  DDRH=DDRH|B00111000; /* DDRH|=(1<<PH6)|(1<<PH5); */
  TCCR4A|=(1<<COM4A1)|(1<<WGM40);
  TCCR4B|=(1<<CS41)|(1<<CS40);
  pinMode(s,INPUT);
  attachInterrupt(5, doA2, CHANGE);
  attachInterrupt(4, doB2, CHANGE);  
  Serial.println("START READING");
}

void loop()
{ if(digitalRead(s)==HIGH)
{
  theta=count_2*(360.0/10000.0);
  error2=setpoint-theta;
  
if(error2==0.0)
{
  motorStop();
}
else if(error2>0.0)
{
  motor_CW();
  OCR4A=255.0-(kp*error2);
}
else if(error2<0.0)
{
  if(kp*error2<0)
  {
    motor_CCW();
    OCR4A=(-1)*(-kp*error2+255.0);
  }else{
        motor_CCW();
        OCR4A=kp*error2-255.0;
       }
}
else if(error2>=20.0 || error2<=-20.0)
  {
    motorStop();
  }
serialData();
}else 
  {motorStop();}
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
void serialData()
{
  Serial.print("count_2=");
  Serial.print(count_2);
  Serial.print(" theta = ");
  Serial.print(theta);
  Serial.print(", error2 = ");
  Serial.print(error2);
  Serial.print(", V=");
  Serial.print(OCR4A);
  Serial.println();
}
