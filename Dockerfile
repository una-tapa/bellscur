FROM websphere-liberty

USER root
RUN apt-get update

# In case, bells feature is not installed.
# RUN /opt/ibm/wlp/bin/installUtility install --acceptLicense bells-1.0

ADD server-bells.xml     /opt/ibm/wlp/usr/servers/defaultServer/server.xml 
ADD basicauth.war          /opt/ibm/wlp/usr/servers/defaultServer/apps/basicauth.war
ADD bootstrap.properties  /opt/ibm/wlp/usr/servers/defaultServer
ADD java-project/target/bellscur-1.0-SNAPSHOT.jar /opt/ibm/wlp/usr/servers/defaultServer/resources/sharedLib/bellsCur.jar
ADD users.props /opt/ibm/wlp/usr/servers/defaultServer/resources/users.props
ADD groups.props /opt/ibm/wlp/usr/servers/defaultServer/resources/groups.props

# CMD [ "bash" ] 