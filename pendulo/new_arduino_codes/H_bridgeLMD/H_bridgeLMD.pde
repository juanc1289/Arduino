/*PROGRAM TO MAKE MOTOR GOES FORWARD AND BACKWARD BY USING
  AN H-BRIDGE LMD18200*/
//#define s 53
const int dir =10;
const int pwm =8;
const int brake =9;
int V = 30;
#define s 53

void setup ()
{//TCCR0B=0x00;
  pinMode (dir, OUTPUT);
  pinMode (pwm, OUTPUT);
  pinMode (brake, OUTPUT);
  pinMode(s,INPUT);
}

void loop ()
{if(digitalRead(s)==HIGH)
{
 motor_CCW();
 analogWrite(pwm,V);
 delay(500);
 motorStop();
 delay(100);
 motor_CW();
 analogWrite(pwm,V);
 delay(500);
 motorStop();
 delay(100);
}
else {motorStop();
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


