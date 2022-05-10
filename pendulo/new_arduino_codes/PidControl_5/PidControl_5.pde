const int A_2=18; /*channel A from encoder 2 plugged in pin 18*/
const int B_2=19; /*channel B from encoder 2 plugged in pin 19*/
const int dir=10; /*H-bridge pin plugged in pin 8*/
const int pwm=8; /*H-bridge pin plugged in pin 7*/
const int brake=9;/*H-bridge pin plugged in pin 6*/
const int S=53;/*switch*/
const int led=52;
volatile float count_2 = 0.0;
volatile float angle_2,error2,V,Int_E,Area,Der_E,lastE;
const float setpoint=180.0; /*reference*/
const float dt=0.0041; /*sample time*/
const float kp=15.0; /*proportional gain*/
const float ki=0.0; /*integral gain*/
const float kd=0.0; /*derivative gain*/

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
  TCCR2B=(1<<CS22)|(1<<CS21);
  TCCR2A=0x00;
  ASSR=0x00;
  TIMSK2=0x01;
  TCNT2=0X00;
  TIFR2=0x01;
  SREG=0x80;
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  pinMode(dir, OUTPUT);
  pinMode(pwm, OUTPUT);
  pinMode(brake, OUTPUT);
  pinMode(S,INPUT);
  pinMode(led,OUTPUT);
  Serial.begin (19200); Serial.println("START READING");
  attachInterrupt(5,doA2,CHANGE);
  attachInterrupt(4,doB2,CHANGE);
  constrain(V,-255.0,255.0);
  
}
void loop ()
{
  if(digitalRead(S)==HIGH)
  {
  angle_2=count_2*(360.0/10000.0);
  error2 = setpoint - angle_2;
if (error2>0.0)
{
if(error2>=20.0)
{
  motorStop();
}
else
 {motor_CCW();
  analogWrite(pwm,V)
 }
}
if(error2<0.0)
{
  if(error2<=-20.0)
  {
    motorStop();
  }
  else
  {
    motor_CW();
    analogWrite(pwm,V);
  }
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



