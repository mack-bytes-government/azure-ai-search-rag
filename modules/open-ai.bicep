param openai_name string
param location string = resourceGroup().location
param subnet_id string

// Tag Configuration:
param default_tag_name string
param default_tag_value string

@secure()
param admin_email string

resource openai 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: openai_name
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: subnet_id
        }
      ]
    }
    userOwnedStorage: []
    publicNetworkAccess: 'Disabled'
    email: admin_email
  }
  tags: {
    default_tag_name: default_tag_value
  }
}

output openaiId string = openai.id
output openaiName string = openai.name
