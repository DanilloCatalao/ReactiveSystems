#define LED_PIN 13
#define KEY1 A1
#define KEY2 A2
#define KEY3 A3

int state = 1;
float delayTime = 1000;
unsigned long old;
int but1pressed;
int but2pressed;
int but1delay = 1000;
int but2delay = 1000;
unsigned long but1old;
unsigned long but2old;

void setup() {
  // put your setup code here, to run once:
  pinMode(LED_PIN, OUTPUT);
  pinMode(KEY1, INPUT_PULLUP);
  pinMode(KEY2, INPUT_PULLUP);
  pinMode(KEY3, INPUT_PULLUP);
  Serial.begin(9600);
  
  but1pressed = 1000 + millis();
  but2pressed = millis();
}

void loop() {
  // put your main code here, to run repeatedly:
  unsigned long now = millis();
  int but1 = digitalRead(KEY1);
  int but2 = digitalRead(KEY2);
  int but3 = digitalRead(KEY3);
  if((now >= but1old + but1delay) && (but1 == 0)){
    delayTime /= 2.0;
    but1pressed = now;
    Serial.print('a');
    Serial.print(delayTime);
    Serial.print('\n');
    but1old = now;
  }
    
    
  if((now >= but2old + but2delay) && (but2 == 0)){
    delayTime *= 2;
    but2pressed = now;
    Serial.print('b');
    Serial.print(delayTime);
    Serial.print('\n');
    but2old = now;
  }
  
  if (now >= old + delayTime){
    old = now;
    state = !state;
    digitalWrite(LED_PIN, state);
  }
  
  int interval = abs(but1pressed - but2pressed);
  //Serial.println(interval);
  
  if(interval <= 500){
    while(1);
  }
  
}
