/*Furuta Pendulum PID controller */
#include <avr/interrupt.h>
#include <avr/io.h>

const int A_2=18; /*channel A from encoder 2 plugged in pin 18*/
const int B_2=19; /*channel B from encoder 2 plugged in pin 19*/
const int dir=6; /*H-bridge pin plugged in pin 8*/
const int pwm=4; /*H-bridge pin plugged in pin 7*/
const int brake=5;/*H-bridge pin plugged in pin 6*/
const int x=11;
//const int S=10;/*switch*/
const int led=52;
volatile float count_2 = 0.0;
float angle_2,error2,V,Int_E,Area,Der_E,lastE;
const float setpoint=180.0; /*reference*/
const float dt=0.0041; /*sample time*/
const float kp=12.0;
const float ki=0.0;
const float kd=0.0;

ISR(TIMER2_OVF_vect)
  {
    digitalWrite(x,HIGH);
    Area=(error2+lastE)*0.00205;/*el 0.00205=dt/2*/
    Int_E=(Area+Int_E);
    Der_E=(error2-lastE)/dt;
    lastE=error2;
    V=kp*error2+ki*Int_E+kd*Der_E;
    digitalWrite(x,LOW);
  }
  
void setup() 
{ //TCCR4B=B00000001 ;
  //TCCR4A=B00100001;
  TCCR2B=0x06;
  TCCR2A=0x00;
  ASSR=0x00;
  TIMSK2=0x01;
  TCNT2=0X00;
  TIFR2=0x01;
  SREG=0x80;
  sei();
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  pinMode (dir, OUTPUT);
  pinMode (pwm, OUTPUT);
  pinMode (brake, OUTPUT);
  pinMode(x,OUTPUT);
  //pinMode(S,INPUT);
  pinMode(led,OUTPUT);
  attachInterrupt(5,doA2,CHANGE);
  attachInterrupt(4,doB2,CHANGE);
  Serial.begin (19200); Serial.println("START READING");
}

void loop()
{  
  
  digitalWrite(led,HIGH);
  angle_2=count_2*(360.0/10000.0);
  error2 = setpoint - angle_2;
  if (error2>0.0)
  {  
     motor_CW (); 
     analogWrite(pwm,V);

     if(V>255.0)
     {
       V=255.0;
       analogWrite(pwm,V);
     }
  }
  if (error2>=30.0)
        {
          motorStop (); 
        }
  if(error2<0.0)
     { 
       if(V<0.0)
       {
       motor_CCW ();    
       V=V*(-1.0);
       analogWrite(pwm,V);
       }
       motor_CCW();
       analogWrite(pwm,V);
       if(V>255.0)
     {
       V=255.0; 
       analogWrite(pwm,V);
       
     }
   if(error2<=-30.0)
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
  //delay(1);
  digitalWrite(pwm,HIGH);
  //delay(1);
  digitalWrite(brake,LOW);
}
void motor_CCW ()/*motor spins counter clockwise direction*/
{
  digitalWrite(dir,LOW);
  //delay(1);
  digitalWrite(pwm,HIGH);
  //delay(1);
  digitalWrite(brake,LOW);
}
void motorStop ()/*motor brakes*/
{
  digitalWrite (dir, LOW);
  //delay(1);
  digitalWrite (pwm, LOW);
  //delay(1);
  digitalWrite (brake, HIGH);
}

