//Lucas Pinheiro Nepomuceno - 1611079
//Danillo Catalao - 1320966

#include "event_driven.h"
#include "app.h"
#include "pindefs.h"

int state = 1;
double tim = 1000;

void appinit()
{
  timer_set(tim);
  button_listen(KEY1);
  button_listen(KEY2);
}


void timer_expired()
{
  state = !state;
  digitalWrite(LED1, state);
}

void button_changed(int pin, int v)
{
  if (pin==KEY1)
  {
    tim/=2;
    timer_set(tim);
  }
  
  if (pin==KEY2)
  {
    tim*=2;
    timer_set(tim);
  }
  
  if(v == 1)
  {
        Serial.println("tchau");
    digitalWrite(LED1,LOW);
    while(1);
  }
}

