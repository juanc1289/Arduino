#include <avr/interrupt.h>
#include <avr/io.h>
const int A_2=18; 
const int B_2=19; 
const int dir=10; 
const int pwm=8; 
const int brake=9;
const int S=53;
const int led=52;
volatile float count_2 = 0.0,angle_2;
volatile float error2,V,Int_E,Area,Der_E,lastE;
const float setpoint=180.0; /*reference*/
const float dt=0.0041; /*sample time*/
const float kp=15.0; /*proportional gain*/
const float ki=0.0; /*integral gain*/
const float kd=0.0; /*derivative gain*/

void setup()
{ Serial.begin (9600);
  Serial.println("Furuta Control");
  TCCR2B|=(1<<CS22)|(1<<CS21);
  TIMSK2|=(1<<TOIE2);
  EIMSK|=(1<<INT3)|(1<<INT2);
  EICRA|=(1<<ISC30)|(1<<ISC20);
  sei();
  
}
void loop()
{
  if(digitalRead(S)==HIGH)
  {//sei();
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
  analogWrite(pwm,V);
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
cli();
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
sei();

}
}
ISR(INT3_vect)
{
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
ISR(INT2_vect)
{
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

