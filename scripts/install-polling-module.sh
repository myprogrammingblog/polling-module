#!/bin/bash
clear
present=`pwd`
sudo chmod -R 755 ./subscripts

# Make changes to config.xml
cd "$present"
cd subscripts
./config.sh /var/www/bigbluebutton/client/conf/config.xml

# Make changes to bbb-apps.xml
cd "$present"
cd subscripts
./bbb-apps.sh /usr/share/red5/webapps/bigbluebutton/WEB-INF/bbb-apps.xml

# Move server-side class files
cd "$present"
cd ../prod_files
sudo chmod -R 777 /usr/share/red5/webapps/bigbluebutton/WEB-INF/classes
cp -r classes /usr/share/red5/webapps/bigbluebutton/WEB-INF/

# Move client-side SWF files
cd "$present"
cd ../prod_files
sudo chmod -R 777 /var/www/bigbluebutton/client
cp -r client /var/www/bigbluebutton/
