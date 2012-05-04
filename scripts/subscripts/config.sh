#!/bin/bash

if grep -q "PollingModule" ~/dev/bigbluebutton/bigbluebutton-client/src/conf/config.xml; then
	echo "PollingModule already exists in config.xml. Continuing with installation."
else
	sed -i 's/<\/modules>/\t<module name=\"PollingModule\" \n\t\t\turl=\"PollingModule.swf?v=3809\" \n\t\t\turi="rtmp:\/\/<SERVER_IP>\/bigbluebutton" \n\t\t\thost="http:\/\/<SERVER_IP>" \n\t\t\tdependsOn="ViewersModule" \n\t\t\/> \n\t<CLOSE-MODULE>/' ~/dev/bigbluebutton/bigbluebutton-client/src/conf/config.xml
	sed -i 's/<CLOSE-MODULE>/<\/modules>/' ~/dev/bigbluebutton/bigbluebutton-client/src/conf/config.xml
fi

echo " "

if grep -q "<SERVER_IP>" ~/dev/bigbluebutton/bigbluebutton-client/src/conf/config.xml; then
	echo "PollingModule is already looking at the right IP address or URL. Continuing with installation."
else
	serverURL=`grep "help url" ~/dev/bigbluebutton/bigbluebutton-client/src/conf/config.xml`
	serverURL=${serverURL:22}
	serverURL=${serverURL%"/help.html\"/>"}
	sed -i s/\<SERVER_IP\>/$serverURL/g ~/dev/bigbluebutton/bigbluebutton-client/src/conf/config.xml
fi

echo " "
echo "Modifications to config.xml complete."
echo " "
