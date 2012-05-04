#!/bin/bash

if grep -q "poll_icon.png" ~/dev/bigbluebutton/bigbluebutton-client/src/org/bigbluebutton/common/events/Images.as; then
	echo "poll_icon.png is already referenced in Images.as."
else
	sed -i 's/public var shape_handles:Class;/public var shape_handles:Class;\n\t[Embed(source="assets\/images\/poll_icon.png")]\n\tpublic var pollIcon:Class;/' ~/dev/bigbluebutton/bigbluebutton-client/src/org/bigbluebutton/common/events/Images.as
fi
echo "\n"
echo "Modifications to Images.as complete."
echo "\n"
