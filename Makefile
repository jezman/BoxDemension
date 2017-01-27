hc-rs04: hc-sr04.c fcgi.cpp
		gcc -lwiringPi -o hc-sr04 src/hc-sr04.c
		g++ -lfcgi++ -lfcgi -o fcgi src/fcgi.cpp
install:
		cp fcgi /usr/bin/fcgi
		cp hc-sr04 /usr/bin/hc-sr04
		echo "spawn-fcgi -p 8000 -n fcgi&" > /etc/init.d/fcgi
		chmod 700 /usr/bin/fcgi /usr/bin/hc-sr04 /etc/init.d/fcgi
		cat <(crontab -l) <(echo "0-59 * * * * [[ -n $(pidof fcgi) ]] || sudo spawn-fcgi -p 8000 -n fcgi&") | crontab -
uninstall: 
		rm -f /usr/bin/fcgi
		rm -f /usr/bin/hc-sr04
		rm -f /etc/init.d/fcgi
