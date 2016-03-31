#!/bin/bash

if [ -d "/home/ariba/pws_test" ];then
    cd /home/ariba && nohup java -jar /test/selenium-server-standalone-$1.jar -role hub &> /home/ariba/nohup.grid.out&
    
    cd /home/ariba/pws_test && git pull

    echo "sleeping for 10 minutes .. time for Ariba to start up"
    #sleep 600

    cd /home/ariba/pws_test && gradle build

    cd /home/ariba/pws_test && gradle aggregate
    DATE=`date +%Y-%m-%d`
    cp -R /home/ariba/pws_test/target/site/serenity /vagrant/$DATE
    cd /home/ariba/pws_test && gradle clean
else
    git clone git@bitbucket.org:fhenri/powersource.git /home/ariba/pws_test
    cd /home/ariba/pws_test && git checkout TST_Serenity
    cd /home/ariba/pws_test && gradle assemble
fi
