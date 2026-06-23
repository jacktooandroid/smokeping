#!/usr/bin/env bash
set -euo pipefail

sudo apt update && sudo apt install -y smokeping miniupnpc libapache2-mod-fcgid dnsutils cron glances

sudo mkdir -p /etc/systemd/system/smokeping.service.d
sudo tee /etc/systemd/system/smokeping.service.d/override.conf > /dev/null <<'EOF'
[Unit]
Wants=network-online.target
After=network-online.target

[Service]
TimeoutStartSec=1800
EOF
sudo systemctl daemon-reload

sudo wget https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Probes.txt -O /etc/smokeping/config.d/Probes
sudo curl https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Probes.txt -o /etc/smokeping/config.d/Probes
sudo wget https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Presentation.txt -O /etc/smokeping/config.d/Presentation
sudo curl https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Presentation.txt -o /etc/smokeping/config.d/Presentation
sudo wget https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Targets.txt -O /etc/smokeping/config.d/Targets
sudo curl https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Targets.txt -o /etc/smokeping/config.d/Targets

sudo a2enmod fcgid
sudo a2enconf smokeping
sudo cp /etc/apache2/conf-available/smokeping.conf /etc/apache2/conf-available/smokeping.conf.bak.$(date +%Y%m%d%H%M%S)
if ! grep -q '<Location "/smokeping/smokeping.cgi">' /etc/apache2/conf-available/smokeping.conf; then
sudo tee -a /etc/apache2/conf-available/smokeping.conf > /dev/null <<'EOF'

<Location "/smokeping/smokeping.cgi">
    SetHandler fcgid-script
</Location>
EOF
fi
sudo tee /etc/apache2/conf-available/fcgid-smokeping.conf > /dev/null <<'EOF'
<IfModule fcgid_module>
    FcgidIOTimeout 600
    FcgidBusyTimeout 600
    FcgidConnectTimeout 60
    FcgidIdleTimeout 300
    FcgidProcessLifeTime 3600
    FcgidMaxProcessesPerClass 8
</IfModule>
EOF
sudo a2enconf fcgid-smokeping

sudo smokeping --check
sudo apache2ctl configtest

sudo systemctl restart smokeping
sudo systemctl restart apache2

sudo cp /var/www/html/index.html /var/www/html/index.html.bak.$(date +%Y%m%d%H%M%S)
# sudo wget https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Redirection%20to%20SmokePing.html -O /var/www/html/index.html
# sudo curl https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Redirection%20to%20SmokePing.html -o /var/www/html/index.html
# sudo systemctl restart apache2

#Download Cloudflare DDNS Script
sudo wget https://raw.githubusercontent.com/jacktooandroid/cloudflare/master/cloudflare_ddns-smokeping.sh -O /usr/local/bin/cloudflare_ddns-smokeping.sh
sudo curl https://raw.githubusercontent.com/jacktooandroid/cloudflare/master/cloudflare_ddns-smokeping.sh -o /usr/local/bin/cloudflare_ddns-smokeping.sh

#Download Smokeping Targets Monitoring Script
sudo wget https://raw.githubusercontent.com/jacktooandroid/smokeping/master/SmokePing_Targets_Monitoring_Script.sh -O /usr/local/sbin/SmokePing_Targets_Monitoring_Script.sh
sudo curl https://raw.githubusercontent.com/jacktooandroid/smokeping/master/SmokePing_Targets_Monitoring_Script.sh -o /usr/local/sbin/SmokePing_Targets_Monitoring_Script.sh

exit