#!/usr/bin/env python

import RPi.GPIO as GPIO
from time import sleep, time

BEEP_PIN = 16

TRIG_X = 18
ECHO_X = 22
TRIG_Y = 17
ECHO_Y = 27
TRIG_Z = 23
ECHO_Z = 24


GPIO.setmode(GPIO. BCM)
GPIO.setwarnings(False)

default_range = (103, 104, 119)
volume = []

def beep(count, delay=0.3):
    GPIO.setup(BEEP_PIN, GPIO.OUT)
    for i in range(0, count):
        GPIO.output(BEEP_PIN, False)
        GPIO.output(BEEP_PIN, True)
        sleep(delay)


def pin_check(trigger, echo):
    GPIO.setup(echo, GPIO.IN)
    pin = GPIO.wait_for_edge(echo, GPIO.RISING, timeout=500)
    if pin is None:
        volume.append(0)
    else:
        check_range(trigger, echo)


def check_range(trigger, echo):
    GPIO.setup(trigger, GPIO.OUT)
    GPIO.output(trigger, False)

    sleep(0.1)

    GPIO.output(trigger, True)
    sleep(0.00001)
    GPIO.output(trigger, False)

    while GPIO.input(echo) == 0:
        pulse_start = time()

    while GPIO.input(echo) == 1:
        pulse_end = time()

    volume.append(round(((pulse_end - pulse_start) * 17570), 2))


try:
    pin_check(TRIG_X, ECHO_X)
    pin_check(TRIG_Y, ECHO_Y)
    pin_check(TRIG_Z, ECHO_Z)

    print("Content-Type: text/plain;charset=utf-8")
    print()

    volume = list(map(lambda x,y: x - y ,dafault_range, volume))
    print(';'.join(map(str, volume)))
    beep(1)
except:
    print("0;0;0")
    beep(2)
finally:
GPIO.cleanup()
