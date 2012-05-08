#!/bin/bash

if grep -q "PollingModule" $1; then
	echo "PollingModule already exists in config.xml. Continuing with installation."
else
	sed -i 's/<\/modules>/\t<module name=\"PollingModule\" \n\t\t\turl=\"PollingModule.swf?v=3809\" \n\t\t\turi="rtmp:\/\/<SERVER_IP>\/bigbluebutton" \n\t\t\thost="http:\/\/<SERVER_IP>" \n\t\t\tdependsOn="ViewersModule" \n\t\t\/> \n\t<CLOSE-MODULE>/' $1
	sed -i 's/<CLOSE-MODULE>/<\/modules>/' $1
fi

echo " "

if grep -q "<SERVER_IP>" $1; then
	serverURL=`grep "help url" ~/dev/bigbluebutton/bigbluebutton-client/src/conf/config.xml`
	serverURL=${serverURL:22}
	serverURL=${serverURL%"/help.html\"/>"}
	sed -i s/\<SERVER_IP\>/$serverURL/g $1	
else
	echo "PollingModule is already looking at the right IP address or URL. Continuing with installation."
fi

echo " "
echo "Modifications to config.xml complete."
echo " "

