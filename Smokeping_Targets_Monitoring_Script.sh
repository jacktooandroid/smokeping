#!/bin/bash

mkdir /tmp/smokeping

sudo wget https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Targets.txt -O /tmp/smokeping/Targets
sudo curl https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Targets.txt -o /tmp/smokeping/Targets

sha256sum /tmp/smokeping/Targets | head -c 64 | sudo tee /tmp/smokeping/GitHub_Targets > /dev/null
sha256sum /etc/smokeping/config.d/Targets | head -c 64 | sudo tee /tmp/smokeping/Local_Targets > /dev/null

GitHub_Targets=$(cat /tmp/smokeping/GitHub_Targets)
Local_Targets=$(cat /tmp/smokeping/Local_Targets)

if [ "$GitHub_Targets" = "$Local_Targets" ]
    then
        exit
    else
        sudo cp /tmp/smokeping/Targets /etc/smokeping/config.d/Targets
        sudo service smokeping restart
        exit
fi

exit

#cmp /tmp/smokeping/GitHub_Targets /tmp/smokeping/Local_Targets | sudo tee /tmp/smokeping/cmp_results
#cmp_results=$(cat /tmp/smokeping/cmp_results)
#if [ -z "$cmp_results" ]
#    then
#        exit
#    else
#        sudo cp /tmp/smokeping/Targets /etc/smokeping/config.d/Targets
#        sudo service smokeping restart
#        exit
#fi

#exit
