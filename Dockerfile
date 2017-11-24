FROM tomcat:latest
MAINTAINER d.basivireddy@gmail.com
COPY target/CounterWebApp.war /opt/tomcat/webapps/
CMD ["/opt/vimoservices"]
