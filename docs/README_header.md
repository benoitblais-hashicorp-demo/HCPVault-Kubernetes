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
