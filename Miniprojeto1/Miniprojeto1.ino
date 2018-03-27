
// Danillo Catalao 1320966
// Lucas Pinheiro  1611079


/* Define shift register pins used for seven segment display */
#define LATCH_DIO 4
#define CLK_DIO 7
#define DATA_DIO 8
#define BUTTON1 A1
#define BUTTON2 A2
#define BUTTON3 A3
#define LED1       10
#define LED2       11
#define LED3       12
#define LED4       13
#define BUZZ        3
#define BUT_DELAY 300

#define ON 1
#define OFF 0

/* Segment byte maps for numbers 0 to 9 */
const byte SEGMENT_MAP[] = {0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0X80, 0X90};
/* Byte maps to select digit 1 to 4 */
const byte SEGMENT_SELECT[] = {0xF1, 0xF2, 0xF4, 0xF8};
enum STATE {
  NORMAL,
  SETTIME,
  SETALARM,
  SOUNDALARM
};


void SetAlarmState();
void SetTimeState();
void NormalState();
void WriteNumberToSegment(byte Segment, byte Value);
void CheckAlarm();
void UpdateTime();

void WriteSeg1(int hora);
void WriteSeg2(int hora);
void WriteSeg3(int minuto);
void WriteSeg4(int minuto);




unsigned long currentTime; // Stores the current time in ms
unsigned long lastTime; // Stores the last time in ms the counter was last updated
unsigned long lastBleep= 0;
int hora; // Stores the value that will be displayed
int minuto; // Stores the value that will be displayed
int horaAlarme;
int minutoAlarme;
STATE currentState = NORMAL;
int on = 1;
int lastPress;
int digitPos = 0;
int alarme = 0;
int soundAlarm = 0;
int show = 0;





void setup ()
{
  pinMode(LED1, OUTPUT);
  pinMode(LATCH_DIO, OUTPUT);
  pinMode(CLK_DIO, OUTPUT);
  pinMode(DATA_DIO, OUTPUT);
  pinMode (BUTTON1, INPUT_PULLUP);
  pinMode (BUTTON2, INPUT_PULLUP);
  pinMode(BUTTON3, INPUT_PULLUP);
  Serial.begin(9600);
  
  digitalWrite(LED1,ON);

  currentTime = millis();
  lastTime = 0;
  hora = 15;
  minuto = 50;
  horaAlarme = 15;
  minutoAlarme = 53;
}
 
/* Main program */
void loop()
{
  CheckAlarm();
  UpdateTime();
  
  
  if (currentState == NORMAL)
  {
    //Serial.println("Estado Normal");
    NormalState();

  }
  else if (currentState == SETALARM)
  {
    //Serial.println("Estado Setar Alarme");
    
    
    WriteSeg1(horaAlarme);
    WriteSeg2(horaAlarme);
    WriteSeg3(minutoAlarme);
    WriteSeg4(minutoAlarme);
    
    SetAlarmState();
  }
  else if (currentState == SETTIME)
  {
    //Serial.println("Estado Setar Tempo");
    SetTimeState();
  }
}
 
/* Write a decimal number between 0 and 9 to one of the 4 digits of the display */
void WriteNumberToSegment(byte Segment, byte Value)
{
  digitalWrite(LATCH_DIO,LOW);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_MAP[Value]);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_SELECT[Segment] );
  digitalWrite(LATCH_DIO,HIGH);
}

