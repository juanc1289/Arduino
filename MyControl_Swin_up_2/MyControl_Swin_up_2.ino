/*PROGRAM TO CONTROL A FURUTA PENDULUM*/
#include <stdio.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <LiquidCrystal.h>
LiquidCrystal lcd(48, 49, 45, 44, 43, 42);
/*encoder pins*/
int A_2=18;
int B_2=19;
int A_1=20;
int B_1=21;
const int s=53;
volatile float count_2 =0.0;
volatile float count_1=0.0;
const float dt=0.6;
/*PID_1 gains*/
const float kp_1=5.0;
const float ki_1=0.0;//0.0*n;
const float kd_1=0.8;//0.5/n;
/*PID_2 gains*/
const float kp_2=40;//60.0;
const float ki_2=2;//4.0*n;
const float kd_2=2.0;//2.0/n;
long i=0;
int t=0;
float setpoint_theta=180;
float setpoint_alpha=0;
/*PID variables*/
volatile float alpha=0,error1=0,lastE1=0,Area_1=0,Int_E1=0,Der_E1=0,out1=0;
volatile float theta=0,error2=0,lastE2=0,Area_2=0,Int_E2=0,Der_E2=0,out2=0;

ISR(TIMER3_COMPA_vect)
{ sei();
digitalWrite(22,HIGH);
     theta=count_2*(360.0/10000.0);
     alpha=count_1*(360.0/(800));
    if (digitalRead(s)==HIGH)
      { 
        if(alpha>200 || alpha<-200){  // Protección, impide que el motor gire mas alla de lo que permite el cable
        motorStop();
        t=10;
        }
        /*
        Swim up
        t=0 es una perturbación inicial, luego, t=1, hace que el “brazo” del péndulo 
        vaya hacia la posición inicial y trata de evitar que salga de allí 
        (mini control proporcional), una vez el péndulo alcanza los 160 grados,
        comienza t=2 que es un control pid, sin realimentación, sobre el angulo
        del péndulo, y que se encarga de estabilizar la velocidad del péndulo, 
        luego cuando la velocidad del péndulo es cercana a cero y  el angulo del
        brazo es menor a 10 grados, inicia t=3 que es el control  pid sobre el 
        angulo del péndulo y retroalimentado con la señal de un  pid sobre el 
        angulo del brazo.  
            
        */
        
        if(t==0){              
           motor_CW();
           OCR4A=255.0-90;           
           if(theta<-35){          
             t=1;
           }
        }
    
        if(t==1){
           error1=alpha;
           out1=6*error1;        
          if (out1<0)
          {  out1=out1*(-1);
             if(out1>255){out1=255;}
             motor_CW();
             OCR4A=255.0-out1;
             out1=out1*(-1);
           }
          if (out1>0)
           { if(out1>255){out1=255;}
             motor_CCW();
             OCR4A=255.0-out1;
             }
          if (out1==0){
            motorStop();
             }
          if(theta>160){
          t=2;
          }
          
        }
        
         if(t==2){
        
           error1=alpha;
           Area_1=(100*lastE1+100*error1)*0.01*dt/2;
           Int_E1=(Area_1+Int_E1);
           Der_E1=(100*error1-100*lastE1)/dt;  
           out1=5*error1;
           
           theta=theta-out1/80;
      
           error2=theta-setpoint_theta;
           Area_2=(100*lastE2+100*error2)*0.01*dt/2;
           Int_E2=(Area_2+Int_E2);
           Der_E2=(100*error2-100*lastE2)/dt;  
           out2=kp_2*error2+ki_2*Int_E2+3*kd_2*Der_E2;
           if(Der_E2>-1 && Der_E2<1){
            i=1;
         }
         
        if(alpha>-10 && alpha<10 && i==1){
           t=3;
           }
        if (theta>150 && theta <210){   
          if (out2<0)
          {  out2=out2*(-1);
             if(out2>255){out2=255;}
             motor_CW();
             OCR4A=255.0-out2;
             out2=out2*(-1);
           }
          if (out2>0)
           { if(out2>255){out2=255;}
             motor_CCW();
             OCR4A=255.0-out2;
             }
          if (out2==0){
            motorStop();
             }
          }else{
            motorStop();
          }
          lastE1=error1;
          lastE2=error2;
      }         

        

        if(t==3){
        
           error1=alpha-setpoint_alpha;
           Area_1=(100*lastE1+100*error1)*0.01*dt/2;
           Int_E1=(Area_1+Int_E1);
           Der_E1=(100*error1-100*lastE1)/dt;  
           out1=kp_1*error1 + ki_1*Int_E1 + kd_1*Der_E1;
           
           theta=theta-out1/80;
      
           error2=theta-setpoint_theta;
           Area_2=(100*lastE2+100*error2)*0.01*dt/2;
           Int_E2=(Area_2+Int_E2);
           Der_E2=(100*error2-100*lastE2)/dt;  
           out2=kp_2*error2+ki_2*Int_E2+kd_2*Der_E2;
        if (theta>155 && theta <205){   
          if (out2<0)
          {  out2=out2*(-1);
             if(out2>255){out2=255;}
             motor_CW();
             OCR4A=255.0-out2;
             out2=out2*(-1);
           }
          if (out2>0)
           { if(out2>255){out2=255;}
             motor_CCW();
             OCR4A=255.0-out2;
             }
          if (out2==0){
            motorStop();
             }
          }else{
            motorStop();
            //t=1;
          }
          lastE1=error1;
          lastE2=error2;
      }
 }else{
        motorStop();
        Int_E2=0;
        Int_E1=0;}
digitalWrite(22,LOW);
}
void setup()
{//Serial.begin(9600);
  pinMode(s,INPUT);
  pinMode(22,OUTPUT);
  /*channels A and B as inputs*/
  pinMode(A_2, INPUT); 
  pinMode(B_2, INPUT);
  pinMode(A_1, INPUT); 
  pinMode(B_1, INPUT);
  /*to read encoder*/
  attachInterrupt(5, doA2, CHANGE);
  attachInterrupt(4, doB2, CHANGE);
  attachInterrupt(3, doA1, CHANGE);
  attachInterrupt(2, doB1, CHANGE);
  lcd.begin(16,2);
  /*pins to H-bridge as outputs*/
  DDRH=DDRH|B00111000;//PH5=D PH4=B PH3=P
  TCCR4A|=(1<<COM4A1)|(1<<WGM40);
  TCCR4B=0x02;//TCCR4B|=(1<<CS41)|(1<<CS40);
  /*to set ISR*/
  TCCR3A=0;
  TCCR3B=0;
  OCR3A=32000*dt;
  TCCR3B |= (1<<WGM32);
  TCCR3B |= (0<<CS30);
  TCCR3B |= (1<<CS31);
  TIMSK3=(1<<OCIE3A);
  sei();
  message();
// Serial.begin(9600);
}
void loop()
{

  if (digitalRead(s)==HIGH)
 { lcd.clear();
   lcd_prints();}
   lcd.clear();

/*
 Serial.print("theta= ");
 Serial.print(theta);
 Serial.print(", alpha= ");
 Serial.print(alpha);
 Serial.print(", E1= ");
 Serial.print(int(error1));
 Serial.print(", E2= ");
 Serial.print(int(error2));
 Serial.print(" I1= ");
 Serial.print(Int_E1);
 Serial.print(" I2= ");
 Serial.print(Int_E2);
 Serial.print(" D1= ");
 Serial.print(Der_E1);
 Serial.print(" D2= ");
 Serial.print(Der_E2);
 Serial.print(" out1= ");
 Serial.print(out1);
 Serial.print(" out2= ");
 Serial.println(out2);
*/

}


