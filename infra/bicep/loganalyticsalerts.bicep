// --------------------------------------------------------------------------------
// Creates a Log Analytics Workspace
// See: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-monitoring
// --------------------------------------------------------------------------------
param actionGroupName string = 'AlertGroup1'
@maxLength(12)
param actionGroupShortName string = 'alertgroup1'

param alert_Operational_Issues_Name string = 'Operational issues'
param alert_Daily_Cap_Name string = 'Data ingestion has hit the daily cap'
param alert_Exceeding_Limit_Name string = 'Data ingestion is exceeding the ingestion rate limit'

param notificationEmail string = ''

param workspaceName string = ''
param location string = ''

// --------------------------------------------------------------------------------
// Variables
// --------------------------------------------------------------------------------
var alert_Operational_Issues_Name_And_Workspace = '${alert_Operational_Issues_Name} - ${workspaceName}'
var alert_Daily_Cap_Name_And_Workspace = '${alert_Daily_Cap_Name} - ${workspaceName}'
var alert_Exceeding_Limit_Name_And_Workspace = '${alert_Exceeding_Limit_Name} - ${workspaceName}'

var emailReceivers = (notificationEmail == '') ? [] : [
  {
    name: 'emailme_-EmailAction-'
    emailAddress: notificationEmail
    useCommonAlertSchema: true
  }
]
var armRole_Owner_Guid = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var armRoleReceivers = [
  {
    name: 'ArmRole'
    roleId: armRole_Owner_Guid
    useCommonAlertSchema: true
  }
]


// --------------------------------------------------------------------------------
// Find resources
// --------------------------------------------------------------------------------
resource workspaceResource 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = { name: workspaceName }
var workspaceId = workspaceResource.id

// --------------------------------------------------------------------------------
// Create alert group
// --------------------------------------------------------------------------------
// group: Defined Owner
resource actionGroup_resource 'microsoft.insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    groupShortName: actionGroupShortName
    enabled: true
    emailReceivers: emailReceivers
    armRoleReceivers: armRoleReceivers
  }
}

// --------------------------------------------------------------------------------
// Create alerts
// --------------------------------------------------------------------------------
// alert: 'Data ingestion has reached the daily cap configured in the workspace'
resource alert_Daily_Cap_resource 'microsoft.insights/scheduledqueryrules@2023-03-15-preview' = {
  name: alert_Daily_Cap_Name_And_Workspace
  location: location
  properties: {
    description: 'Data ingestion has reached the daily cap configured in the workspace'
    severity: 2
    enabled: true
    evaluationFrequency: 'PT5M'
    scopes: [
      workspaceId
    ]
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          query: '_LogOperation | where Category == "Ingestion" | where Operation has "Data collection"'
          timeAggregation: 'Count'
          resourceIdColumn: '_ResourceId'
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    autoMitigate: false
    actions: {
      actionGroups: [
        actionGroup_resource.id
      ]
      customProperties: {}
    }
  }
}

// alert: 'Data ingested from Azure resources has reached the ingestion rate limit'
resource alert_Exceeding_Limit_resource 'microsoft.insights/scheduledqueryrules@2023-03-15-preview' = {
  name: alert_Exceeding_Limit_Name_And_Workspace
  location: location
  properties: {
    description: 'Data ingested from Azure resources has reached the ingestion rate limit'
    severity: 2
    enabled: true
    evaluationFrequency: 'PT5M'
    scopes: [
      workspaceId
    ]
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          query: '_LogOperation | where Category == "Ingestion" | where Operation has "Ingestion rate"'
          timeAggregation: 'Count'
          resourceIdColumn: '_ResourceId'
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    autoMitigate: false
    actions: {
      actionGroups: [
        actionGroup_resource.id
      ]
      customProperties: {}
    }
  }
}

// alert: 'There are operational issues in the workspace'
resource alert_Operational_Issues_resource 'microsoft.insights/scheduledqueryrules@2023-03-15-preview' = {
  name: alert_Operational_Issues_Name_And_Workspace
  location: location
  properties: {
    description: 'There are operational issues in the workspace'
    severity: 3
    enabled: true
    evaluationFrequency: 'PT5M'
    scopes: [
      workspaceId
    ]
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          query: '_LogOperation | where Level == "Warning"'
          timeAggregation: 'Count'
          resourceIdColumn: '_ResourceId'
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    autoMitigate: false
    actions: {
      actionGroups: [
        actionGroup_resource.id
      ]
      customProperties: {}
    }
  }
}
