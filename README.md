# Deploy a Containerized Python App via Azure DevOps Pipelines

This is a sample project to demonstrate how to deploy a containerized Python app to Azure Container App Service via Azure DevOps Pipelines.

## Pipeline Setup Instructions

See the [readme.md](/.azdo/readme.md) in the .azdo/pipelines directory for more info on how to set up the pipelines. This is a multi-stage process that involves:

- creating a Variable Group with basic info
- running a pipeline creating a Azure Container Registry
- creating a Docker Service Connection to the ACR
- updating the Variable Group with ACR credentials
- running a pipeline to create the Azure resources
- running a pipeline to deploy the application

## Sample Application -- Deploy a Python (Flask) web app to Azure App Service

This is the sample Flask application for the Azure Quickstart [Deploy a Python (Django or Flask) web app to Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/quickstart-python). For instructions on how to create the Azure resources and deploy the application to Azure, refer to the Quickstart article.

https://learn.microsoft.com/en-us/azure/developer/python/tutorial-containerize-simple-web-app-for-app-service?tabs=web-app-fastapi