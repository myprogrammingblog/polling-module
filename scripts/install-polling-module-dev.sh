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
./config.sh ~/dev/bigbluebutton/bigbluebutton-client/src/conf/config.xml

# Make changes to Images.as
cd "$present"
cd subscripts
./image-dep.sh

# Make changes to locales
cd "$present"
cd subscripts
./locales.sh

# Make changes to bbb-apps.xml
cd "$present"
cd subscripts
./bbb-apps.sh ~/dev/bigbluebutton/bigbluebutton-apps/src/main/webapp/WEB-INF/bbb-apps.xml

# Install web polling
cd "$present"
cd subscripts
./web-polling.sh

# Graft polling module file structure onto main BBB file structure
cd "$present"
cd ..
sudo chmod -R 777 ~/dev/bigbluebutton
cp -r bigbluebutton ~/dev/
read -p "Press any key to continue... " -n1 -s
echo " "

# Build locales
repeat=true
while $repeat; do
    cd ~/dev/bigbluebutton/bigbluebutton-client
    ant locales
    echo "Was the build successful?"
    select response in "Yes" "No"; do
        case $response in
	    Yes ) repeat=false; break;;
            No ) break;;
        esac
    done
done
echo " "

# Build client
repeat=true
while $repeat; do
    cd ~/dev/bigbluebutton/bigbluebutton-client
    ant
    echo "Was the build successful?"
    select response in "Yes" "No"; do
        case $response in
	    Yes ) repeat=false; break;;
            No ) break;;
        esac
    done
done
echo " "

# Stop Red5 and compile apps
sudo /etc/init.d/red5 stop
cd /home/firstuser/dev/bigbluebutton/bigbluebutton-apps
gradle resolveDeps
gradle clean war deploy
read -p "Press any key to continue... " -n1 -s
echo " "

# Clean restart of Big Blue Button
sudo service nginx restart
sudo bbb-conf --clean
