/* proportional control to keep balancing a pendulum on an inverted position*/
#define A_2 18
#define B_2 19
#include <LiquidCrystal.h>
LiquidCrystal lcd(46, 47, 45, 44, 43, 42);
const int s=53;
volatile float count_2 = 0;
volatile float theta;
float Voltage,error2;
float Kp=14;
float setpoint=180;
void setup()
{      
  DDRH=DDRH|B00111000; /* DDRH|=(1<<PH6)|(1<<PH5); */
  TCCR4A|=(1<<COM4A1)|(1<<WGM40);
  TCCR4B|=(1<<CS41)|(1<<CS40);
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  pinMode(s,INPUT);
  attachInterrupt(5, doA2, CHANGE);
  attachInterrupt(4, doB2, CHANGE);  
  lcd.begin(16, 2);
  //Serial.begin (9600); Serial.println("START READING");
}

void loop()
{ if(digitalRead(s)==HIGH)
{
   theta=count_2*(360.0/10000.0); /*variable to convert pulses to mechanical degrees*/
  error2= setpoint - theta;
  
  if(error2<=-20.0|error2>=20.0)
      { motorStop();
      } 
  if (error2>0)
  {  motor_CW();
     Voltage= Kp*error2; /*control signal*/
     OCR4A=Voltage;//analogWrite(pwm,Voltage);
     if(Voltage>255.0)
     {
       Voltage=255.0;
       OCR4A=Voltage;
     }
  } //motorStop(); 
  if(error2<0)
     { motor_CCW();
        Voltage= Kp*error2; /*control signal*/
       Voltage=Voltage*(-1.0);
       OCR4A=Voltage;//analogWrite(pwm,Voltage);
       if(Voltage>255.0)
     {
       Voltage=255.0;
       OCR4A=Voltage;//analogWrite(pwm,Voltage);
     }
       
     }  //motorStop();
   
     if(error2<=-20.0|error2>=20.0)
      { motorStop();
      }
      lcd_prints();
      lcd.clear();
   /*Serial.print(int(count_2));
  Serial.print(" theta = ");
  Serial.print(theta);
  Serial.print(", error2 = ");
  Serial.print(error2);
  Serial.print(", pot=");
  Serial.print(Voltage);
  Serial.println();*/
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
void lcd_prints()
{
  lcd.setCursor(0,0);
  lcd.print("P2=");
  lcd.setCursor(0,1);
  lcd.print("E2=");
  lcd.setCursor(9,0);
  lcd.print("P1=");
  lcd.setCursor(9,1);
  lcd.print("E1=");
  lcd.setCursor(3, 0);
  lcd.print(int(theta));
  lcd.setCursor(3,1);
  lcd.print(int(error2));
  
  delay(10);
}

