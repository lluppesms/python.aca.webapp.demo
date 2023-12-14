# Azure DevOps Deployment Template Notes

## 1. Setup and Deploy Steps

To deploy this application, execute the following steps:

- [Create an Azure DevOps Service Connection](https://docs.luppes.com/CreateServiceConnections/)

- [Create Azure DevOps Environments](https://docs.luppes.com/CreateDevOpsEnvironments/)

- Create Azure DevOps Variable Groups -- see step 3.1 below for details

- [Create Azure DevOps Pipelines](https://docs.luppes.com/CreateNewPipeline/)

- Run the [aca-1-container-registry-pipeline.yml](pipelines/aca-1-container-registry-pipeline.yml) to create a Azure Container Registry

- Grant acrPull rights in the Azure Container Registry to the service principal that is running your pipelines

- Create a Docker Service Connection in the AzDO Project Settings - see Step 3.2 below for details

- Add the Docker Service Connection name and the ACR Name/User/Password to the Variable Group - see Step 3.3 below for details

- Run the [aca-2-deploy-infra-pipeline.yml](pipelines/aca-2-deploy-infra-pipeline.yml) to deploy the Azure Resources to an Azure subscription.

- Run the [aca-3-deploy-aca-app-pipeline.yml](pipelines/aca-3-deploy-aca-app-pipeline.yml) to build and deploy the application to the ACA.

---

## 2. Azure DevOps Template Definitions

These are the main pipelines defined for this project:

- **[aca-1-container-registry-pipeline.yml](pipelines/aca-1-container-registry-pipeline.yml):** Deploys the main-containerregistry.bicep template to creates a container registry
- **[aca-2-deploy-infra-pipeline.yml](pipelines/aca-2-deploy-infra-pipeline.yml):** Deploys the main-infra.bicep template and creates all of the Azure resources
- **[aca-3-deploy-aca-app-pipeline.yml](pipelines/aca-3-deploy-aca-app-pipeline.yml):** Builds and deploys all (or some) of the applications to the ACA

These YML files were designed to run as multi-stage environment deploys (i.e. DEV/QA/PROD). Each Azure DevOps environments can have permissions and approvals defined. For example, DEV can be published upon change, and QA/PROD environments can require an approval before any changes are made. If you don't supply environments, it will assume that it is a single environment named 'DEMO'.

---

## 3. Creating the Variable Group "PythonFlaskDemo"

### 3.1. Create the Initial Variable Group

Create a variable group with these values before running the aca-infra-pipeline.yml by customizing and running this command in the Azure Cloud Shell:

``` bash
   az login

   az pipelines variable-group create 
     --organization=https://dev.azure.com/<yourAzDOOrg>/ 
     --project='<yourAzDOProject>' 
     --name PythonFlaskDemo 
     --variables 
         orgName=xxx-python-aca
         subscriptionName=yourAzureServiceConnectionName
         resourceGroupPrefix='rg-python-aca'
         location=eastus
         acrFolderName=python-app
         azureServiceConnection=yourAzureServiceConnectionName 
         notificationEmail=youremail@domain.com

         dockerRegistryConnectionName=TBD-(yourDockerServiceConnectionName)
         acrName=TBD
         acrAdminUserName=TBD
         acrAdminPassword=TBD
```

### 3.2. Create Docker Service Connection

AFTER creating the Azure Container Registry, go into the Project Settings and create a Docker Service Connection that will allow the pipelines to connect to the Container Registry.

![Create Docker Service Connection](DockerServiceConnection.png)

### 3.3. Update the Variable Group

After creating the Docker Service Connection, add these four variables in the variable group.  

Find the acrAdminUserName and acrAdminPassword by navigating to the Container Registry in the portal, going to the Access keys tab, and (if the Admin User option is enabled) the password should be visible on that page.

Find the dockerRegistryConnectionName value by navigating to the Project Settings, clicking on Service Connections, and then clicking on the Docker Registry Service Connection.  The last node in the URL says "resourceid=" and THAT GUID is the value you need to put into this variable.

Make these entries in the Variable Group:

``` bash
  dockerRegistryConnectionName=<nameOfDockerRegistryServiceConnection>
  acrName=<containerRegistryName>
  acrAdminUserName=<fromContainerRegistryPage>
  acrAdminPassword=<fromContainerRegistryPage>
```
