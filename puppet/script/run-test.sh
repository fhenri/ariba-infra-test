cd /home/ariba && nohup java -jar selenium-server-standalone-2.50.1.jar -role hub &> /home/ariba/nohup.grid.out&

git clone git@bitbucket.org:fhenri/powersource.git /home/ariba/pws_test
cd /home/ariba/pws_test && git checkout TST_Serenity
cd /home/ariba/pws_test && gradle build

cd /home/ariba/pws_test && gradle aggregate
DATE=`date +%Y-%m-%d`
cp -R /home/ariba/pws_test/target/site/serenity /vagrant/$DATE