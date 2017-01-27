int buzzer(int argc, char *argv[]) {
	if(wiringPiSetup() == -1){
	printf("setup wiringPi failed !");
	return 1;
	}

	if (argc != 2) {
		int COUNT = 1;
	} else {
		int COUNT = atoi(argv[1]);
	}

	pinMode(BEEP, OUTPUT);
	int repeat = 1;
	
	while(repeat <= COUNT) {
		int timer = 200;
		while(timer != 0) {
			digitalWrite(BEEP, HIGH);
			delayMicroseconds(200);
			digitalWrite(BEEP, LOW);
			delayMicroseconds(200);
			timer--;
		}
	delay(50);
	repeat++;
	}	
return 0;
}

