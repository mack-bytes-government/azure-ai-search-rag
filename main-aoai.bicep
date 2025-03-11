// Basic Parameters
@description('The project abbreviation')
param project_prefix string 

@description('The environment prefix (dev, test, prod)')
@minLength(1)
@maxLength(100)
param env_prefix string

// Network Implementation:
@description('The id of the subnet')
param subnet_id string

param admin_email string

// Tag Configuration:
param default_tag_name string
param default_tag_value string

module aoai './modules/open-ai.bicep' = {
  name: 'aoai'
  params: {
    openai_name: '${project_prefix}-${env_prefix}-aoai'
    location: resourceGroup().location
    subnet_id: subnet_id
    admin_email: admin_email
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
}
