FROM tomcat:latest
MAINTAINER d.basivireddy@gmail.com
RUN cp target/CounterWebApp.war /opt/tomcat/webapps/
RUN /opt/vimoservices
