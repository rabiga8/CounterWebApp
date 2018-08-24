FROM tomcat:latest
MAINTAINER smattareddy2016@gmail.com
COPY target/CounterWebApp.war /opt/tomcat/webapps/
CMD ["/opt/vimoservices"]
