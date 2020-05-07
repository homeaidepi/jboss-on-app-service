FROM registry.access.redhat.com/jboss-eap-7/eap72-openshift

USER root

ARG RH_USERNAME
ARG RH_PASSWORD

ENV PORT 8080
ENV SSH_PORT 2222

COPY tmp/init_container.sh      /bin/init_container.sh
COPY tmp/standalone-full.xml    /opt/eap/standalone/configuration/standalone-full.xml
COPY tmp/index.jsp              /tmp/wildfly/webapps/ROOT/index.jsp
COPY tmp/sshd_config            /etc/ssh/
COPY tmp/ssh_keygen.sh          /tmp/ssh_keygen.sh

# Register with Red Hat, install utilities, unregister
RUN subscription-manager register --username $RH_USERNAME --password $RH_PASSWORD --auto-attach
RUN yum install -y openssh-server
RUN yum install -y wget
RUN subscription-manager unregister

# Set up SSH keys
RUN chmod 755 /tmp/ssh_keygen.sh
RUN echo "root:Docker!" | chpasswd
RUN sh /tmp/ssh_keygen.sh

# Download AI agent, copy the config file
RUN wget -O /tmp/appinsights-agent.jar https://github.com/microsoft/ApplicationInsights-Java/releases/download/2.6.0/applicationinsights-agent-2.6.0.jar
COPY tmp/AI-Agent.xml           /tmp/AI-Agent.xml

# Make directory for deployment tools
RUN mkdir -p /home/site/deployments/tools

EXPOSE 8080 2222

CMD ["sh", "/bin/init_container.sh"]