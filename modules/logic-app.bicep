param location string = resourceGroup().location
param logic_app_name string
param subnet_in_id string 
param subnet_out_id string 
param vnet_id string
param privateDnsZoneName string = 'privatelink.azurewebsites.us'
param default_tag_name string
param default_tag_value string

resource logic_app 'Microsoft.Web/sites@2024-04-01' = {
  name: logic_app_name
  location: location
  tags: {
    '${default_tag_name}': default_tag_value
  }
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${logic_app_name}.azurewebsites.us'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${logic_app_name}.scm.azurewebsites.us'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: logic_app_asp.id
    dnsConfiguration: {}
    vnetRouteAllEnabled: true
    vnetImagePullEnabled: false
    vnetContentShareEnabled: true
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 1
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    vnetBackupRestoreEnabled: false
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    endToEndEncryptionEnabled: false
    redundancyMode: 'None'
    publicNetworkAccess: 'Disabled'
    storageAccountRequired: false
    virtualNetworkSubnetId: subnet_out_id
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource logic_app_asp 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: '${logic_app_name}-asp'
  location: location
  tags: {
    '${default_tag_name}': default_tag_value
  }
  sku: {
    name: 'WS1'
    tier: 'WorkflowStandard'
    size: 'WS1'
    family: 'WS'
    capacity: 1
  }
  kind: 'elastic'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: true
    maximumElasticWorkerCount: 20
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource logic_app_web 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: logic_app
  name: 'web'
  location: location
  tags: {
    '${default_tag_name}': default_tag_value
  }
  properties: {
    numberOfWorkers: 1
    // defaultDocuments: [
    //   'Default.htm'
    //   'Default.html'
    //   'Default.asp'
    //   'index.htm'
    //   'index.html'
    //   'iisstart.htm'
    //   'default.aspx'
    //   'index.php'
    // ]
    netFrameworkVersion: 'v6.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    // virtualApplications: [
    //   {
    //     virtualPath: '/'
    //     physicalPath: 'site\\wwwroot'
    //     preloadEnabled: false
    //   }
    // ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetName: vnet_id
    vnetRouteAllEnabled: true
    vnetPrivatePortsCount: 2
    publicNetworkAccess: 'Disabled'
    cors: {
      supportCredentials: false
    }
    localMySqlEnabled: false
    managedServiceIdentityId: 3837
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 1
    functionAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: true
    minimumElasticInstanceCount: 1
    azureStorageAccounts: {}
  }
}

resource logic_app_pe 'Microsoft.Network/privateEndpoints@2024-03-01' = {
  name: '${logic_app_name}-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${logic_app_name}-pe'
        properties: {
          privateLinkServiceId: logic_app.id
          groupIds: [
            'sites'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: subnet_in_id
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
}

resource logic_app_pe_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-03-01' = {
  name: '${logic_app_name}-pe/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.azurewebsites.us-config'
        properties: {
          privateDnsZoneId: logic_app_private_dns_zone.id
        }
      }
    ]
  }
  dependsOn: [
    logic_app_pe
  ]
}

resource logic_app_private_dns_zone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
}
