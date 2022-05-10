/* proportional control to keep balancing a pendulum on an inverted position*/
#define A_2 2
#define B_2 3
const int s=53;
volatile float count_2 = 0;
volatile int theta;
int Voltage;
int Kp=14;
int setpoint=180;
void setup()
{      
  DDRH=DDRH|B00111000; /* DDRH|=(1<<PH6)|(1<<PH5); */
  TCCR4A|=(1<<COM4A1)|(1<<WGM40);
  TCCR4B|=(1<<CS41)|(1<<CS40);
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  pinMode(s,INPUT);
  attachInterrupt(0, doA2, CHANGE);
  attachInterrupt(1, doB2, CHANGE);  
  Serial.begin (9600); Serial.println("START READING");
}

void loop()
{ if(digitalRead(s)==HIGH)
{
   theta=int (count_2*(360.0/10000.0)); /*variable to convert pulses to mechanical degrees*/
  int error2= setpoint - theta;
  
  if(error2<=-20|error2>=20)
      { motorStop();
      } 
  if (error2>0)
  {  motor_CW();
     Voltage= Kp*error2; /*control signal*/
     OCR4A=Voltage;//analogWrite(pwm,Voltage);
     if(Voltage>255)
     {
       Voltage=255;
       OCR4A=Voltage;
     }
  } //motorStop(); 
  if(error2<0)
     { motor_CCW();
        Voltage= Kp*error2; /*control signal*/
       Voltage=Voltage*(-1);
       OCR4A=Voltage;//analogWrite(pwm,Voltage);
       if(Voltage>255)
     {
       Voltage=255;
       OCR4A=Voltage;//analogWrite(pwm,Voltage);
     }
       
     }  //motorStop();
   
     if(error2<=-20|error2>=20)
      { motorStop();
      }
     if (error2==0)
      {motorStop();} 
   Serial.print(int(count_2));
  Serial.print(" theta = ");
  Serial.print(theta);
  Serial.print(", error2 = ");
  Serial.print(error2);
  Serial.print(", pot=");
  Serial.print(Voltage);
  Serial.println();
}
else{motorStop();
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
void motor_CCW()
{
	PORTH=B00101000;
}
void motor_CW()
{
	PORTH=B00001000;
}
void motorStop()
{
	PORTH=B00010000;
}
