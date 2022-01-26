# Overview of API Management Concepts

## Why API Management
- Provide API Documentation, Testing, Code Samples
- Onboard / Offboard Users
- Managing API Subscriptions and Keys
- Implementing API Revisions and Versioning
- Implementing API access controls, such as authentication and rate limiting
- API Reporting for Usage and Errors
- Obtain Analytics on API Usage

## API Management Concepts

> Important: APIM does not host your APIs. It's a facade/gateway for APIs. You host the APIs wherever you prefer and with APIM you can decouple the usage of policies and governance without needing to directly touch the API/Codebase

- [API Gateway](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts#api-gateway)
    - Gateway accepts API calls and routes to configured backends
    - Verifies API Keys, JWT Tokens, Certificates, Credentials, etc.
    - Enforces Usage Quotas and Rate Limits
    - Applies Policies to Transform Requests/Responses
    - Can cache responses
    - Emit metrics/logs

- [Management/Administrative Plane](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts#management-plane)
    - Provision/Configure APIM Settings
    - Define/Import API Schemas
    - Package APIs into Products
    - Setup Policies on APIs
    - Get Insights on Analytics
    - Manage Users and Developer Portal

- [Developer Portal](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts#developer-portal)
    - API Documentation
    - Call/Test API via interactive console
    - Create an account and subscripe for API Keys
    - Download API definitions
    - Manage API Keys
    - You likely will need to enable CORS to test from the portal
        - Behind the scenes, this applies a policy to APIM at the global level to allow CORS from the dev portal origin
        - [Cross Domain Policies](https://docs.microsoft.com/en-us/azure/api-management/api-management-cross-domain-policies)
    - [Add AAD Auth/Sign In for Users](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-aad?WT.mc_id=Portal-fx#authorize-developer-accounts-by-using-azure-ad)
    - [Adding AAD Groups to the Portal](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-aad?WT.mc_id=Portal-fx#add-an-external-azure-ad-group)

- [APIs](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts#apis)
    - Each API represents a set of operations available to app developers to consume
    - API requests sent to backend service that implements the API

- [Products](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts#products)
    - Groups of APIs that can be open or protected
    - Protected products require a subscription key
    - Once you publish a product, it will be visible to those groups that have access to that product
    - You can apply access control to your particular groups per product
        - Once a group is associated with a products, users in that group can view and subscribe to the product [reference](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-create-groups#-associate-a-group-with-a-product)
    - You can leverage [AAD](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-aad) for developer account sign-in and groups

- [Groups](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts#groups)
    - Used to manage the visilibity of products to developers
    - You can leverage the built-in groups, create custom groups, or use external groups in AAD
    - [Leverage AAD](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-aad)

- [Developers](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts#developers)
    - User accounts that can access for the dev portal and subscribe to products for which they have visibility
    - [Leverage AAD](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-aad)

- [Policies](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts#policies)
    - Use policies to change/secure API behavior through configuration
    - They can be applied at different scopes: global, product, API, API Operation
    - [Policy Reference](https://docs.microsoft.com/en-us/azure/api-management/set-edit-policies)

- [APIM SKUs](https://docs.microsoft.com/en-us/azure/api-management/api-management-features)
    - Review the different features available for the different APIM SKUs

