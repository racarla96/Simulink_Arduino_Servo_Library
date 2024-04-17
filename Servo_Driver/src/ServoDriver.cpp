//ServoDriver.cpp
#include <Arduino.h>
#include <Servo.h>
#include "ServoDriver.h"   

Servo servos[8];
int global_id = 0;

extern "C" void ServoDriver_Init(int32_t* id, int32_t pin)
{ 
    servos[global_id].attach(pin);
    *id = global_id;
    global_id++;
} 

extern "C" void ServoDriver_Step(int32_t id, int32_t us, int32_t min_us, int32_t max_us) 
{ 
    if (us < min_us) us = min_us;
    if (us > max_us) us = max_us;
    servos[id].writeMicroseconds(us);
} 

extern "C" void ServoDriver_Terminate() 
{
    
} 