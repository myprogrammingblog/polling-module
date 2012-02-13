#!/bin/bash


#CHANGE THIS PATH IF IT IS NOT YOUR PATH TO BIGBLUEBUTTON
BBB=/home/firstuser/dev/source/bigbluebutton



#if number of arguments are correct check if file name that user passed exist
if [ -f "$BBB/bigbluebutton-client/src/PollingModule.mxml" ]
then
 #if exist compile using mxmlc parameters such as sourcepath libraries etc
  mxmlc $BBB/bigbluebutton-client/src/PollingModule.mxml -sp $BBB/bigbluebutton-client/src  -l $BBB/bigbluebutton-client/libs -locale -accessible
 else
        echo "PollingModule.mxml does not exist... in $BBB/bigbluebutton-client/src/"
	exit
fi

#if compilation went well compilable file should be in the directory
if [ -f "/home/firstuser/dev/source/bigbluebutton/bigbluebutton-client/src/PollingModule.swf" ]
  then

        #IF  COMPILABLE FILE EXIST --> MOVE TO "BIN"
                
        mv  /home/firstuser/dev/source/bigbluebutton/bigbluebutton-client/src/PollingModule.swf /home/firstuser/dev/source/bigbluebutton/bigbluebutton-client/bin
        #OUTPUT SUCCESS
        echo " ----------------------------------------------------- "
        echo "CONGRATULATIONS FILE: PollingModule.swf  COMPILED AND MOVED TO:"
        echo "                                          /home/firstuser/dev/source/bigbluebutton/bigbluebutton-client/bin " 
        echo " ----------------------------------------------------- "
  else
        #OUTPUT ERROR
        echo " ----------------------------"
        echo "PollingModule.swf was not created"
        echo " ----------------------------"
  fi

