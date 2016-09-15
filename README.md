# Box demension

This project to measure the volume of boxes. 
Appliance designed for automation of warehouse. To implement it, I used:
- RaspberryPi.
- HC-SR04 sensor - 3 pcs.
- Piezo element.
- Power plug.
- Power switch button.
- Led.
- One europallet.

| HC-SR04   | GPIO/PIN  |
| :-------: |:---------:|
| Trigger X | 18/12     |
| Echo X    | 22/15     |
| Trigger Y | 17/11     |
| Echo Y    | 27/13     |
| Trigger Z | 23/16     |
| Echo Z    | 24/18     |

![alt text](https://github.com/jezman/box_demension/blob/master/img_proj.jpg "Breadboard")



###How it works:
Sensors attached to the pallet on the axes XYZ. 
The script is triggered when you receive a GET request. In response, it sends the size of the box.

###Install the packages to work with GPIO.
```bash
$ sudo apt-get update && sudo apt-get install python-dev python-rpi.gpio
```
####dimension.py

Configure GPIO
```python
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
```
Check sensors:
```python
def pin_check(trigger, echo):
    GPIO.setup(echo, GPIO.IN)
    pin = GPIO.wait_for_edge(echo, GPIO.RISING, timeout=500)
    if pin is None:
        volume.append(0)
    else:
        check_range(trigger, echo)
```
if all sensors is ok, starts dimension:
```python
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
```
if the sensors don't answer, sends zeros and alert(beep-beep):
```python
def beep(count, delay=0.3):
    GPIO.setup(BEEP_PIN, GPIO.OUT)
    for i in range(0, count):
        GPIO.output(BEEP_PIN, False)
        GPIO.output(BEEP_PIN, True)
sleep(delay)
```
```python
print("0;0;0")
beep(2)
```
sends data and beep:
```python
print("Content-Type: text/plain;charset=utf-8")
print()
volume = list(map(lambda x,y: x - y ,dafault_range, volume))
print(';'.join(map(str, volume)))
beep(1)
```
finnaly clear GPIO
```python
GPIO.cleanup()
```
