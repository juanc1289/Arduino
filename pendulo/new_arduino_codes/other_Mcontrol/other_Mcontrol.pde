/*another motot control*/
#define E1 10 
#define I1 9 
#define I2 8
void setup()
{
  pinMode(E1,OUTPUT);
  pinMode(I1,OUTPUT);
  pinMode(I2,OUTPUT);
}
void loop()
{
  if (motor(50)>0)
    {
      E1=HIGH;
      IN1=HIGH;
      IN2=LOW;
      analogWrite(E1,motor(50));
    }
  if(motor(50)<0)
    {
      E1=1;
      IN1=0;
      IN2=0;
      analogWrite(E1,motor(50));
    }
  if(motor(50)==0)
    {
      E1=0;
      IN1=0;
      IN2=0;
    }
}
int motor (int velocity)
{
 velocity=50; 
}
