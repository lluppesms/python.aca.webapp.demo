// ------------------------------------------------------------------------------------------------------------------------
// Main Bicep File for Azure Container App Project
// ------------------------------------------------------------------------------------------------------------------------
param orgName string = ''
param envName string = 'DEMO'
param runDateTime string = utcNow()
param location string = resourceGroup().location

// ------------------------------------------------------------------------------------------------------------------------
var deploymentSuffix = '-${runDateTime}'
var commonTags = {         
  LastDeployed: runDateTime
  Organization: orgName
  Environment: envName
}

// --------------------------------------------------------------------------------
module resourceNames 'resourcenames.bicep' = {
  name: 'resourceNames${deploymentSuffix}'
  params: {
    orgName: orgName
    environmentName: toLower(envName)
  }
}

module logAnalyticsModule 'loganalytics.bicep' = {
  name: 'logAnalyticsWorkspace${deploymentSuffix}'
  params: {
    name: resourceNames.outputs.logAnalyticsWorkspaceName
    location: location
    commonTags: commonTags
  }
}

// module keyVaultModule 'keyvault.bicep' = {
//   name: 'keyVault-Deploy${deploymentSuffix}'
//   params: {
//     keyVaultName: resourceNames.outputs.keyVaultName
//     location: location
//     commonTags: commonTags
//     workspaceId: logAnalyticsModule.outputs.id
//   }
// }
// module keyVaultAppRightsModule 'keyvaultadminrights.bicep' = {
//   name: 'keyVault-Rights${deploymentSuffix}'
//   params: {
//     keyVaultName: keyVaultModule.outputs.name
//     onePrincipalId: logicAppModule.outputs.principalId
//     onePrincipalAdminRights: false
//     onePrincipalCertificateRights: false
//   }
// }
// module keyVaultSecretList 'keyvaultlistsecretnames.bicep' = {
//   name: 'keyVault-SecretsList${deploymentSuffix}'
//   dependsOn: [ keyVaultModule ]
//   params: {
//     keyVaultName: keyVaultModule.outputs.name
//     location: location
//     userManagedIdentityId: keyVaultModule.outputs.userManagedIdentityId
//   }
// }
// module keyVaultSecretStorage 'keyvaultsecretstorageconnection.bicep' = {
//   name: 'keyVaultSecret-Storage${deploymentSuffix}'
//   dependsOn: [ keyVaultModule, storageModule ]
//   params: {
//     keyVaultName: keyVaultModule.outputs.name
//     secretName: 'StorageAccountConnectionString'
//     storageAccountName: storageModule.outputs.storageAccountName
//     existingSecretNames: keyVaultSecretList.outputs.secretNameList
//   }
// }

module acaEnvironmentResource 'acaenvironment.bicep' = {
  name: 'containerAppEnvironment${deploymentSuffix}'
  dependsOn: [ logAnalyticsModule ]
  params: {
    name: resourceNames.outputs.acaEnvironmentName
    location: location
    logAnalyticsName: logAnalyticsModule.outputs.name
    appInsightsName: resourceNames.outputs.appInsightsName
    // keyVaultName: resourceNames.outputs.keyVaultName
    // keyVaultPrincipalId: keyVaultModule.outputs.daprIdentityId
    workspaceId: logAnalyticsModule.outputs.id
    commonTags: commonTags
  }
}
