/* proportional control to keep balancing a pendulum on an inverted position*/
#define A_2 18
#define B_2 19
#define dir 8
#define pwm 6
#define brake 7
const int s=53;
volatile float count_2 = 0;
volatile int theta;
int Kp, pot;
int setpoint;

void setup()
{ //TCCR4B=0x01;
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  pinMode (dir, OUTPUT);
  pinMode (pwm, OUTPUT);
  pinMode (brake, OUTPUT); 
  pinMode(s,INPUT);
  attachInterrupt(5, doA2, CHANGE);
  attachInterrupt(4, doB2, CHANGE);  
  Serial.begin (9600); Serial.println("START READING");
}

void loop()
{ if(digitalRead(s)==HIGH)
{
   theta=int (count_2*(360.0/10000.0)); /*variable to convert pulses to mechanical degrees*/
  Kp= 15; /*proportional gain*/
  setpoint=180;
  int error2= setpoint - theta;
  if (error2>0)
  {  //delay(10);
     digitalWrite(dir,LOW);
     //digitalWrite(pwm,HIGH);
     digitalWrite(brake,LOW);
      pot= Kp*error2; /*control signal*/
     analogWrite(pwm,pot);
     if(pot>255)
     {
       pot=255;
       analogWrite(pwm,pot);
     }
  } 
  if(error2<0)
     { //delay(10);
       digitalWrite(dir,HIGH);
      // digitalWrite(pwm,HIGH);
       digitalWrite(brake,LOW);
        pot= Kp*error2; /*control signal*/
       pot=pot*(-1);
       analogWrite(pwm,pot);
       if(pot>255)
     {
       pot=255;
       analogWrite(pwm,pot);
     }
       
     }
   if(error2==0)
      {
        digitalWrite (dir, LOW);
        digitalWrite (pwm, LOW);
        digitalWrite (brake, HIGH);
      }
     if(error2<=-20|error2>=20)
    {   digitalWrite (dir, LOW);
        digitalWrite (pwm, LOW);
        digitalWrite (brake, HIGH);
      } 
 
  Serial.print(" theta = ");
  Serial.print(theta);
  Serial.print(", error2 = ");
  Serial.print(error2);
  Serial.print(", pot=");
  Serial.print(pot);
  Serial.println();
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

