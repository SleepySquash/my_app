#include <Servo.h>
#include "RTClib.h"

// Утро
#define HALL1_PIN 19
#define SERVO1_PIN 6

#define HALL2_PIN 15
#define SERVO2_PIN 9

#define HALL3_PIN 18
#define SERVO3_PIN 5

// Ночь
#define HALL4_PIN 14
#define SERVO4_PIN 10

// #define DEBUG 1

struct Event {
  bool type = false; // 0 = open, 1 = close
  int index = 0;
  int addedSeconds = 0;
  Event* next = nullptr;
  DateTime when;
};

Servo servo[4];
RTC_DS1307 rtc;

String inData = "";
Event* events = nullptr;
bool requestEvents = true;

bool hall[4] = { HIGH };

bool closeOnNextHall = false;
bool onHallClose[4] = { false };

bool defaultClosed = true;
bool servoClosed[4] = { defaultClosed, defaultClosed, defaultClosed, defaultClosed };
void setup()
{
  Serial.begin(9600);
  
#ifdef DEBUG
  while (!Serial); // Если Native USB, то ждём открытия Serial
#endif

  Serial.println("Serial serial started at 9600");

  if (!rtc.begin()) { Serial.println("Couldn't find RTC"); while (1); }
  if (!rtc.isrunning()) {
    Serial.println("RTC is NOT running!");
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  }

  Serial1.begin(9600);

  pinMode(HALL1_PIN, INPUT);
  pinMode(HALL2_PIN, INPUT);
  pinMode(HALL3_PIN, INPUT);
  pinMode(HALL4_PIN, INPUT);
  
  servo[0].attach(SERVO1_PIN); servo[0].write(defaultClosed ? 90 : 0); delay(500);
  servo[1].attach(SERVO2_PIN); servo[1].write(defaultClosed ? 0 : 90); delay(500);
  servo[2].attach(SERVO3_PIN); servo[2].write(defaultClosed ? 0 : 90); delay(500);
  servo[3].attach(SERVO4_PIN); servo[3].write(defaultClosed ? 90 : 0); delay(500);
}

void open(const int& index) {
  switch (index) {
    default: servo[index].write( 0); break;
    case 1:  servo[index].write(90); break;
    case 2:  servo[index].write(90); break;
    case 3:  servo[index].write( 0); break;
  }
  servoClosed[index] = false;
}

void close(const int& index) {
  switch (index) {
    default: servo[index].write(90); break;
    case 1:  servo[index].write( 0); break;
    case 2:  servo[index].write( 0); break;
    case 3:  servo[index].write(90); break;
  }
  servoClosed[index] = true;
}

