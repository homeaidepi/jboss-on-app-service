# JBoss EAP on App Service

This repository shows how to deploy JBoss EAP onto Azure App Service. The app server is deployed as a custom container.

## Usage

### Create the web app

1. Run the Azure CLI command below to create an Azure web app. This command will use `asdasdasdasd` as the container image.

  ```shell
  az webapp create -n <webapp-name> -g <resource-group> -p <app-service-plan> --deployment-container-image-name "sadasdasdasdsa"
  ```

1. Once the webapp is created, run the CLI command to enable the container to use the App Service file system.

  ```shell
  az webapp config appsettings set 
  ```

1. Browse to your web app at *http://your-site-name.azurewebsites.net*. You should see the default web page. In the next section, we will use App Service's REST APIs to deploy a .WAR application onto the web app.

### Deploy a .WAR

## Build the sample app

## Deploy the sample app

- Need publishing credentials
- 

### Set up Application Insights

### Web SSH

## Local Usage

### Run the container

1. Build the image.

  ```shell
  docker build . -t jboss
  ```

1. Run the image. This will mount a directory to the wwwroot directory, so we can deploy .WAR applications locally.

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
docker exec -it <container-id> bash
```

### Deploy an app

Build the sample app using Maven.

```shell
cd sample
mvn clean install
```

Next, deploy the WAR file using App Service's REST APIs for deployment. For WAR applications, use `/api/wardeploy/`. The username and password for the following command are from your Web App's publish profile.

```shell
curl -X Post -u <username> --data-binary @"target/applicationPetstore.war" https://<your-app-name>.scm.azurewebsites.net/api/wardeploy
```

If you are using PowerShell, there is a Azure commandlet for WAR deploy.

```powershell
Publish-AzWebapp -ResourceGroupName <group-name> -Name <app-name> -ArchivePath "sample\target\applicationPetstore.war"
```

## Notes

- "The JBoss EAP management CLI is not recommended for use with JBoss EAP running in a containerized environment. Any configuration changes made using the management CLI in a running container will be lost when the container restarts." [Source](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.2/html-single/getting_started_with_jboss_eap_for_openshift_container_platform/index)

## Links

- [JBoss EAP 7.2 for OpenShift Container Image](https://access.redhat.com/containers/?extIdCarryOver=true&sc_cid=701f2000001Css5AAC&tab=images&get-method=unauthenticated#/registry.access.redhat.com/jboss-eap-7/eap72-openshift)
