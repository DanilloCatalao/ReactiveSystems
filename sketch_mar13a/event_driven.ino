//Lucas Pinheiro Nepomuceno - 1611079
//Danillo Catalao - 1320966

#include "event_driven.h"
#include "app.h"
#include "pindefs.h"

unsigned int timer = 10000;
unsigned long lastTime = -timer;
unsigned int clickCD = 3000;
unsigned long lastClick = -clickCD;

int regbut[2];
int lastreg = 0;

int buttonOnePressed = 10000;
int buttonTwoPressed = 20000;


void setup() {
  Serial.begin(9600);
   pinMode(LED1,OUTPUT);
  pinMode(KEY1, INPUT_PULLUP);
  pinMode(KEY2, INPUT_PULLUP);
  pinMode(KEY3, INPUT_PULLUP);
  appinit();
 
}

void loop() {
  
  unsigned long now = millis();
  if (now - lastTime > timer)
  {
    lastTime = now;
    timer_expired();
  }
  
  if(!digitalRead(regbut[0]))
  {
    buttonOnePressed = now;
  }
  
  if(!digitalRead(regbut[1]))
  {
    buttonTwoPressed = now;
  }
  
  if(now - lastClick > clickCD)
  {
    if(!digitalRead(regbut[0]))
    {
      lastClick = now;
      button_changed(regbut[0], 0);
    }
    
    if(!digitalRead(regbut[1]))
    {
      lastClick = now;
      button_changed(regbut[1], 0);
    }
  }
  
  if (abs(buttonOnePressed - buttonTwoPressed) < 500)
  {
    Serial.println("oi");
    button_changed(-100, 1);
  }
  
}

void button_listen (int pin)
{
  regbut[lastreg] = pin;
  lastreg++;
}
void timer_set (int ms)
{
  timer = ms;
}