void UpdateTime()
{
  currentTime = millis();

  
  if (currentState != SETTIME)
  {
    if (currentTime - lastTime > 60000) 
    {
      //passou-se 1 minuto
      lastTime = currentTime;
      minuto++;
      if (minuto > 59)
      {
        minuto = 0;
        hora++;
        if (hora > 23)
        {
          hora = 0;
        }
      }
    }
  }
  
    if(currentState == SETTIME)
    {
      
      if ((millis()/1000)%2 > 0)
      {
       switch (digitPos)
        {
          case 0:
            WriteSeg1(hora);
            break;
          case 1:
            WriteSeg2(hora);
            break;
          case 2:
            WriteSeg3(minuto);                      
            break;
          case 3:
            WriteSeg4(minuto);          
            break;
        }
      }
      
      switch (digitPos)
        {
          case 0:
            WriteSeg2(hora);
            WriteSeg3(minuto);
            WriteSeg4(minuto);            
            break;
          case 1:
            WriteSeg1(hora);
            WriteSeg3(minuto);
            WriteSeg4(minuto);                      
            break;
          case 2:
            WriteSeg1(hora);
            WriteSeg2(hora);            
            WriteSeg4(minuto);                      
            break;
          case 3:
            WriteSeg1(hora);
            WriteSeg2(hora);            
            WriteSeg3(minuto);          
            break;
        }
      

    } 
    else if(currentState == SETALARM)
    {
      if ((millis()/1000)%2 > 0)
      {
       switch (digitPos)
        {
          case 0:
            WriteSeg1(horaAlarme);
            break;
          case 1:
            WriteSeg2(horaAlarme);
            break;
          case 2:
            WriteSeg3(minutoAlarme);                      
            break;
          case 3:
            WriteSeg4(minutoAlarme);          
            break;
        }
      }
      
      switch (digitPos)
      {
          case 0:
            WriteSeg2(horaAlarme);
            WriteSeg3(minutoAlarme);
            WriteSeg4(minutoAlarme);            
            break;
          case 1:
            WriteSeg1(horaAlarme);
            WriteSeg3(minutoAlarme);
            WriteSeg4(minutoAlarme);                      
            break;
          case 2:
            WriteSeg1(horaAlarme);
            WriteSeg2(horaAlarme);            
            WriteSeg4(minutoAlarme);                      
            break;
          case 3:
            WriteSeg1(horaAlarme);
            WriteSeg2(horaAlarme);            
            WriteSeg3(minutoAlarme);          
            break;
      }
      
    } 
    else
    {
      WriteSeg1(hora);
      WriteSeg2(hora);
      WriteSeg3(minuto);
      WriteSeg4(minuto);      
    }
    
}

void WriteSeg1(int hora)
{
  WriteNumberToSegment(0 , hora / 10);
}

void WriteSeg2(int hora)
{
  WriteNumberToSegment(1 , hora % 10);
}

void WriteSeg3(int minuto)
{
  WriteNumberToSegment(2 , minuto / 10);
}

void WriteSeg4(int minuto)
{
  WriteNumberToSegment(3 , minuto % 10);
}

void NormalState()
{
  int curPress;

  curPress = millis();
  if (curPress - lastPress > BUT_DELAY)
  {
    lastPress = curPress;
    if (!digitalRead(BUTTON1))
    {
      currentState = SETTIME;
    }
    if (!digitalRead(BUTTON2))
    {
      alarme = !alarme;
      digitalWrite(LED1, alarme);
    }
    if (!digitalRead(BUTTON3))
    {
    }
  }
}

