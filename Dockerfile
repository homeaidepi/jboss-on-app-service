FROM registry.access.redhat.com/jboss-eap-7/eap72-openshift

USER root

ENV PORT 8080
ENV SSH_PORT 2222

COPY tmp/init_container.sh      /bin/init_container.sh
COPY tmp/standalone-full.xml    /opt/eap/standalone/configuration/standalone-full.xml
COPY tmp/index.jsp              /tmp/wildfly/webapps/ROOT/index.jsp
COPY tmp/sshd_config            /etc/ssh/
COPY tmp/ssh_keygen.sh          /tmp/ssh_keygen.sh
COPY tmp/centos_7.repo          /etc/yum.repos.d/centos_7.repo

# Register with Red Hat, install utilities, unregister
RUN yum install -y openssh-server
RUN yum install -y dos2unix
RUN yum install -y wget

RUN dos2unix /tmp/ssh_keygen.sh
RUN dos2unix /bin/init_container.sh

# Set up SSH keys
RUN chmod 755 /tmp/ssh_keygen.sh
RUN echo "root:Docker!" | chpasswd
RUN sh /tmp/ssh_keygen.sh

# Download AI agent, copy the config file
RUN wget -O /tmp/applicationinsights-agent-latest.jar https://repo1.maven.org/maven2/com/microsoft/azure/applicationinsights-agent/3.1.1/applicationinsights-agent-3.1.1.jar
# COPY tmp/AI-Agent.xml           /tmp/AI-Agent.xml

# Make directory for deployment tools
RUN mkdir -p /home/site/deployments/tools

EXPOSE 8080 2222

CMD ["sh", "/bin/init_container.sh"]