#!/bin/bash

if grep -q 'bean id="pollHandler"' $1; then
	echo "Polling Module beans already exist in bbb-apps.xml."
else
	sed -i 's/<\/beans>/\t<!-- START Polling  -->\n\t<bean id="pollHandler"\n\t      class="org.bigbluebutton.conference.service.poll.PollHandler">\n\t\t<property name="pollApplication"> \n\t\t\t<ref local="pollApplication"\/>\n\t\t<\/property>\n\t\t<property name="recorderApplication"> \n\t\t\t<ref local="recorderApplication"\/>\n\t\t<\/property>\n\t<\/bean>\n\t\n\t<bean id="pollApplication" class="org.bigbluebutton.conference.service.poll.PollApplication">\n\t\t<property name="roomsManager"> \n\t\t\t<ref local="pollRoomsManager"\/>\n\t\t<\/property>\n\t<\/bean>\n\t\n\t<bean id="poll.service" \n\t      class="org.bigbluebutton.conference.service.poll.PollService">\n\t\t<property name="pollApplication"> \n\t\t\t<ref local="pollApplication"\/>\n\t\t<\/property>\n\t<\/bean>\n\t\n\t<bean id="pollRoomsManager"\n\t      class="org.bigbluebutton.conference.service.poll.PollRoomsManager"\/>\n\t\n\t<bean id="pollRecorder"\n\t      class="org.bigbluebutton.conference.service.recorder.polling.PollRecorder">\n\t\t<property name="redisPool">\n\t\t\t<ref local="redisPool" \/> \n\t\t<\/property>   \n\t<\/bean>\n<\/beans>/' $1
fi

echo " "
echo "Modifications to bbb-apps.xml complete."
echo " "
