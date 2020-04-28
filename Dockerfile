FROM registry.access.redhat.com/jboss-eap-7/eap72-openshift

USER root

ENV PORT 8080
ENV SSH_PORT 2222

COPY tmp/init_container.sh      /bin/init_container.sh
COPY tmp/standalone-full.xml    /opt/eap/standalone/configuration/standalone-full.xml
COPY tmp/index.jsp              /tmp/wildfly/webapps/ROOT/index.jsp
COPY tmp/sshd_config            /etc/ssh/
COPY tmp/ssh_keygen.sh          /tmp/ssh_keygen.sh

EXPOSE 8080 2222

CMD ["sh", "/bin/init_container.sh"]