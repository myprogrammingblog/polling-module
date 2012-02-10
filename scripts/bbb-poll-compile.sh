#!/bin/bash


#Checks number of arguments
if [ ! -n "$1" ]
then
  echo ""       
  echo "ERROR:Syntax for this command is ./compile-module <moduleName> (without extension just name) "
  echo " "
  exit 
fi  
# Shows current version of script
if [ "$1" == "-v" ]
        then
                echo " bbb-client Module Compiler"
                echo "     v 1.0  Created: September 28, 2011"
                echo "          by Anatoly Spektor  << http://myprogrammingblog.com  >>"
                exit
fi

#if number of arguments are correct check if file name that user passed exist
if [ -f "/home/firstuser/dev/source/bigbluebutton/bigbluebutton-client/src/$1.mxml" ]
then
 #if exist compile using mxmlc parameters such as sourcepath libraries etc
  mxmlc  /home/firstuser/dev/source/bigbluebutton/bigbluebutton-client/src/$1.mxml -sp /home/firstuser/dev/source/bigbluebutton/bigbluebutton-client/src  -l /home/firstuser/dev/source/bigbluebutton/bigbluebutton-client/libs -locale -accessible
 else
        echo "$1.mxml does not exist, please choose another name"
fi

#if compilation went well compilable file should be in the directory
if [ -f "/home/firstuser/dev/source/bigbluebutton/bigbluebutton-client/src/$1.swf" ]
  then

        #IF  COMPILABLE FILE EXIST --> MOVE TO "BIN"
                
        mv  /home/firstuser/dev/source/bigbluebutton/bigbluebutton-client/src/$1.swf /home/firstuser/dev/source/bigbluebutton/bigbluebutton-client/bin
        #OUTPUT SUCCESS
        echo " ----------------------------------------------------- "
        echo "CONGRATULATIONS FILE: $1.swf  COMPILED AND MOVED TO:"
        echo "                                          /home/firstuser/dev/source/bigbluebutton/bigbluebutton-client/bin " 
        echo " ----------------------------------------------------- "
  else
        #OUTPUT ERROR
        echo " ----------------------------"
        echo "$1.swf was not created"
        echo " ----------------------------"
  fi

