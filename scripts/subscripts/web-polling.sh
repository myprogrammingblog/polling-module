#!/bin/bash

sudo rm -r /var/lib/tomcat6/webapps/p* 2> /dev/null
sudo cp ../../web-polling/etc/bigbluebutton/nginx/p.nginx /etc/bigbluebutton/nginx
sudo cp ../../web-polling/tomcat6/webapps/p.war /var/lib/tomcat6/webapps
sudo service tomcat6 restart

