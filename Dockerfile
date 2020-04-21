FROM registry.access.redhat.com/jboss-eap-7/eap72-openshift

USER root

# App Service needs these env vars defined
ENV PORT 8080

COPY tmp/init_container.sh      /bin/init_container.sh
COPY tmp/standalone-full.xml    /opt/eap/standalone/configuration/standalone-full.xml

EXPOSE 8080 9990

#CMD ["sh", "/opt/eap/bin/openshift-launch.sh"]
CMD ["sh", "/bin/init_container.sh"]