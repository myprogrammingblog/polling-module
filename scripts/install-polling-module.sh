#!/bin/bash
clear
present=`pwd`
sudo chmod -R 755 ./subscripts

# Make changes to build.xml
cd subscripts
./build.sh

# Make changes to config.xml
cd "$present"
cd subscripts
./config.sh

# Make changes to Images.as
cd "$present"
cd subscripts
./image-dep.sh

# Make changes to locales
cd "$present"
cd subscripts
./locales.sh

# Install web polling
cd "$present"
cd subscripts
./web-polling.sh

# Graft polling module file structure onto main BBB file structure
cd "$present"
cd ..
sudo chmod -R 777 ~/dev/bigbluebutton
cp -fr bigbluebutton ~/dev/bigbluebutton
read -p "Press any key to continue... " -n1 -s
echo " "

# Build locales
cd ~/dev/bigbluebutton/bigbluebutton-client
ant locales
read -p "Press any key to continue... " -n1 -s
echo " "
ant
read -p "Press any key to continue... " -n1 -s
echo " "

# Stop Red5 and compile apps
sudo /etc/init.d/red5 stop
cd /home/firstuser/dev/bigbluebutton/bigbluebutton-apps
gradle resolveDeps
gradle clean war deploy
read -p "Press any key to continue... " -n1 -s
echo " "

# Clean restart of Big Blue Button
sudo bbb-conf --clean
