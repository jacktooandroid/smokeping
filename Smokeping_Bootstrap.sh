#!/bin/bash

echo "DefaultTimeoutStartSec=1800s" | sudo tee -a /etc/systemd/system.conf
sudo systemctl daemon-reload

sudo apt-get update && sudo apt-get install smokeping miniupnpc -y
sudo wget https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Probes.txt -O /etc/smokeping/config.d/Probes
sudo curl https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Probes.txt -o /etc/smokeping/config.d/Probes
sudo wget https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Presentation.txt -O /etc/smokeping/config.d/Presentation
sudo curl https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Presentation.txt -o /etc/smokeping/config.d/Presentation
#sudo wget https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Targets.txt -O /etc/smokeping/config.d/Targets
#sudo curl https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Targets.txt -o /etc/smokeping/config.d/Targets
sudo service smokeping restart

sudo cp /var/www/html/index.html /var/www/html/index.html.bak
sudo wget https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Redirection%20to%20SmokePing.html -O /var/www/html/index.html
sudo curl https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Redirection%20to%20SmokePing.html -o /var/www/html/index.html
sudo service apache2 restart

#Download Cloudflare DDNS Script
sudo wget https://raw.githubusercontent.com/jacktooandroid/cloudflare/master/cloudflare_ddns-smokeping.sh -O /usr/local/bin/cloudflare_ddns-smokeping.sh
sudo curl https://raw.githubusercontent.com/jacktooandroid/cloudflare/master/cloudflare_ddns-smokeping.sh -o /usr/local/bin/cloudflare_ddns-smokeping.sh

#Download Smokeping Targets Monitoring Script
sudo wget https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Smokeping_Targets_Monitoring_Script.sh -O /usr/local/sbin/Smokeping_Targets_Monitoring_Script.sh
sudo curl https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Smokeping_Targets_Monitoring_Script.sh -o /usr/local/sbin/Smokeping_Targets_Monitoring_Script.sh

exit