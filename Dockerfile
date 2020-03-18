FROM registry.access.redhat.com/jboss-eap-7/eap72-openshift

EXPOSE 8080 9990

CMD [ "/opt/eap/bin/openshift-launch.sh" ]