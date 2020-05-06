

# Adds the Postgres module using the JBoss CLI. "--commands" allows you to pass a list of
# JBoss CLI commands as a comma-seperated string.
$JBOSS_HOME/bin/jboss-cli.sh 
    --commands="module add 
        --name=org.postgres
        --resources=/home/site/deployments/tools/postgresql-42.2.12.jar
        --dependencies=javax.api,javax.transaction.api"
