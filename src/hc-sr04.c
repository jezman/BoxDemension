#define BEEP 27
#include <wiringPi.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "buzzer.h" 

static int ping(TRIG, ECHO, DEF_RANGE) {
	long ping      = 0;
	long pong      = 0;
	float distance = 0;
 	long timeout   = 500000; // 0.5 sec ~ 171 m

	pinMode(TRIG, OUTPUT);
	pinMode(ECHO, INPUT);

	// Ensure trigger is low.
	digitalWrite(TRIG, LOW);
	delay(50);

	// Trigger the ping.
	digitalWrite(TRIG, HIGH);
	delayMicroseconds(10); 
	digitalWrite(TRIG, LOW);

	// Wait for ping response, or timeout.
  int response(SET) {
		while (digitalRead(ECHO) == SET && micros() < timeout) {
		}

		// Cancel on timeout.
		if (micros() > timeout) {
			printf("0\n");
			buzzer(1);
			return 0;
		}
	}

	response(LOW);
	ping = micros();

  response(HIGH);
	pong = micros();

	// Convert ping duration to distance.
	distance = (float) DEF_RANGE - ((pong - ping) * 0.017150);

	printf("%.2f\n", distance);

	return 1;
}

int main () {
//	printf ("Content-Type: text/plain;charset=utf-8\n");

	if (wiringPiSetup () == -1) {
		exit(EXIT_FAILURE);
	        buzzer(1);
        }

	if (setuid(getuid()) < 0) {
		perror("Dropping privileges failed.\n");
	        buzzer(1);
		exit(EXIT_FAILURE);
	}

	// x, y, z
	int TRIG[3] = {1, 0, 4};
	int ECHO[3] = {3, 2, 5};
	int DEF_RANGE[3] = {103, 104, 119};

	ping(TRIG[0], ECHO[0], DEF_RANGE[0]);
	ping(TRIG[1], ECHO[1], DEF_RANGE[1]);
	ping(TRIG[2], ECHO[2], DEF_RANGE[2]);
	buzzer(1);
	return 0;
}
