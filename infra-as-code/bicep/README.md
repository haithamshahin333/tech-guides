# Azure Bicep

## Important Concepts to Review:

1. [Azure Resource Manager](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview)
    - [Resource Providers & Types](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types) and [AZ CLI Commands](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types#azure-cli) relevant to exploring resource providers/types
    - [Control Plane & Data Plane](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/control-plane-and-data-plane)

2. [ARM Templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/overview)
    - [Modularity](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/linked-templates?tabs=azure-powershell)
    - [Parameters](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/parameters)
    - [Outputs](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/outputs?tabs=azure-powershell)
    - [Deployment Scripts](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deployment-script-template)
    - [dependsOn](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/resource-dependency)

## Bicep Install

- [Install Bicep Tools](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)

## Bicep Concepts:

* Transpilation: Bicep Template - [bicep build] -> ARM JSON Template - [az deployment group create] -> Azure Resource Manager
* Deployment resource (Microsoft.Resources/deployments)
    - When you submit a Bicep deployment, you create or update a deployment resource
    - You can view the deployment history by referencing these deployments in the portal

- [Bicep File Format](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/file#bicep-format)

    ```bicep
    targetScope = '<scope>'

    @<decorator>(<argument>)
    param <parameter-name> <parameter-data-type> = <default-value>

    var <variable-name> = <variable-value>

    resource <resource-symbolic-name> '<resource-type>@<api-version>' = {
    <resource-properties>
    }

    module <module-symbolic-name> '<path-to-file>' = {
    name: '<linked-deployment-name>'
    params: {
        <parameter-names-and-values>
    }
    }

    output
    ```

    - `targetScope`: Default scope is set to the resource group level. Values can be resourceGroup, subscription, managementGroup, tenant. A module that is referenced can have a different scope than the rest of the bicep file.
    - `param`: Values that change across deployments and provided at deployment time. You can provide defaults.
    - `@decorator`: Parameter decorators describe the param and can constrain the values/types passed in.
    - `var`: Define a variable for reuse. Use expressions here and reference var in template.
    - `resource`: Keyword declaring the resource that you are deploying. `resource-symbolic-name` represents the symbolic name you can use to refer to this resource within the template (it is not the name of the resource deployed in azure).
    - `<resource-type>@<api-version>`: This references the resource provider/type that is being deployed and the associated API Version that defines the properties being passed in this template. Here is tbe upstream link to view that info: [arm/bicep reference](https://docs.microsoft.com/en-us/azure/templates/)
    - `module`: A module references a bicep file that you want to leverage in your template. This is for code reuse.
    - `output`: The return value from the deployment. Use this when there are values that you want to leverage for other operations within the template that depend on that resource deployment.

- Dependencies:

    * To view how bicep implicitely will capture the dependency, put the following file in `test-dependency.bicep` and run `bicep build --file test-dependency.bicep --stdout`.

    ```bicep
    resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
        name: 'toy-product-launch-plan'
        location: 'eastus'
        sku: {
            name: 'F1'
        }
    }

    resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
        name: 'toy-product-launch-1'
        location: 'eastus'
        properties: {
            serverFarmId: appServicePlan.id
            httpsOnly: true
        }
    }
    ```

    > Reference: Output from `bicep build --file test-dependency.bicep --stdout`
    ```json
    {
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "_generator": {
        "name": "bicep",
        "version": "0.4.1124.51302",
        "templateHash": "5247397555027350235"
        }
    },
    "resources": [
        {
        "type": "Microsoft.Web/serverfarms",
        "apiVersion": "2020-06-01",
        "name": "toy-product-launch-plan",
        "location": "eastus",
        "sku": {
            "name": "F1"
        }
        },
        {
        "type": "Microsoft.Web/sites",
        "apiVersion": "2020-06-01",
        "name": "toy-product-launch-1",
        "location": "eastus",
        "properties": {
            "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', 'toy-product-launch-plan')]",
            "httpsOnly": true
        },
        "dependsOn": [
            "[resourceId('Microsoft.Web/serverfarms', 'toy-product-launch-plan')]"
        ]
        }
    ]
    }
    ```

- [Parameters](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/parameters)

    - Format: `param <parameter-name> <parameter-data-type> = <default-value>`
    - Examples:
        ```bicep
        //basic default
        param demoParam string = 'Contoso'

        //use an expression in a default value
        //parameters are resolved before deployment time, so be sure to not sure functions that rely on runtime state
        param location string = resourceGroup().location

        //you can reference the value of one param in another
        param siteName string = 'site${uniqueString(resourceGroup().id)}'
        param hostingPlanName string = '${siteName}-plan'  
        
        //define a unique resource name with a good seed value
        //the seed value will get consistent names when deploying in same sub/rg
        //example: /subscriptions/3e57e557-826f-460b-8f1c-4ce38fd53b32/resourceGroups/MyResourceGroup
        param storageAccountName string = uniqueString(resourceGroup().id)

        //string interpolation to use expression string and concat with hard-coded value
        param storageAccountName string = 'toylaunch${uniqueString(resourceGroup().id)}'

        //decorator to specify allowed values
        //you can use this to use the same template but make it conditional on the env
        @allowed([
        'nonprod'
        'prod'
        ])
        param environmentType string

        var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
        var appServicePlanSkuName = (environmentType == 'prod') ? 'P2_v3' : 'F1'
        ```

- [Variables](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/variables)

    - Format: `var <variable-name> = <variable-value>`
    - Examples:
        ```bicep
        //dont need to specify data type like params
        //variable declared and defined at same time
        var stringVar = 'example value'

        //use prior values
        param inputValue string = 'deployment parameter'
        var stringVar = 'preset variable'
        var concatToVar =  '${stringVar}AddToVar'
        var concatToParam = '${inputValue}AddToParam'

        //use expressions and functions
        param storageNamePrefix string = 'stg'
        var storageName = '${toLower(storageNamePrefix)}${uniqueString(resourceGroup().id)}'

        //configuration vars
        //reference var
        @allowed([
        'test'
        'prod'
        ])
        param environmentName string

        var environmentSettings = {
        test: {
            instanceSize: 'Small'
            instanceCount: 1
        }
        prod: {
            instanceSize: 'Large'
            instanceCount: 4
        }
        }

        //reference var as follows
        environmentSettings[environmentName].instanceSize
        ```

- [Outputs](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/outputs?tabs=azure-powershell)

    - Format: `output <name> <data-type> = <value>`
    - Examples:
    ```bicep
    //publicIp is a symbolic name for a deployed resource
    //return a property from the deployed resource
    output hostname string = publicIP.properties.dnsSettings.fqdn

    //conditional output
    //useful is the deployment of a resource was conditional
    output <name> <data-type> = <condition> ? <true-value> : <false-value>

    //example of conditional output
    param deployStorage bool = true
    param storageName string
    param location string = resourceGroup().location

    resource myStorageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = if (deployStorage) {
    name: storageName
    location: location
    kind: 'StorageV2'
    sku:{
        name:'Standard_LRS'
        tier: 'Standard'
    }
    properties: {
        accessTier: 'Hot'
    }
    }

    output endpoint string = deployStorage ? myStorageAccount.properties.primaryEndpoints.blob : ''

    //get an output from a module
    <module-name>.outputs.<property-name>

    //get output from deployment on cli
    az deployment group show \
    -g <resource-group-name> \
    -n <deployment-name> \
    --query properties.outputs.resourceID.value
    ```

- [Modules](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/modules)

    - Format:
    ```bicep
    module <symbolic-name> '<path-to-file>' = {
        name: '<linked-deployment-name>'
        params: {
            <parameter-names-and-values>
        }
    }
    ```

    - Example:
    ```bicep
    module stgModule '../storageAccount.bicep' = {
        name: 'storageDeploy'
        params: {
            storagePrefix: 'examplestg1'
        }
    }
    ```

    - Path to Module can be a local file or external file (a file in private registry or template spec):
    ```bicep
    //assume a local file in a modules folder is leveraged
    module stgModule './modules/storageAccount.bicep' = {
        name: 'storageDeploy'
        params: {
            storagePrefix: 'examplestg1'
        }
    }

    //module in registry
    //the account doing the deployment would need proper permissions to access the registry
    //behind the scenes this relies on bicep restore which gets executed during a build - https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-cli#restore
    module <symbolic-name> 'br:<registry-name>.azurecr.io/<file-path>:<tag>' = {
    //example in registry
    module stgModule 'br:exampleregistry.azurecr.io/bicep/modules/storage:v1' = {
        name: 'storageDeploy'
        params: {
            storagePrefix: 'examplestg1'
        }
    }

    //apply a different scope to a module
    // set the target scope for this file
    targetScope = 'subscription'

    @minLength(3)
    @maxLength(11)
    param namePrefix string

    param location string = deployment().location

    var resourceGroupName = '${namePrefix}rg'

    resource newRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
    name: resourceGroupName
    location: location
    }

    module stgModule '../create-storage-account/main.bicep' = {
    name: 'storageDeploy'
    scope: newRG
    params: {
        storagePrefix: namePrefix
        location: location
    }
    }

    //obtain output from the module
    //you need to define the output in the module file and then reference like below in parent template
    output storageEndpoint object = stgModule.outputs.storageEndpoint
    ```

- [Scopes](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-to-resource-group?tabs=azure-cli)

    - How to deploy at different scopes:
        - Resource Group: `az deployment group create`
        - Subscription: `az deployment sub create`
        - Management Group: `az deployment mg create`
        - Tenant: `az deployment tenant create`
    - Use modules to specify the scope for different resources when all packaged together in the same parent bicep file which targets a different scope
        > Example is in the `fundamentals-bicep` folder
    - There are certain resources where you also can define the scope directly on the resource (meaning it doesn't need to be a module)

- [Child Resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/child-resource-name-type)

    > Only exist in the context of another resource

    - Format (Within Parent Resource):

    ```bicep
    resource <parent-resource-symbolic-name> '<resource-type>@<api-version>' = {
    <parent-resource-properties>

        resource <child-resource-symbolic-name> '<child-resource-type>' = {
            <child-resource-properties>
        }
    }
    ```

    - Format (Outside Parent Resource):

    ```bicep
    resource <parent-resource-symbolic-name> '<resource-type>@<api-version>' = {
    name: 'myParent'
    <parent-resource-properties>
    }

    resource <child-resource-symbolic-name> '<child-resource-type>@<api-version>' = {
    parent: <parent-resource-symbolic-name>
    name: 'myChild'
    <child-resource-properties>
    }
    ```

    - Reference a nested resource outside the parent (example with output):

    ```bicep
    output childAddressPrefix string = VNet1::VNet1_Subnet1.properties.addressPrefix
    ```

    - Example: 


    ```bicep
    resource storage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
        name: 'examplestorage'
        location: resourceGroup().location
        kind: 'StorageV2'
        sku: {
            name: 'Standard_LRS'
        }

        resource service 'fileServices' = {
            name: 'default'

                resource share 'shares' = {
                    name: 'exampleshare'
                }
        }
    }
    ```

- [Extension Resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scope-extension-resources)

    > Resource that modifies another resource. They are always attached to other resources
    > Examples include: Role Assignments, Policy Assignments, Locks, Diagnostic Settings
    > [Full List of Extension Resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/extension-resource-types)

    - Example for Resource:

    ```bicep
    resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2020-04-01' = {
        name: cosmosDBAccountName
        location: location
        properties: {
            // ...
        }
    }

    resource lockResource 'Microsoft.Authorization/locks@2016-09-01' = {
        scope: cosmosDBAccount
        name: 'DontDelete'
        properties: {
            level: 'CanNotDelete'
            notes: 'Prevents deletion of the toy data Cosmos DB account.'
        }
    }  
    ```

    - Example at Deployment Scope:

    ```bicep
    targetScope = 'subscription'

    @description('The principal to assign the role to')
    param principalId string

    @allowed([
    'Owner'
    'Contributor'
    'Reader'
    ])
    @description('Built-in role to assign')
    param builtInRoleType string

    @description('A new GUID used to identify the role assignment')
    param roleNameGuid string = newGuid()

    var role = {
        Owner: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
        Contributor: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
        Reader: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'
    }

    resource roleAssignSub 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
        name: roleNameGuid
        properties: {
            roleDefinitionId: role[builtInRoleType]
            principalId: principalId
        }
    }
    ```

- [Existing Resources](https://docs.microsoft.com/en-us/learn/modules/child-extension-bicep-templates/6-work-with-existing-resources)

    > Refer to resources in bicep that may already exist and were created elsewhere
    > Think of it as a placeholder so you can reference this resource in other resources/deployments within your template

    - Example:

    ```bicep
    resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
        name: 'toydesigndocs'
    }
    ```

    - Example with Child Resources:

    ```bicep
    resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
        name: 'toy-design-vnet'

        resource managementSubnet 'subnets' existing = {
            name: 'management'
        }
    }

    //reference later as example
    output managementSubnetResourceId string = vnet::managementSubnet.id
    ```

    - Example reference resource in different sub/rg:

    ```bicep
    resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
        scope: resourceGroup('f0750bbe-ea75-4ae5-b24d-a92ca601da2c', 'networking-rg')
        name: 'toy-design-vnet'
    }
    ```

- Example Fundamentals Deployment:

    > Review the folder `fundamentals-bicep` and run the following to deploy:

    ```bash
    # deploy nonprod env
    az deployment sub create --template-file main.bicep --parameters environmentType=nonprod --location eastus
    ```