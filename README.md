<!-- BEGIN_TF_DOCS -->
# Vault Kubernetes Demo

This module configures a dedicated child namespace in HCP Vault Dedicated for a Kubernetes integration demonstration.
It prepares controlled access for an HCP Terraform Stack by creating the JWT auth method, JWT role, identity entity, alias, and policy required to bootstrap the rest of the demo.

## What This Demo Demonstrates

This demo demonstrates how to:

- Isolate a Kubernetes-focused demo environment in a child Vault namespace.
- Use HCP Terraform workload identity with Vault JWT authentication.
- Grant least-privileged administrative access so a Stack can configure Kubernetes auth and KVv2 in the child namespace.
- Avoid static credentials by using short-lived dynamic credentials for Terraform runs.

## Demo Components

The module provisions and configures the following components:

- A child Vault namespace dedicated to the demo.
- A Vault JWT auth backend for HCP Terraform workload identity tokens.
- A JWT auth role bound to a configurable identity claim.
- A Vault policy that permits management of KVv2 mounts, Kubernetes auth mounts, ACL policies, and token self-lookup.
- A Vault identity entity and alias associated with the HCP Terraform identity.

## Permissions

### Vault

The caller authenticating to Vault to apply this module must be able to:

- Create and manage namespaces.
- Enable and configure JWT auth methods.
- Create and update JWT auth roles.
- Create and manage Vault policies.
- Create and manage Vault identity entities and aliases.

## Authentications

Authentication to Vault can be configured using one of the following methods:

### Static Token

Use environment variables to authenticate with a static Vault token:

- `VAULT_ADDR`: Set to your HCP Vault Dedicated cluster address (for example `https://my-cluster.vault.hashicorp.cloud:8200`).
- `VAULT_TOKEN`: Set to a valid Vault token with the permissions listed above.
- `VAULT_NAMESPACE`: Set to the parent namespace (for example `admin`) if applicable.

### HCP Terraform Dynamic Credentials (Recommended)

For enhanced security, use HCP Terraform dynamic provider credentials to authenticate to Vault without storing static tokens.
This method uses workload identity (JWT/OIDC) to generate short-lived Vault tokens automatically.

- `TFC_VAULT_PROVIDER_AUTH`: Set to `true`.
- `TFC_VAULT_ADDR`: Set to your HCP Vault Dedicated cluster address.
- `TFC_VAULT_NAMESPACE`: Set to the child namespace created by this module.
- `TFC_VAULT_AUTH_PATH`: Set to the JWT auth backend path created by this module.
- `TFC_VAULT_RUN_ROLE`: Set to the JWT role name created by this module.

Documentation:

- [HCP Terraform Dynamic Credentials](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials)
- [Vault JWT Auth Method](https://developer.hashicorp.com/vault/docs/auth/jwt)

## Features

Key features included in this module:

- Configurable child namespace path for demo isolation.
- Configurable claim binding to support workspace or stack identity claims.
- Support for dynamic provider credentials to remove static secret usage from Terraform runs.
- Explicit outputs for namespace path, JWT auth path, JWT role name, identity entity name, and policy name.

## Demo Value Proposition

This module provides a repeatable and secure starting point for demonstrating Vault and Kubernetes integration with HCP Terraform.
By isolating all configuration in a child namespace and using workload identity-based authentication, the demo showcases practical security patterns that are production-relevant and easy to explain.

## Documentation

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.10)

