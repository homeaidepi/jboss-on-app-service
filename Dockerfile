FROM registry.access.redhat.com/jboss-eap-7/eap72-openshift

EXPOSE 8080

CMD [ "/opt/eap/bin/openshift-launch.sh" ]