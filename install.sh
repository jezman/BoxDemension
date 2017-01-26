#/bin/bash

# Run script as sudo!
if [ "$EUID" -ne 0 ]
  then echo "Are you f*cking crazy??? USE SUDO..."
  exit
fi


zabbix_agent_conf=/etc/zabbix/zabbix_agentd.conf
rules=/etc/iptables/rules.v4

# Create temporary directory
DIR=/tmp/distrib
mkdir $DIR
cd $DIR

# Install packages
apt-get update -y
apt-get install libfcgi-dev spawn-fcgi nginx vim iptables-persistent htop iftop \
                iotop ethtool lm-sensors tmux curl zabbix-agent wpa-supplicant fail2ban git -y

# Install wiringPi library
git clone git://git.drogon.net/wiringPi
cd wiringPi
git pull origin
./build

# Config Nginx
cat <<EOF > /etc/nginx/nginx.conf
user www-data;
worker_processes 4;
pid /run/nginx.pid;

events {
	worker_connections 1024;
	# multi_accept on;
}

http {
  server {
    listen 80;
    server_name localhost;

    location / {
      fastcgi_pass   127.0.0.1:8000;
      access_log /var/log/nginx/access.log;
      error_log /var/log/nginx/error.log;
      
      fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
      fastcgi_param  SERVER_SOFTWARE    nginx;
      fastcgi_param  QUERY_STRING       $query_string;
      fastcgi_param  REQUEST_METHOD     $request_method;
      fastcgi_param  CONTENT_TYPE       $content_type;
      fastcgi_param  CONTENT_LENGTH     $content_length;
      fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
      fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
      fastcgi_param  REQUEST_URI        $request_uri;
      fastcgi_param  DOCUMENT_URI       $document_uri;
      fastcgi_param  DOCUMENT_ROOT      $document_root;
      fastcgi_param  SERVER_PROTOCOL    $server_protocol;
      fastcgi_param  REMOTE_ADDR        $remote_addr;
      fastcgi_param  REMOTE_PORT        $remote_port;
      fastcgi_param  SERVER_ADDR        $server_addr;
      fastcgi_param  SERVER_PORT        $server_port;
      fastcgi_param  SERVER_NAME        $server_name;
    }
  }
}
EOF

# Edit ssh
sed -i -e 's/Port 22/Port 22/g' /etc/ssh/sshd_config

# Configure wifi
cat <<EOF > /etc/wpa_supplicant/wpa_supplicant.conf
wpactrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=RU

network={
	ssid="ssid"
	psk="passwd"
	key_mgmt=WPA-PSK
}
EOF

cat <<EOF > /etc/network/intercaces
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

iface eth0 inet manual

allow-hotplug wlan0
iface wlan0 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

allow-hotplug wlan1
iface wlan1 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
EOF

# Ipables rules
iptables -F
iptables -A INPUT -i lo -j ACCEPT
iptables -N zabbix
iptables -A INPUT -s 127.0.0.1/32 -j zabbix
iptables -A zabbix -p tcp --dport 10050 -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -s 127.0.0.1/28 --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -s 127.0.0.1/24 --dport 80 -j ACCEPT
iptables -A INPUT -j DROP

service fail2ban stop
sed -i '/fail2ban/d' $rules
cat $rules | iptables-restore -c
service fail2ban start

# Edit Zabbix agent configuration
sed -i -e 's/Server=127.0.0.1/Server=127.0.0.1/g' $zabbix_agent_conf
sed -i -e 's/ServerActive=127.0.0.1/ServerActive=127.0.0.1/g' $zabbix_agent_conf

# Download source for hc-sr04
git clone https://github.com/jezman/BoxDemension.git
cd BoxDemention
gcc hc-sr04.c -lwiringPi -o /usr/bin/hc-sr04
g++ fcgi.cpp -lfcgi++ -lfcgi -o /usr/bin/fcgi

# Startup app
echo "spawn-fcgi -p 8000 -n fcgi&" > /etc/init.d/fcgi

# Add task in crontab
cat <(crontab -l) <(echo "SHELL=/bin/sh") | crontab -
cat <(crontab -l) <(echo "PATH=/bin:/usr/bin") | crontab -
cat <(crontab -l) <(echo "0-59 * * * * [[ -n $(pidof fcgi) ]] || sudo spawn-fcgi -p 8000 -n fcgi&") | crontab -

# Set permission
chmod 700 /usr/bin/hc-sr04 /usr/bin/fcgi /etc/init.d/fcgi