bool sleeping = false;
int sleepCycles = 0;
void loop()
{
  while (Serial.available() > 0) Serial1.write(Serial.read());
  while (Serial1.available() > 0)
  {
    char symbol = Serial1.read();
    
    // Считываем по символу до тех пор, пока не встретим \n - признак, что передача завершена
    if (symbol <= 31) {
      Serial.println("Data available: " + inData);
      
           if (inData == "o1")  open(0);
      else if (inData == "c1") close(0);
      else if (inData == "o2")  open(1);
      else if (inData == "c2") close(1);
      else if (inData == "o3")  open(2);
      else if (inData == "c3") close(2);
      else if (inData == "o4")  open(3);
      else if (inData == "c4") close(3);
      else if (inData == "o") {  open(0); delay(500);  open(1); delay(500);  open(2); delay(500);  open(3); delay(500); }
      else if (inData == "c") { close(0); delay(500); close(1); delay(500); close(2); delay(500); close(3); delay(500); }
      else if (inData[0] == 't') {
        int _year = inData.substring(1, 5).toInt();
        int _month = inData.substring(5, 7).toInt();
        int _day = inData.substring(7, 9).toInt();
        int _hour = inData.substring(9, 11).toInt();
        int _minute = inData.substring(11, 13).toInt();
        int _second = inData.substring(13, 15).toInt();
        Serial.println("Date:  " + String(_year) + " " + String(_month) + " " + String(_day) + " " + String(_hour) + " " + String(_minute) + " " + String(_second));
        rtc.adjust(DateTime(_year, _month, _day, _hour, _minute, _second));

        if (requestEvents) {
          Serial1.write("e");
          Serial.println("events requested");
        }
      }
      else if (inData[0] == 'e') {
        requestEvents = false;

        Event* e = events;
        while (e != nullptr) {
          Event* next = e->next;
          delete e;
          e = next;
        }
        events = nullptr;

        DateTime now = rtc.now();
        if (inData.length() >= 8) {
          for (int i = 0; i < inData.length(); i += 8) {
            if (inData[i] == 'e') {
              int _index = inData.substring(i + 1, i + 2).toInt();
              int _hour = inData.substring(i + 2, i + 4).toInt();
              int _minute = inData.substring(i + 4, i + 6).toInt();
              int _repeat = inData.substring(i + 6, i + 8).toInt();
              Serial.println("Event[" + String(_index) + "] parsed with: " + String(_hour) + " " + String(_minute) + " " + String(_repeat) + " ");
  
              Event* event = new Event;
              if (!events) events = event; else e->next = event;
              event->when = DateTime(now.year(), now.month(), now.day(), _hour, _minute, 0);
              event->addedSeconds = _repeat * 60;
              event->index = _index;
              // TODO: if now() > when (but not in addedSeconds) => now.day() += 1
              e = event;
            }
          }
        }
      }
      else if (inData == "Q") {
        Event* e = events;
        while (e != nullptr) {
          Event* next = e->next;
          delete e;
          e = next;
        }
        events = nullptr;
      }
      else if (inData == "T") {
        DateTime now = rtc.now();
        Serial.println("Current time:  " + String(now.year()) + " " + String(now.month()) + " " + String(now.day()) + " " + String(now.hour()) + " " + String(now.minute()) + " " + String(now.second()));
      } 
      
      inData = "";
    } else {
      inData += String(symbol);
      if (inData == "OK+CONN" || inData == "OK+LOST") {
        Serial.println("Command available: " + inData);
        inData = "";
      }
    }
  }

  // Датчик Холла
  //if (closeOnNextHall)
  for (int i = 0; i < 4; i++)
  {
    int val;
    switch (i) {
      default: val = digitalRead(HALL1_PIN); break;
      case 1:  val = digitalRead(HALL2_PIN); break;
      case 2:  val = digitalRead(HALL3_PIN); break;
      case 3:  val = digitalRead(HALL4_PIN); break; }
    if (val != hall[i]) { hall[i] = val;
      if (onHallClose[i] && !val) { close(i); onHallClose[i] = false; }
      if (!servoClosed[i]) {
        if (val) { /*String str = "h1" + String(i); Serial1.write(str.c_str()); Serial.println(str);*/ }
            else
            {
              switch (i) {
                default: Serial1.write("h0"); break;
                case 1:  Serial1.write("h1"); break;
                case 2:  Serial1.write("h2"); break;
                case 3:  Serial1.write("h3"); break;
              }
            }
      }
      Serial.println("hall" + String(i) + ": " + String(hall[i]));
    }
  }

  if (sleepCycles % 20 == 0) {
    DateTime now = rtc.now();
    //printDateTime(now); Serial.print("\n");

    Event* e = events;
    while (e != nullptr) {
      if (now >= e->when) {
        bool slept = false;
        if (e->type) e->when = DateTime(now.year(),
                                        now.month(),
                                        now.day() + 1,
                                        e->when.hour(),
                                        e->when.minute(),
                                        0);
        else {
          DateTime when = e->when;
          when = when + TimeSpan(e->addedSeconds);
          if (now >= when) {
            slept = true;
            e->when = DateTime(now.year(),
                               now.month(),
                               now.day() + 1,
                               e->when.hour(),
                               e->when.minute(),
                               0);
          }
          else e->when = when;
        }
        Serial.println("e->when " + String(e->type) + " triggered and will be activated: ");
        printDateTime(e->when); Serial.print(" at this time.\n");

        if (!slept)
        {
          e->type = !e->type;
          if (!e->type) {
            if (!hall[e->index]) close(e->index);
            else onHallClose[e->index] = true;
          }
          else { open(e->index); onHallClose[e->index] = false; }
        }
      }
      e = e->next;
    }
  }

  if (sleeping) { delay(1000); sleepCycles += 20; }
  else { delay(50); sleepCycles += 1; }
}



#define countof(a) (sizeof(a) / sizeof(a[0]))
void printDateTime(const DateTime& dt) {
    char datestring[20];
    snprintf_P(datestring, 
            countof(datestring),
            PSTR("%02u/%02u/%04u %02u:%02u:%02u"),
            dt.month(), dt.day(), dt.year(),
            dt.hour(), dt.minute(), dt.second() );
    Serial.print(datestring);
}
