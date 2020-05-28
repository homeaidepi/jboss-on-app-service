# JBoss EAP on App Service

This tutorial shows how to deploy JBoss EAP onto Azure App Service. The JBoss app server is deployed as a custom container.

-------

## Table of Contents

- [Prerequisites](#prerequisites)
- [Tutorial](#tutorial)
  - [Create the App Service Plan and resource group](#create-the-app-service-plan-and-resource-group)
  - [Create and configure the web app](#create-and-configure-the-web-app)
  - [Deploy a WAR file](#deploy-a-WAR-file)
  - [SSH into the web app](#SSH-into-the-web-app)
  - [Configure JBoss](#Configure-JBoss)
  - [Monitor with Application Insights](#Monitor-with-Application-Insights)
- [Local Usage](#Local-Usage)
- [Related Materials](#Related-Materials)

## Prerequisites

To complete this tutorial, you will need the following tools installed on your machine.

- The Azure CLI
- Maven
- Docker (optional)
- An FTP client, such as FileZilla

You will also need an active Azure Subscription.

## Tutorial

### Create the App Service Plan and resource group

If you do not already have an App Service Plan and resource group created, run the commands below to create them.

```shell
az group create --name <resource-group> --location eastus2
az appservice plan create --name <plan-name> --resource-group <resource-group> --sku P1V2 --is-linux
```

If you would like to use a different region, run the command `az account list-locations` to see a list of locations.

### Create and configure the web app

Now that the App Service Plan is created, we will create a Linux web app on the plan.

1. Run the Azure CLI command below to create an Azure web app. This command will use `jasonfreeberg/jboss-on-app-service` as the container image.

    ```shell
    az webapp create -n <webapp-name> -g <resource-group> -p <app-service-plan-name> --deployment-container-image-name "jasonfreeberg/jboss-on-app-service"
    ```

1. Once the webapp is created, run this CLI command to allow the container to use the App Service file system.

    ```shell
    az webapp config appsettings set --name <webapp-name> --resource-group <resource-group> --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=true
    ```

1. Browse to your web app at *http://\<webapp-name>.azurewebsites.net*. You should see the [default JSP](tmp/index.jsp). You now have a custom container running JBoss deployed on App Service.  

### Deploy a WAR file

We will now use App Service's [REST APIs to deploy a .WAR file](https://docs.microsoft.com/azure/app-service/deploy-zip#deploy-war-file) onto the web app.

#### Build the sample app

From the root directory of the repository, run the following commands to build the sample app. This will use Maven to create a WAR file

  ```shell
  cd sample
  mvn clean install
  ```

#### Deploy the sample app

Next, deploy the WAR file using either cURL or PowerShell. After deploying, browse to your web app to confirm the WAR file has deployed.

##### with cURL

1. To deploy with cURL, you will need the deployment username and password. Run the command below. In the command output, your username and password are in the first JSON.

    ```bash
    az webapp deployment list-publishing-profiles --name <ap-name> --resource-group <resource-group>
    ```

1. Copy the username and paste it into the placeholder below. Run the cURL command and enter the password when prompted.

    ```bash
    curl -X POST -u <username> --data-binary @"<war-file-path>" https://<app-name>.scm.azurewebsites.net/api/wardeploy
    ```

##### with PowerShell

If have the Azure PowerShell commandlets installed and you are [logged in](https://docs.microsoft.com/powershell/azure/authenticate-azureps?view=azps-3.8.0), you can use the following command to deploy (no need to get the deployment credentials).

```powershell
Publish-AzWebapp -ResourceGroupName <group-name> -Name <app-name> -ArchivePath <war-file-path>
```

### SSH into the web app

This container has been configured to allow easy SSH from the Kudu management site, simply open a browser to `https://<app-name>.scm.azurewebsites.net/webssh/host`.

You can also connect using you favorite SSH client. For more information, see [this article](https://docs.microsoft.com/azure/app-service/containers/app-service-linux-ssh-support).

### Configure JBoss

In App Service, each app instance is stateless. This means any changes applied to the container as it is running will be lost if the instance moves or restarts. App Service allows you to specify a [startup script](https://docs.microsoft.com/azure/app-service/containers/app-service-linux-faq#built-in-images) to be called as the container starts. This is where your can specify a shell script to run any JBoss CLI commands (or other commands) to configure the container.

The section below shows how to upload a database driver and use a startup script to register it as a JBoss module.

#### Configure a database

The `db_config/` directory of this repository contains a JDBC driver for Postgres and a shell script to add this driver as a JBoss module. Open [`startup_script.sh`](db_config/startup_script.sh) and take a look at the contents.

Use your FTP client to upload the contents of the `db_config/` directory to the container's `/home/wwwroot/deployments/tools` directory. You can use `az webapp deployment list-publishing-profiles --name <app-name> --resource-group <group>` to get the site's FTP deployment URL, username, and password.

Once the driver and shell script are uploaded, run the following Azure CLI command. This will configure the platform to run the shell script whenever your JBoss container starts.

```shell
az webapp config set --startup-file "/home/site/deployments/tools/startup_script.sh" --name <webapp-name> --resource-group <group-name>
```

### Monitor with Application Insights

The container is configured with Application Insights. To view the telemetry, simply create an Application Insights resource and provide your instrumentation key as an environment variable.

1. [Create an Application Insights resource](https://docs.microsoft.com/azure/azure-monitor/app/create-new-resource) using the Azure Portal.

1. Create a new app setting, `APPINSIGHTS_INSTRUMENTATIONKEY`, with your AI Instrumentation key from the Application Insights blade.

    ```shell
    az webapp config appsettings set --name <webapp-name> --resource-group <resource-group> --settings APPINSIGHTS_INSTRUMENTATIONKEY=<your-key>
    ```

You can now [use Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview) to set up alerts, query metrics, or send custom telemetry.

#### Outsource application state

JBoss applications are sometimes run in a clustered configuration (also known as domain mode). However, App Service does not support direct communication between application instances so JBoss apps can only be run in standalone mode on App Service. If you do wish to run a stateful JBoss EAP application on the platform, the state must be stored remotely in Red Hat Data Grid. JBoss 7 supports  For more information, please see [this section of the JBoss 7 docs](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.2/html/configuration_guide/configuring_high_availability#cache_containers).

> If you are migrating an existing JBoss application that runs in domain mode, see [JBoss on Azure Virtual Machines](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.1/html-single/using_jboss_eap_in_microsoft_azure/index).

## Local Usage

The following instructions are for using the Docker image locally. These steps are not required to run the image on App Service.

### Build and run the container

1. Build the image.

  ```shell
  docker build . -t jboss --build-arg RH_USERNAME --build-arg RH_PASSWORD
  ```

1. Run the image. This will mount a directory to the wwwroot directory, so we can deploy WAR applications locally.

  ```shell
  docker run --name jboss -v ~/mounted_home:/home/ --publish-all jboss
  ```

1. Get the port mapping

  ```shell
  docker container ps
  ```

  This will show the jboss container under the `PORTS` column.

1. Open a browser to `http://localhost:<port-mapped-to-8080>`

### SSH into the container

```shell
docker exec -it jboss bash
```

## Related Materials

- "The JBoss EAP management CLI is not recommended for use with JBoss EAP running in a containerized environment. Any configuration changes made using the management CLI in a running container will be lost when the container restarts." [Source](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.2/html-single/getting_started_with_jboss_eap_for_openshift_container_platform/index)
- The container image used in this tutorial is based on the [JBoss EAP 7.2 for OpenShift Container Image](https://access.redhat.com/containers/?extIdCarryOver=true&sc_cid=701f2000001Css5AAC&tab=images&get-method=unauthenticated#/registry.access.redhat.com/jboss-eap-7/eap72-openshift)
