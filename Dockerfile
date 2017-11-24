FROM tomcat:latest
MAINTAINER d.basivireddy@gmail.com
WORKDIR /root/MusicBox
RUN cp /var/lib/jenkins/workspace/CounterWebApp/target/CounterWebApp.war /opt/tomcat/webapps/
RUN /opt/vimoservices
