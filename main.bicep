// Basic Parameters
@description('The project abbreviation')
param project_prefix string 

@description('The environment prefix (dev, test, prod)')
@minLength(1)
@maxLength(100)
param env_prefix string

// Network Implementation:
@description('The id of an existing network to be passed')
param existing_network_name string

// Subnet Configuration
param project_cidr string = '10.0.1.0/24'
param storage_cidr string = '10.0.2.0/24'
param logic_app_in_cidr string = '10.0.3.0/24'
param logic_app_out_cidr string = '10.0.4.0/24'

// Tag Configuration:
param default_tag_name string
param default_tag_value string

// Jumpbox Configuration
param deploy_jumpbox bool = false

// Deployment Control:
param deploy_search bool = true
param deploy_logic_app bool = true  
param deploy_storage bool = true


//Deploy into a existing network
module existing_network './modules/network.bicep' = {
  name: 'existing-network'
  params: {
    location: resourceGroup().location
    project_prefix: project_prefix
    env_prefix: env_prefix
    existing_network_name: existing_network_name
    project_cidr: project_cidr
    storage_cidr: storage_cidr
    logic_app_in_cidr: logic_app_in_cidr
    logic_app_out_cidr: logic_app_out_cidr
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
    deploy_jumpbox: deploy_jumpbox
  }
}

module storage './modules/storage.bicep' = if (deploy_storage) {
  name: 'storage'
  params: {
    storage_account_name: '${project_prefix}${env_prefix}stg'
    location: resourceGroup().location
    subnet_id: existing_network.outputs.storage_subnet_id
    vnet_id: existing_network.outputs.id
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
  dependsOn: [
    existing_network
  ]
}

module search './modules/search.bicep' = if (deploy_search) {
  name: 'search'
  params: {
    search_name: '${project_prefix}${env_prefix}search'
    location: resourceGroup().location
    subnet_id: existing_network.outputs.primary_subnet_id
    vnet_id: existing_network.outputs.id
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
  dependsOn: [
    storage
  ]
}

module logic_app './modules/logic-app.bicep' = if (deploy_logic_app) {
  name: 'logic-app'
  params: {
    logic_app_name: '${project_prefix}-${env_prefix}-logicapp'
    location: resourceGroup().location
    subnet_in_id: existing_network.outputs.logic_app_in_subnet_id
    subnet_out_id: existing_network.outputs.logic_app_out_subnet_id
    vnet_id: existing_network.outputs.id
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
  dependsOn: [
    search
  ]
}

output storage_subnet_id string = existing_network.outputs.storage_subnet_id
output logic_app_in_subnet_id string = existing_network.outputs.logic_app_in_subnet_id
output logic_app_out_subnet_id string = existing_network.outputs.logic_app_out_subnet_id
output search_subnet_id string = existing_network.outputs.primary_subnet_id
output jumpbox_subnet_id string = deploy_jumpbox ? existing_network.outputs.jumpbox_subnet_id : 'N/A'