void SetAlarmState()
{
  
  int digits[4];
  int curPress;

  digits[0] = horaAlarme / 10;
  digits[1] = horaAlarme % 10;
  digits[2] = minutoAlarme / 10;
  digits[3] = minutoAlarme % 10;

  curPress = millis();
  if (curPress - lastPress > BUT_DELAY)
  {
    lastPress = curPress;
    if (!digitalRead(BUTTON1))
    {
      alarme = ON;
      minutoAlarme = digits[2] * 10 + digits[3];
      horaAlarme = digits[0] * 10 + digits[1];
      currentState = NORMAL;
    }
    if (!digitalRead(BUTTON2))
    {
      digitPos++;
      if (digitPos > 3)
        digitPos = 0;
    }
    if (!digitalRead(BUTTON3))
    {

      digits[digitPos]++;
      switch (digitPos) {
        case 0:
          if ( digits[digitPos] > 2 ) {
            digits[digitPos] = 0;
          }

          horaAlarme = digits[0] * 10 + digits[1];
          break;
        case 1:
          if ( digits[digitPos] > 9 ) {
            digits[digitPos] = 0;
          }
          if ( digits[0] == 2 && digits[digitPos] > 3 ) {
            digits[digitPos] = 0;
          }
          horaAlarme = digits[0] * 10 + digits[1];
          break;
        case 2:
          if ( digits[digitPos] > 5 ) {
            digits[digitPos] = 0;
          }
          minutoAlarme = digits[2] * 10 + digits[3];
          break;
        case 3:
          if ( digits[digitPos] > 9 ) {
            digits[digitPos] = 0;
          }
          minutoAlarme = digits[2] * 10 + digits[3];
          break;
      }

    }
  }
}

void SetTimeState()
{

  int digits[4];
  int curPress;

  digits[0] = hora / 10;
  digits[1] = hora % 10;
  digits[2] = minuto / 10;
  digits[3] = minuto % 10;

  curPress = millis();
  if (curPress - lastPress > BUT_DELAY)
  {
    lastPress = curPress;
    if (!digitalRead(BUTTON1))
    {
      minuto = digits[2] * 10 + digits[3];
      hora = digits[0] * 10 + digits[1];
      currentState = SETALARM;
    }
    if (!digitalRead(BUTTON2))
    {
      digitPos++;
      if (digitPos > 3)
        digitPos = 0;
    }
    if (!digitalRead(BUTTON3))
    {

      digits[digitPos]++;
      switch (digitPos) {
        case 0:
          if ( digits[digitPos] > 2 ) {
            digits[digitPos] = 0;
          }          
          if (digits[1] > 3)
          {
            if (digits[digitPos]>1)
            {
              digits[digitPos] = 0;
            }
          }
          hora = digits[0] * 10 + digits[1];
          break;
        case 1:
          if ( digits[digitPos] > 9 ) 
          {
            digits[digitPos] = 0;
          }
          
          if ( digits[0] == 2 && digits[digitPos] > 3 ) 
          {
            digits[digitPos] = 0;
          }
          
          hora = digits[0] * 10 + digits[1];
          break;
        case 2:
          if ( digits[digitPos] > 5 ) {
            digits[digitPos] = 0;
          }
          minuto = digits[2] * 10 + digits[3];
          break;
        case 3:
          if ( digits[digitPos] > 9 ) {
            digits[digitPos] = 0;
          }
          minuto = digits[2] * 10 + digits[3];
          break;
      }
    }
  }
}



void CheckAlarm()
{

  int curPress;
  bool press = false;

  curPress = millis();
  if (curPress - lastPress > BUT_DELAY)
  {
    lastPress = curPress;
    if (!digitalRead(BUTTON1))
    {
      press = true; //Serial.println("Apertou o botão 1");
    }
    if (!digitalRead(BUTTON2))
    {
      press = true; //Serial.println("Apertou o botão 2");
    }
    if (!digitalRead(BUTTON3))
    {
      press = true; //Serial.println("Apertou o botão 3");
    }
  }

  if (press == true)
  {
    soundAlarm = OFF;
    alarme = OFF;
    currentState = NORMAL;
    tone(BUZZ,0);
    press=false;
  }

  if (alarme == ON)
  {
    if (hora == horaAlarme && minuto == minutoAlarme)
    {
      soundAlarm = ON;
      currentState = SOUNDALARM;
    }
  }

  if (soundAlarm == ON)
  {
    for (int x = 0; x < 180; x++)
    {
      double freq;
      freq = (sin(x * 3.1416 / 180));
      freq = 2000 + ( freq * 1000 );
      tone(BUZZ,freq);
      delay(2);
    }
    
  }
  
}

