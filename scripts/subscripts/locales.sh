#!/bin/bash

for folder in ../../locales/*; do
	loc=${folder#\.\.\/\.\.\/locales\/}
	repoLocale="../../locales/$loc/bbbResources.properties"
	if grep -q "bbb.polling.createPoll" ~/dev/bigbluebutton/bigbluebutton-client/locale/$loc/bbbResources.properties; then	
		echo "Localization for $loc is already applied."
	else
		cat $repoLocale >> ~/dev/bigbluebutton/bigbluebutton-client/locale/$loc/bbbResources.properties
	fi
done

