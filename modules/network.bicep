// Required Parameters:
param project_prefix string
param env_prefix string 
param location string 

// Configuration Paramters:
// Network Implementation:
param existing_network_name string = ''

// Optional Parameters:
param project_cidr string = '10.0.1.0/24'
param storage_cidr string = '10.0.2.0/24'
param logic_app_in_cidr string = '10.0.3.0/24'
param logic_app_out_cidr string = '10.0.4.0/24'
param jumpbox_cidr string = '10.0.5.0/24'
param bastion_cidr string = '10.0.6.0/24'

param deploy_jumpbox bool = true

param default_tag_name string
param default_tag_value string

resource virtual_network 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: existing_network_name
}

// Subnet for pod pods
resource default_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: '${project_prefix}-${env_prefix}-project'
  parent: virtual_network
  properties: {
    addressPrefix: project_cidr
  }
  dependsOn: [
    virtual_network
  ]
}

resource storage_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: '${project_prefix}-${env_prefix}-storage'
  parent: virtual_network 
  properties: {
    addressPrefix: storage_cidr
  }
  dependsOn: [
    virtual_network, default_subnet
  ]
}

resource logic_app_in_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: '${project_prefix}-${env_prefix}-logic-app-in'
  parent: virtual_network 
  properties: {
    addressPrefix: logic_app_in_cidr
  }
  dependsOn: [
    virtual_network, storage_subnet
  ]
}

resource logic_app_out_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: '${project_prefix}-${env_prefix}-logic-app-out'
  parent: virtual_network 
  properties: {
    addressPrefix: logic_app_out_cidr
    delegations: [
      {
        name: 'MicrosoftWebServerFarmsDelegation'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
  dependsOn: [
    virtual_network, logic_app_in_subnet
  ]
}

resource jumpbox_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = if (deploy_jumpbox) {
  name: '${project_prefix}-${env_prefix}-jump-box'
  parent: virtual_network 
  properties: {
    addressPrefix: jumpbox_cidr
  }
  dependsOn: [
    virtual_network, logic_app_out_subnet
  ]
}

// Bastion Subnet
resource bastion_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = if (deploy_jumpbox) {
  name: '${project_prefix}-${env_prefix}-bastion'
  parent: virtual_network 
  properties: {
    addressPrefix: bastion_cidr
  }
  dependsOn: [
    virtual_network, jumpbox_subnet
  ]
}

// Bastion Host
resource bastion_host 'Microsoft.Network/bastionHosts@2023-09-01' = if (deploy_jumpbox) {
  name: '${project_prefix}-${env_prefix}-bastion-host'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bastionIPConfig'
        properties: {
          subnet: {
            id: bastion_subnet.id
          }
          publicIPAddress: {
            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/publicIPAddresses/${project_prefix}-${env_prefix}-bastion-pip'
          }
        }
      }
    ]
  }
  dependsOn: [
    bastion_subnet
  ]
}

output id string = virtual_network.id
output name string = virtual_network.name
output primary_subnet_id string = virtual_network.properties.subnets[0].id
output storage_subnet_id string = storage_subnet.id
output logic_app_in_subnet_id string = logic_app_in_subnet.id
output logic_app_out_subnet_id string = logic_app_out_subnet.id
output jumpbox_subnet_id string = jumpbox_subnet.id
