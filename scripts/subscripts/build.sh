#!/bin/bash

if grep -q 'property name="POLLING" value="PollingModule"' ~/dev/bigbluebutton/bigbluebutton-client/build.xml; then
	echo "PollingModule already defined in build.xml. Continuing with installation."
else
	sed -i 's/<property name="VIDEO_DOCK" value="VideodockModule" \/>/<property name="VIDEO__DOCK" value="VideodockModule" \/>\n\t<property name="POLLING" value="PollingModule" \/>/' ~/dev/bigbluebutton/bigbluebutton-client/build.xml
	sed -i 's/VIDEO__DOCK/VIDEO_DOCK/' ~/dev/bigbluebutton/bigbluebutton-client/build.xml
fi

echo "\n"

if grep -q 'target name="build-polling" description="Compile Polling Module' ~/dev/bigbluebutton/bigbluebutton-client/build.xml; then
	echo "build-polling target already defined in build.xml. Continuing with installation."
else
	sed -i 's/<target name="build-viewers" description="Compile Viewers Module">/<target name="build-polling" description="Compile Polling Module">\n\t\t<build-module src="${SRC_DIR}" target="${POLLING}" \/>\n\t<\/target>\n\n\t<target name="build--viewers" description="Compile Viewers Module">/' ~/dev/bigbluebutton/bigbluebutton-client/build.xml
	sed -i 's/<target name="build--viewers" description="Compile Viewers Module">/<target name="build-viewers" description="Compile Viewers Module">/' ~/dev/bigbluebutton/bigbluebutton-client/build.xml
fi

echo "\n"

if grep -q 'build-chat, build-polling, ' ~/dev/bigbluebutton/bigbluebutton-client/build.xml; then
	echo "build-polling already included in target 'build-main-chat-viewers-listeners-present'. Continuing installation."
else
	sed -i 's/build-chat, /build-chat, build-polling, /' ~/dev/bigbluebutton/bigbluebutton-client/build.xml
	sed -i 's/ chat,/ chat, polling,/' ~/dev/bigbluebutton/bigbluebutton-client/build.xml
fi

echo "\n"

if grep -q 'target name="build-poll"' ~/dev/bigbluebutton/bigbluebutton-client/build.xml; then
	echo "build-poll custom build instructions already present."
else
	sed -i 's/<\/project>/\t<target name="build-poll" depends="init-ant-contrib, build-polling" description="Build only the polling module." \/>\n<\/project>/' ~/dev/bigbluebutton/bigbluebutton-client/build.xml
fi

echo "\n"
echo "Modifications to build.xml complete."
echo "\n"