void doA1(){
  // look for a low-to-high on channel A
  if (digitalRead(A_1) == HIGH) { 
    // check channel B to see which way encoder is turning
    if (digitalRead(B_1) == LOW) {  
      count_1 = count_1 + 1;         // CW
    } 
    else {
      count_1 = count_1 - 1;         // CCW
    }
  }
  else   // must be a high-to-low edge on channel A                                       
  { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(B_1) == HIGH) {   
      count_1 = count_1 + 1;          // CW
    } 
    else {
      count_1 = count_1 - 1;          // CCW
    }
  }
 }
void doB1(){
  // look for a low-to-high on channel B
  if (digitalRead(B_1) == HIGH) {   
   // check channel A to see which way encoder is turning
    if (digitalRead(A_1) == HIGH) {  
      count_1 = count_1 + 1;         // CW
    } 
    else {
      count_1 = count_1 - 1;         // CCW
    }
  }
  // Look for a high-to-low on channel B
  else { 
    // check channel B to see which way encoder is turning  
    if (digitalRead(A_1) == LOW) {   
      count_1 = count_1 + 1;          // CW
    } 
    else {
      count_1 = count_1 - 1;          // CCW
    }
  }
}

void doA2(){
  //  digitalWrite(28,HIGH);
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
//  digitalWrite(28,LOW);
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
	PORTH=0x10;
}
void motor_CW()
{
	PORTH=0x30;
}
void motorStop()
{
	PORTH=0x28;
}
void lcd_prints()
{
  lcd.setCursor(0,0);
  lcd.print("alpha= ");
  lcd.setCursor(6, 0);
  lcd.print(alpha);
  lcd.setCursor(0,1);
  lcd.print("theta=");
  lcd.print(theta);
  delay(150);
}

void message()
{
  lcd.setCursor(2,0);
  lcd.print("WELLCOME TO");
  delay(1500);
  lcd.clear();
  lcd.setCursor(1,1);
  lcd.print("CONTROL LAB OF");
  delay(1500);
  lcd.clear();
  lcd.setCursor(1,0);
  lcd.print("FURUTA PENDULUM");
  delay(1500);
  
}

float Abs(float x){
if(x<0){
x=-x;
}
return x;
}

