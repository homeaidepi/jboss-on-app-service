#!/usr/bin/env bash
echo "Running init_container.sh ..."

echo "Starting JBoss in the background"
/opt/eap/bin/openshift-launch.sh &

# BEGIN: Deploy the apps
# Copy wardeployed apps to local location and create marker file for each
if [ -f /home/site/wwwroot/app.ear ]
then
    echo "Found app.ear in /home/site/wwwroot, deploying it"
    ln -s /home/site/wwwroot/app.ear /tmp/wildfly/appservice/ROOT.ear
    $JBOSS_HOME/bin/jboss-cli.sh -c "deploy /tmp/wildfly/appservice/ROOT.ear"
elif [ -f /home/site/wwwroot/app.war ]
then
    echo "Found app.war in /home/site/wwwroot, deploying it"
    ln -s /home/site/wwwroot/app.war /tmp/wildfly/appservice/ROOT.war
    $JBOSS_HOME/bin/jboss-cli.sh -c "deploy /tmp/wildfly/appservice/ROOT.war"
else
    echo "Found neither app.ear nor app.war in /home/site/wwwroot, deploying apps in /home/site/wwwroot/webapps if any"

    for dirpath in /home/site/wwwroot/webapps/*
    do
        dir="$(basename -- $dirpath)"

        echo ***Copying $dirpath to $JBOSS_HOME/standalone/deployments/$dir.war
        cp -r $dirpath $JBOSS_HOME/standalone/deployments/$dir.war

        markerfile=$JBOSS_HOME/standalone/deployments/$dir.war.dodeploy

        echo ***Creating marker file $markerfile
        echo $dir > $markerfile
    done
fi
# END: Deploy the apps

$JBOSS_HOME/bin/jboss-cli.sh -c "reload"

echo "... init_container.sh completed!"