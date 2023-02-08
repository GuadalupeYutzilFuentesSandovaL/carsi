#!/bin/bash

echo -e "-------------------\n Starting TomCat Installing  \n-------------------"
sleep 5

yum update -y

#install java 11


echo -e "-------------------\n Installing Java  \n-------------------"
sleep 5


yum install java-11-openjdk-devel -y #tar.gz

java -version

echo -e "-------------------\n Ready Java  \n-------------------"
sleep 5
echo -e "-------------------\n Installing Tomcat  \n-------------------"
sleep 5


yum install wget -y

wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.71/bin/apache-tomcat-9.0.71.tar.gz 

ls -l 

echo -e "--------------------------------\n"

tar -xzvf apache-tomcat-9.0.71.tar.gz -C /opt/

#move to file

cd /opt

mv apache-tomcat-9.0.71/ tomcat

echo -e "-------------------\n Making grupos  \n-------------------"
sleep 5


groupadd tomcat 
useradd -g tomcat -d /opt/tomcat -s /bin/nologin tomcat

echo -e "-------------------\n Ready group  \n-------------------"
sleep 5

#group,  directory,  unaccess shell , user name

#useradd: Warning: missing or non-executable shell '/bin/nologin'
#useradd: warning: the home directory /opt/tomcat already exists.
#useradd: Not copying any file from skel directory into it.

chown -R tomcat:tomcat /opt/tomcat/
#change the group, propetary  and directory 

echo -e "-------------------\n Configuring Tomcat  \n-------------------"
sleep 5

touch /etc/systemd/system/tomcat.service

cat << EOF > /etc/systemd/system/tomcat.service

[Unit]
Description=Apache Tomcat 9
After=syslog.target network.target

[Service]
User=tomcat
Group=tomcat
Type=forking
Environment=CATALINA_PID=/opt/tomcat/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo -e "-------------------\n Ready server configuration  \n-------------------"
sleep 5

systemctl daemon-reload #reboot services
systemctl enable tomcat
#Created symlink from /etc/systemd/system/multi-user.target.wants/tomcat.service to /etc/systemd/system/tomcat.service.
systemctl start tomcat 
#systemctl status tomcat 


echo -e "-------------------\n User  \n-------------------"
sleep 5

echo "Enter User TomCat"
read userCat
echo "Enter password Tomcat"
read passCat

#user tomcat 
sed -i "56i\<role rolename=\"admin-gui\"/>\n<role rolename=\"manager-gui\"/>\n<user username=\"${userCat}\" password=\"${passCat}\" roles=\"admin-gui,manager-gui\"/>\n" /opt/tomcat/conf/tomcat-users.xml 

echo -e "-------------------\n Ready User  \n-------------------"
sleep 5





sed -i 's/127\\.\\d+\\.\\d+\\.\\d+|::1|0:0:0:0:0:0:0:1/127\\.\\d+\\.\\d+\\.\\d+|::1|0:0:0:0:0:0:0:1|\\d+\\.\\d+\\.\\d+\\.\\d+/g' /opt/tomcat/webapps/manager/META-INF/context.xml

sed -i 's/127\\.\\d+\\.\\d+\\.\\d+|::1|0:0:0:0:0:0:0:1/127\\.\\d+\\.\\d+\\.\\d+|::1|0:0:0:0:0:0:0:1|\\d+\\.\\d+\\.\\d+\\.\\d+/g' /opt/tomcat/webapps/host-manager/META-INF/context.xml



echo -e "-------------------\n Ready Puert \n-------------------"
sleep 5



sed -i "71i\maxPostSize=\"209715200\"\t" /opt/tomcat/conf/server.xml
sed -i 's/50/200/g' /opt/tomcat/webapps/manager/WEB-INF/web.xml
sed -i 's/52428800/209715200/g' /opt/tomcat/webapps/manager/WEB-INF/web.xml


echo -e "-------------------\n Ready size was changed\n-------------------"
sleep 5


systemctl restart tomcat

echo -e "-------------------\n Reboot Tomcat\n-------------------"