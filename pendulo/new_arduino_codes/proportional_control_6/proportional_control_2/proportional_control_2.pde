/* proportional control to keep balancing a pendulum on an inverted position*/
#define A_2 18
#define B_2 19
#define dir 8
#define pwm 7
#define brake 6
volatile float count_2 = 0;
int Kp;
int setpoint;

void setup()
{ TCCR4B=0x02;
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  pinMode (dir, OUTPUT);
  pinMode (pwm, OUTPUT);
  pinMode (brake, OUTPUT); 
  attachInterrupt(5, doA2, CHANGE);
  attachInterrupt(4, doB2, CHANGE);  
 // Serial.begin (19200); Serial.println("START READING");
}

void loop()
{ 
  float angle_2=count_2*(360.0/10000.0); /*variable to convert pulses to mechanical degrees*/
  int pos2=int(angle_2); /*to convert floating point to integer*/
  Kp= 40; /*proportional gain*/
  setpoint=180;
  int error2= setpoint - pos2;
  if (error2>0)
  {          
     motor_CW ();
     int pot= Kp*error2; /*control signal*/
     analogWrite(pwm,pot);
     if(pot>255)
     {
       pot=255;
       analogWrite(pwm,pot);
     }
  } 
  if (error2>=20)
        {
          motorStop ();
        }
  if(error2<0)
     { 
       motor_CCW ();
       int pot= Kp*error2; /*control signal*/
       pot=pot*(-1);
       analogWrite(pwm,pot);
       if(pot>255)
       {
       pot=255;
       analogWrite(pwm,pot);
       }
     }
      if(error2<=-20)
         {
          motorStop ();
         } 
   if(error2==0)
      {
        motorStop ();
      }
      
  /*Serial.print(" pos2 = ");
  Serial.print(pos2);
  Serial.print(", error2 = ");
  Serial.print(error2);
  Serial.println();*/
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
void motor_CW ()/* motor spins clockwise direction*/
{
  digitalWrite(dir,HIGH);
  digitalWrite(pwm,HIGH);
  digitalWrite(brake,LOW);
}
void motor_CCW ()/*motor spins counter clockwise direction*/
{
  digitalWrite(dir,LOW);
  digitalWrite(pwm,HIGH);
  digitalWrite(brake,LOW);
}
void motorStop ()/*motor brakes*/
{
  digitalWrite (dir, HIGH);
  digitalWrite (pwm, LOW);
  digitalWrite (brake, HIGH);
}
