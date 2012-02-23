#!/bin/bash
# Do we want to back it up to the firstuser Desktop, or to the desktop of the user who's running the script?
# export USER=$(whoami)
BBB=/home/firstuser/dev/source/bigbluebutton
BACKDIR=/home/firstuser/Desktop/polling-module
#echo "Beginning PollingModule backup to $BACKDIR..."
#echo "To $BACKDIR/bbb-aps folder..."

#echo "Copying conference/service/recorder/poll..."
mkdir -p $BACKDIR/bbb-aps/src.main.java.bigbluebutton.conference.service.recorder
cp -R $BBB/bigbluebutton-apps/src/main/java/org/bigbluebutton/conference/service/recorder/polling $BACKDIR/bbb-aps/src.main.java.bigbluebutton.conference.service.recorder

#echo "Copying conference/service/poll..."
mkdir -p $BACKDIR/bbb-aps/src.main.java.org.bigbluebutton.conference.service.poll
cp -R $BBB/bigbluebutton-apps/src/main/java/org/bigbluebutton/conference/service/poll $BACKDIR/bbb-aps/src.main.java.org.bigbluebutton.conference.service.poll

#echo "Copying src/main/webapp/WEB-INF..."
mkdir -p $BACKDIR/bbb-aps/src.main.webapps.WEB-INF/
touch $BACKDIR/bbb-aps/src.main.webapps.WEB-INF/bbb-aps.xml
touch $BACKDIR/bbb-aps/src.main.webapps.WEB-INF/red5-web.xml
cp -R $BBB/bigbluebutton-apps/src/main/webapp/WEB-INF/bbb-apps.xml $BACKDIR/bbb-aps/src.main.webapps.WEB-INF/bbb-aps.xml
cp -R $BBB/bigbluebutton-apps/src/main/webapp/WEB-INF/red5-web.xml $BACKDIR/bbb-aps/src.main.webapps.WEB-INF/red5-web.xml
#echo "Done $BACKDIR/bbb-aps folder."

#echo "-----------------------------"
#echo "To $BACKDIR/polling folder..."
cp -R $BBB/bigbluebutton-client/src/org/bigbluebutton/modules/polling $BACKDIR/polling
#echo "Done $BACKDIR/polling folder."

#echo "-----------------------------"
#echo "Copying PollingModule.mxml..."
cp -R $BBB/bigbluebutton-client/src/PollingModule.mxml $BACKDIR
#echo "Copying to lcoales"
cp     $BBB/bigbluebutton-client/locale/en_US/bbbResources.properties $BACKDIR/client.locale/en_US/bbbResources.properties 
cp      $BBB/bigbluebutton-client/locale/ru_RU/bbbResources.properties $BACKDIR/client.locale/ru_RU/bbbResources.properties
#echo "Done PollingModule.mxml."
echo "Polling Module backup complete. Module files backed up to $BACKDIR"
