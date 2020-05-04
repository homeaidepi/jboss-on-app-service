# JBoss EAP on App Service

This repository shows how to deploy JBoss EAP onto Azure App Service. The app server is deployed as a custom container.

## Usage

### Create the web app

1. Run the Azure CLI command below to create an Azure web app. This command will use `asdasdasdasd` as the container image.

    ```shell
    az webapp create -n <webapp-name> -g <resource-group> -p <app-service-plan> --deployment-container-image-name "jasonfreeberg/jboss-on-app-service"
    ```

1. Once the webapp is created, run the CLI command to enable the container to use the App Service file system.

    ```shell
    az webapp config appsettings set --resource-group <resource-group> --name <webapp-name> --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=true
    ```

1. Next, register the container with your Red Hat subscription. Create two app settings, `RH_USERNAME` and `RH_PASSWORD` with your Red Hat username and password respectively.

    ```shell
    az webapp config appsettings set --resource-group <resource-group> --name <webapp-name> --settings RH_USERNAME=<your-username> your-username>RH_PASSWORD=<your-password>
    ```

1. Browse to your web app at *http://webapp-name.azurewebsites.net*. You should see the default web page. You now have a custom container running JBoss deployed on App Service.  

### Deploy a WAR file

We will now use App Service's [REST APIs to deploy a .WAR file](https://docs.microsoft.com/azure/app-service/deploy-zip#deploy-war-file) onto the web app.

## Build the sample app

From the root directory of the repository, run the following commands to build the sample app. This will use Maven to create a WAR file

  ```dotnetcli
  cd sample
  mvn clean install
  ```

### Deploy the sample app

Next, deploy the WAR file using either cURL or PowerShell. After deploying, browse to your web app to confirm the WAR file has deployed.

#### with cURL

ToDo: get the login credentials

```bash
curl -X POST -u <username> --data-binary @"<war-file-path>" https://<app-name>.scm.azurewebsites.net/api/wardeploy
```

#### with PowerShell

If have the Azure PowerShell commandlets installed and you are [logged in](https://docs.microsoft.com/powershell/azure/authenticate-azureps?view=azps-3.8.0), you can use the following command to deploy (no need to get the deployment credentials).

```powershell
Publish-AzWebapp -ResourceGroupName <group-name> -Name <app-name> -ArchivePath <war-file-path>
```

### Web SSH

This container has been configured to allow easy SSH from the Kudu management site, simply open a browser to `https://<app-name>.scm.azurewebsites.net/webssh/host`.

You can also connect using a client of your choice. For more information, see [this article](https://docs.microsoft.com/azure/app-service/containers/app-service-linux-ssh-support).

### Configuring JBoss

In App Service, each app instance is stateless. This means each instance must be configured at startup. Any changes applied to the container as it is running would be lost if the instance moves or restarts. App Service allows you to specify a [startup script]() to be called as the container starts. This is where JBoss CLI commands can be executed to configure the container.

#### Outsource application state

JBoss applications are sometimes run in a clustered configuration (also known as domain mode). However, App Service does not support direct communication between application instances so JBoss apps can only be run in standalone mode on App Service. If you do wish to run a stateful JBoss EAP application on the platform, the state must be stored remotely in Red Hat Data Grid. JBoss 7 supports  For more information, please see [this section of the JBoss 7 docs](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.2/html/configuration_guide/configuring_high_availability#cache_containers).

> If you are migrating an existing JBoss application that runs in domain mode, see [JBoss on Azure Virtual Machines](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.1/html-single/using_jboss_eap_in_microsoft_azure/index).

### Remote EJB calls



### Set up Application Insights

1. Create a new App Setting, `APPINSIGHTS_INSTRUMENTATIONKEY`, with your Application Insights key from the Azure Portal.

1. 

## Local Usage

The following instructions are for using the Docker image locally. These steps are not required to run the image on App Service.

### Run the container

1. Build the image.

  ```shell
  docker build . -t jboss
  ```

1. Run the image. This will mount a directory to the wwwroot directory, so we can deploy .WAR applications locally.

  ```shell
  docker run --name jboss -v ~/mounted_home:/home/ -e RH_USERNAME -e RH_PASSWORD --publish-all jboss
  ```

1. Get the port mapping

  ```shell
  docker container ps
  ```

  This will show the jboss container under the `PORTS` column.

1. Open a browser to `http://localhost:<port-mapped-to-8080>`

### SSH into the container

```shell
docker exec -it <container-id> bash
```

## Notes

- "The JBoss EAP management CLI is not recommended for use with JBoss EAP running in a containerized environment. Any configuration changes made using the management CLI in a running container will be lost when the container restarts." [Source](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.2/html-single/getting_started_with_jboss_eap_for_openshift_container_platform/index)

### Development notes

- Can the Red Hat subscription be registered during Docker build? I had it as part of a `RUN` command, but it seemed to have no effect. Doing it as part of the startup script negatively affects cold start time.

  ```txt
  RUN subscription-manager register --username username --password password --auto-attach
  ```

## Links

- [JBoss EAP 7.2 for OpenShift Container Image](https://access.redhat.com/containers/?extIdCarryOver=true&sc_cid=701f2000001Css5AAC&tab=images&get-method=unauthenticated#/registry.access.redhat.com/jboss-eap-7/eap72-openshift)
 