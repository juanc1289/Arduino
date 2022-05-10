/*PROGRAM TO MAKE MOTOR GOES FORWARD AND BACKWARD BY USING
  AN H-BRIDGE LMD18200*/

const int dir =10;
const int pwm =8;
const int brake =9;
const int S=53;/*a single switch*/
int V = 160;

void setup ()
{//TCCR0B=0x00;
  pinMode (dir, OUTPUT);
  pinMode (pwm, OUTPUT);
  pinMode (brake, OUTPUT);
  pinMode(S,INPUT);
}

void loop ()
{if(digitalRead(S)==HIGH)
  {
   motor_CW();
 //analogWrite(pwm,V);
 //delay(500);
 //motorStop();
 //delay(500);
 //motor_CCW();
 //analogWrite(pwm,V);
 //delay(500);
 //motorStop();
 //delay(500);
  }
 else{ motorStop();}
}
void motor_CW ()/* motor spins clockwise direction*/
{
  digitalWrite(dir,HIGH);
  //digitalWrite(pwm,HIGH);
  digitalWrite(brake,LOW);
  analogWrite(pwm,V);
}
void motor_CCW ()/*motor spins counter clockwise direction*/
{
  digitalWrite(dir,LOW);
  //digitalWrite(pwm,HIGH);
  digitalWrite(brake,LOW);
  analogWrite(pwm,V);
}
void motorStop ()/*motor brakes*/
{
  digitalWrite (dir, LOW);
  digitalWrite (pwm, LOW);
  digitalWrite (brake, HIGH);
}


