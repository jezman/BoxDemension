# Box demension

This project to measure the volume of boxes. 
Appliance designed for automation of warehouse. To implement it, I used:
- RaspberryPi.
- [HC-SR04 sensor](http://www.micropik.com/PDF/HCSR04.pdf) - 3 pcs.
- Piezo element.
- Power plug.
- Power switch button.
- Led.
- Resistor 4.7kΩ - 3 pcs.
- Resistor 10kΩ -3 pcs.
- One europallet.

| HC-SR04   | GPIO/PIN/wiringPi  |
| :-------: |:---------:|
| Trigger X | 18/12/1     |
| Echo X    | 22/15/3     |
| Trigger Y | 17/11/0    |
| Echo Y    | 27/13/2     |
| Trigger Z | 23/16/4   |
| Echo Z    | 24/18/5     |

---
The ECHO output is of 5v. The input pin of Raspberry Pi GPIO is rated at 3.3v. So 5v cannot be directly given to the unprotected 3.3v input pin. Therefore we use a voltage divider circuit using appropriate resistors to bring down the voltage to 3.3V.

## Breadboard
![alt text](https://rawgit.com/jezman/box-demension/master/breadboard.jpg "Breadboard")



### How it works:
Sensors attached to the pallet on the axes XYZ. 
The script is triggered when you receive a GET request. In response, it sends the size of the box.
