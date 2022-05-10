/* Rotary Inverted Pendulum PID controller
  using PID library*/

#include <PID_v1.h>
int A_2=18; /*encoder channel A*/
int B_2=19;/*encoder channel B*/
int dir=8; /*direction pin for H-bridge*/
int pwm=6; /*pwm pin for H-bridge*/
int brake=7;/*brake pin for H-bridge*/
#define S 53/*switch (just to say to arduino 
              that execute the program if switch is turned on)*/
volatile double count_2 = 0.0; /*variable to store encoder pulses*/
double Setpoint,Input,Output,theta;
PID Furuta(&Input,&Output,&Setpoint,5.0,0.0,0.0,DIRECT);

void setup()
{ Serial.begin (9600);
  /*channels A and B as inputs*/
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  /*pins to H-bridge as outputs*/
  pinMode (dir, OUTPUT);
  pinMode (pwm, OUTPUT);
  pinMode (brake, OUTPUT);
 /*for the switch and LED*/ 
  pinMode(S,INPUT);
  /*to read encoder*/
  attachInterrupt(5, doA2, CHANGE);
  attachInterrupt(4, doB2, CHANGE);  
  Furuta.SetMode(AUTOMATIC);
  Furuta.SetOutputLimits(-255.0,255.0);
  Furuta.SetSampleTime(1);
  Furuta.SetControllerDirection(DIRECT);
  Setpoint=180.0;
  Serial.println("START READING");
}
void loop()
{if(digitalRead(S)==HIGH)
{   /*variable to convert pulses to mechanical degrees*/
   theta=count_2*(360.0/10000.0);/* 10000.0=2500*4 
                                        (2500 counts per revolution
                                        encoder resolution)*/ 
  Input = theta ;
  Furuta.Compute();
  if (Input==Setpoint)
  {          
     motorStop ();
  }
  if (Input<Setpoint)
  {
    motor_CW ();/* motor spins clockwise direction*/

    analogWrite(pwm,Output);
  }
  if (Input>Setpoint)
  {  
      motor_CCW ();/*motor spins counter-clockwise direction*/
      
      if(Output<0)
      {Output=Output*(-1.0);
      analogWrite(pwm,Output);
      }else
        {analogWrite(pwm,Output);
        }
    }
  if(Input<=160.0||Input>=200.0)
  {
    motorStop ();
  } 
  serialData();
  
}else{motorStop();}
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
void motor_CCW ()/* motor spins clockwise direction*/
{
  digitalWrite(dir,HIGH);
  digitalWrite(pwm,HIGH);
  digitalWrite(brake,LOW);
}
void motor_CW ()/*motor spins counter clockwise direction*/
{
  digitalWrite(dir,LOW);
  digitalWrite(pwm,HIGH);
  digitalWrite(brake,LOW);
}
void motorStop ()/*motor brakes*/
{
  digitalWrite (dir, LOW);
  digitalWrite (pwm, LOW);
  digitalWrite (brake, HIGH);
}
void serialData()
{
  Serial.print(" Input = ");
  Serial.print(Input);
  Serial.print(", Output=");
  Serial.print(Output);
  Serial.println();
}
