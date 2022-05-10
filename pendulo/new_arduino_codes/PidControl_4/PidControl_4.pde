
#define A_2 18
#define B_2 19
volatile float count_2 = 0;
volatile float angle_2,error2,V,Int_E,Area,Der_E,lastE;
const int S=53;/*switch*/
const int led=52;
const int dir=10; 
const int pwm=8; 
const int brake=9;
const float setpoint=180.0; 
const float dt=0.0041;
const float kp=15.0; 
const float ki=0.0; 
const float kd=0.0; 
ISR(TIMER2_OVF_vect)
  {
    
    Area=(error2+lastE)*0.00205;/*el 0.00205=dt/2*/
    Int_E=(Area+Int_E);
    Der_E=(error2-lastE)/dt;
    lastE=error2;
    V=kp*error2+ki*Int_E+kd*Der_E;
   
  }
void setup()
{ 
  SREG=B10000000;
  EICRA=B01010101;
  EIMSK=B00001111;
  EIFR=B00001111; 
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  pinMode (dir, OUTPUT);
  pinMode (pwm, OUTPUT);
  pinMode (brake, OUTPUT);
  pinMode(S,INPUT);
  pinMode(led,OUTPUT);
  Serial.begin (19200); Serial.println("START READING");
}
void loop()
{ 
  if(digitalRead(S)==HIGH)
  {digitalWrite(led,HIGH);
  //attachInterrupt(5,doA2,CHANGE);
//attachInterrupt(4,doB2,CHANGE);
  angle_2=count_2*(360.0/10000.0);
  error2 = setpoint - angle_2;
  if (error2>0.0)
  {  
     motor_CCW (); 
     analogWrite(pwm,V);

     if(V>255.0)
     {
       V=255.0;
       analogWrite(pwm,V);
     }
  }
  if (error2>=20.0)
        {
          motorStop (); 
        }
  if(error2<0.0)
     { 
       if(V<0.0)
       {
       motor_CW ();    
       V=V*(-1.0);
       analogWrite(pwm,V);
       }
       motor_CW();
       analogWrite(pwm,V);
       if(V>255.0)
     {
       V=255.0; 
       analogWrite(pwm,V);
       
     }
   if(error2<=-20.0)
         {
          motorStop (); 
         } 
     }
   if(error2==0.0)
      {
        motorStop (); 

      }
 
  Serial.print(" P2 = ");/*position encoder 2*/
  Serial.print(angle_2);/*position value encoder 2*/
  Serial.print(", E2 = ");
  Serial.print(error2);
  Serial.print(", P=");
  Serial.print(kp*error2);
  Serial.print(", I=");
  Serial.print(Int_E);
  Serial.print(", D=");
  Serial.print(Der_E);
  Serial.print(", V=");/*output control*/
  Serial.print(V);
  Serial.println();
  //detachInterrupt(5);
  //detachInterrupt(4);
 
  }digitalWrite(led,LOW);
}

ISR(INT2_vect)
{// look for a low-to-high on channel B
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
ISR(INT3_vect)
{// look for a low-to-high on channel A
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

void motor_CW ()/* motor spins clockwise direction*/
{
  digitalWrite(dir,HIGH);
  delayMicroseconds(1);
  digitalWrite(pwm,HIGH);
  delayMicroseconds(1);
  digitalWrite(brake,LOW);
}
void motor_CCW ()/*motor spins counter clockwise direction*/
{
  digitalWrite(dir,LOW);
  delayMicroseconds(1);
  digitalWrite(pwm,HIGH);
  delayMicroseconds(1);
  digitalWrite(brake,LOW);
}
void motorStop ()/*motor brakes*/
{
  digitalWrite (dir, LOW);
  delayMicroseconds(1);
  digitalWrite (pwm, LOW);
  delayMicroseconds(1);
  digitalWrite (brake, HIGH);
}