- <a name="requirement_vault"></a> [vault](#requirement\_vault) (5.8.0)

## Modules

No modules.

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_entity_metadata"></a> [entity\_metadata](#input\_entity\_metadata)

Description: (Optional) Metadata attached to the Vault identity entity used by the HCP Terraform workspace for the Kubernetes integration demonstration.

Type: `map(string)`

Default: `{}`

### <a name="input_entity_name"></a> [entity\_name](#input\_entity\_name)

Description: (Optional) Name of the Vault identity entity representing the HCP Terraform workspace in the demo namespace.

Type: `string`

Default: `"demo-app"`

### <a name="input_hcp_jwt_backend_description"></a> [hcp\_jwt\_backend\_description](#input\_hcp\_jwt\_backend\_description)

Description: (Optional) Description of the JWT auth backend dedicated to the HCP Terraform workspace in the demo namespace.

Type: `string`

Default: `"JWT auth method for HCP Terraform workload identity tokens."`

### <a name="input_hcp_jwt_backend_path"></a> [hcp\_jwt\_backend\_path](#input\_hcp\_jwt\_backend\_path)

Description: (Optional) Mount path of the JWT auth backend used by the HCP Terraform workspace in the demo namespace.

Type: `string`

Default: `"jwt_hcp"`

### <a name="input_hcp_jwt_bound_claims_type"></a> [hcp\_jwt\_bound\_claims\_type](#input\_hcp\_jwt\_bound\_claims\_type)

Description: (Optional) Type of bound claims matching for the Vault JWT role. Use 'glob' to allow wildcard matching (useful for Stacks).

Type: `string`

Default: `"glob"`

### <a name="input_hcp_jwt_bound_issuer"></a> [hcp\_jwt\_bound\_issuer](#input\_hcp\_jwt\_bound\_issuer)

Description: (Optional) Expected issuer claim for HCP Terraform workload identity JWT tokens.

Type: `string`

Default: `"https://app.terraform.io"`

### <a name="input_hcp_jwt_discovery_url"></a> [hcp\_jwt\_discovery\_url](#input\_hcp\_jwt\_discovery\_url)

Description: (Optional) OIDC discovery URL used by Vault to validate HCP Terraform workload identity JWT tokens.

Type: `string`

Default: `"https://app.terraform.io"`

### <a name="input_hcp_jwt_entity_alias_name"></a> [hcp\_jwt\_entity\_alias\_name](#input\_hcp\_jwt\_entity\_alias\_name)

Description: (Optional) Explicit Vault identity alias name for the HCP Terraform workload identity.

Type: `string`

Default: `"hcp-terraform"`

### <a name="input_hcp_jwt_role_name"></a> [hcp\_jwt\_role\_name](#input\_hcp\_jwt\_role\_name)

Description: (Optional) Name of the Vault JWT role used by the HCP Terraform workspace to obtain demo-scoped access in the namespace.

Type: `string`

Default: `"jwt_hcp_role"`

### <a name="input_hcp_jwt_stack_name"></a> [hcp\_jwt\_stack\_name](#input\_hcp\_jwt\_stack\_name)

Description: (Optional) The HCP Terraform Stack name to bind to the Vault role. Setting this enables the JWT backend.

Type: `string`

Default: `""`

### <a name="input_hcp_jwt_token_max_ttl"></a> [hcp\_jwt\_token\_max\_ttl](#input\_hcp\_jwt\_token\_max\_ttl)

Description: (Optional) Maximum lifetime in seconds for Vault tokens issued to the HCP Terraform workspace.

Type: `number`

Default: `600`

### <a name="input_hcp_jwt_token_ttl"></a> [hcp\_jwt\_token\_ttl](#input\_hcp\_jwt\_token\_ttl)

Description: (Optional) Default lifetime in seconds for Vault tokens issued to the HCP Terraform workspace.

Type: `number`

Default: `300`

### <a name="input_hcp_jwt_user_claim"></a> [hcp\_jwt\_user\_claim](#input\_hcp\_jwt\_user\_claim)

Description: (Optional) JWT claim used as the Vault entity alias source for auditability.

Type: `string`

Default: `"terraform_stack_name"`

### <a name="input_namespace_path"></a> [namespace\_path](#input\_namespace\_path)

Description: (Optional) Child Vault namespace path used to isolate the Kubernetes and secret-management demonstration.

Type: `string`

Default: `"kubernetes-demo"`

## Resources

The following resources are used by this module:

- [vault_identity_entity.this](https://registry.terraform.io/providers/hashicorp/vault/5.8.0/docs/resources/identity_entity) (resource)
- [vault_identity_entity_alias.this](https://registry.terraform.io/providers/hashicorp/vault/5.8.0/docs/resources/identity_entity_alias) (resource)
- [vault_jwt_auth_backend.jwt_hcp](https://registry.terraform.io/providers/hashicorp/vault/5.8.0/docs/resources/jwt_auth_backend) (resource)
- [vault_jwt_auth_backend_role.jwt_hcp](https://registry.terraform.io/providers/hashicorp/vault/5.8.0/docs/resources/jwt_auth_backend_role) (resource)
- [vault_namespace.this](https://registry.terraform.io/providers/hashicorp/vault/5.8.0/docs/resources/namespace) (resource)
- [vault_policy.hcp_workspace](https://registry.terraform.io/providers/hashicorp/vault/5.8.0/docs/resources/policy) (resource)

## Outputs

The following outputs are exported:

### <a name="output_entity_name"></a> [entity\_name](#output\_entity\_name)

Description: Name of the HCP Terraform workspace Vault entity. Null when no NHI auth method is configured.

### <a name="output_jwt_hcp_backend_path"></a> [jwt\_hcp\_backend\_path](#output\_jwt\_hcp\_backend\_path)

Description: Mount path of the HCP Terraform JWT auth backend in the child namespace. Null when `hcp_jwt_bound_claim_value` is not set.

### <a name="output_jwt_hcp_role_name"></a> [jwt\_hcp\_role\_name](#output\_jwt\_hcp\_role\_name)

Description: Name of the Vault role that the HCP Terraform workspace or stack must use for dynamic provider credentials. Null when `hcp_jwt_bound_claim_value` is not set.

### <a name="output_namespace_path"></a> [namespace\_path](#output\_namespace\_path)

Description: Fully qualified path of the child namespace.

### <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name)

Description: Name of the Vault policy assigned to the HCP Terraform workspace identity in the child namespace for the Kubernetes integration demonstration.

<!-- markdownlint-enable -->
# External Documentation

- [Vault Namespaces](https://developer.hashicorp.com/vault/docs/enterprise/namespaces)
- [Vault JWT/OIDC Auth Method](https://developer.hashicorp.com/vault/docs/auth/jwt)
- [Vault Policy Concepts](https://developer.hashicorp.com/vault/docs/concepts/policies)
- [Vault ACL Policy Paths for System Backends](https://developer.hashicorp.com/vault/api-docs/system)
- [HCP Terraform Dynamic Provider Credentials](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials)
- [Vault Provider for Terraform](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
<!-- END_TF_DOCS -->