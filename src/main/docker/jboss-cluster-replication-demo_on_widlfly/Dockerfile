FROM quay.io/wildfly/wildfly
# RUN /opt/jboss/wildfly/bin/add-user.sh -m -u admin -p safer-to-set-from-container-instead --silent

ADD src/main/resources/config-server.cli /opt/jboss/

RUN /opt/jboss/wildfly/bin/jboss-cli.sh --file=config-server.cli

RUN rm -rf /opt/jboss/wildfly/standalone/configuration/standalone_xml_history/*

# example of containerized app:
ADD target/jboss-cluster-ha-demo.war /opt/jboss/wildfly/standalone/deployments/

EXPOSE 8080 9990 7600 8888