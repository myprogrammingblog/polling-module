This will outline where to place the files and what they are.

* For all the following commands it's assumed that you are currently in the
* web-polling directory

To copy the etc folder run:
sudo cp -r etc/* /etc

To copy the tomcat6 folder:
sudo cp -r tomcat6/* /var/lib/tomcat6

Restart Tomcat:
sudo service tomcat6 restart

An already created web poll can be accessed by going to "http://localhost/p/[webkey]"



The source folder is there in case someone needs to access the uncompiled .java file. It doesn't need to be moved anywhere.
