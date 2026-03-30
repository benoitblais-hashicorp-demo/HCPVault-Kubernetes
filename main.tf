# ------------------------------------------------------------------------------
# Child Namespace
# ------------------------------------------------------------------------------

resource "vault_namespace" "this" {
  path = var.namespace_path
}

# ------------------------------------------------------------------------------
# HCP Terraform — JWT Auth
#
# HCP Terraform issues workload identity JWT tokens signed by:
#   https://app.terraform.io
#
# The standard audience for Vault dynamic provider credentials is
# "vault.workload.identity". Access is restricted to a single HCP Terraform
# identity (workspace or stack) via a configurable bound claim.
# ------------------------------------------------------------------------------

resource "vault_jwt_auth_backend" "jwt_hcp" {
  count = length(trimspace(var.hcp_jwt_bound_claim_value)) > 0 ? 1 : 0

  namespace          = vault_namespace.this.path_fq
  description        = var.hcp_jwt_backend_description
  path               = var.hcp_jwt_backend_path
  oidc_discovery_url = var.hcp_jwt_discovery_url
  bound_issuer       = var.hcp_jwt_bound_issuer
}

resource "vault_jwt_auth_backend_role" "jwt_hcp" {
  count = length(vault_jwt_auth_backend.jwt_hcp) > 0 ? 1 : 0

  namespace = vault_namespace.this.path_fq
  backend   = vault_jwt_auth_backend.jwt_hcp[0].path
  role_name = var.hcp_jwt_role_name
  role_type = "jwt"

  # "vault.workload.identity" is the standard audience for Vault dynamic
  # provider credentials in HCP Terraform and Terraform Enterprise.
  bound_audiences = ["vault.workload.identity"]

  # Restrict authentication to the trusted HCP Terraform identity.
  bound_claims = {
    (var.hcp_jwt_bound_claim_name) = var.hcp_jwt_bound_claim_value
  }

  # Use a configurable claim as the Vault entity alias source for auditability.
  user_claim = var.hcp_jwt_user_claim

  token_policies          = ["default", vault_policy.hcp_workspace[0].name]
  token_ttl               = var.hcp_jwt_token_ttl
  token_max_ttl           = var.hcp_jwt_token_max_ttl
  token_no_default_policy = true
}

# ------------------------------------------------------------------------------
# HCP Workspace Policy
#
# Grants the child-workspace identity permissions to:
#   - Enable and manage KVv2 mounts at any mount path
#   - Enable and manage Kubernetes auth methods at any mount path
#   - Create and manage ACL policies
#   - Lookup its own token
# ------------------------------------------------------------------------------

resource "vault_policy" "hcp_workspace" {
  count = length(vault_jwt_auth_backend.jwt_hcp) > 0 ? 1 : 0

  namespace = vault_namespace.this.path_fq
  name      = "${var.hcp_jwt_role_name}_admin"
  policy    = <<-EOT
    path "sys/mounts" {
      capabilities = ["read", "list"]
    }

    path "sys/mounts/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }

    path "sys/auth" {
      capabilities = ["read", "list"]
    }

    path "sys/auth/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }

    path "sys/policies/acl" {
      capabilities = ["read", "list"]
    }

    path "sys/policies/acl/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }

    path "auth/token/lookup-self" {
      capabilities = ["read"]
    }
  EOT
}

# ------------------------------------------------------------------------------
# Identity Entities
#
# Two distinct entities are created to clearly separate concerns:
#   - nhi: represents the application/machine identity (GitHub Actions, HCP Terraform)
#   - hi: represents the human operator identity (userpass, GitHub PAT)
# Auth-method-specific aliases are linked to their respective entity so that
# policies, audit logs, and metadata remain cleanly separated.
# ------------------------------------------------------------------------------

# NHI entity — created only when at least one NHI auth method is enabled.
resource "vault_identity_entity" "this" {
  count = length(vault_jwt_auth_backend.jwt_hcp) > 0 ? 1 : 0

  namespace = vault_namespace.this.path_fq
  name      = var.entity_name
  metadata  = var.entity_metadata
}

# ------------------------------------------------------------------------------
# Identity Entity Aliases
#
# Each alias links an auth-method-specific login identity to the shared entity.
# The alias name must match the value of the role's user_claim at login time:
#   - GitHub Actions : user_claim = "repository"              → value = "org/repo"
#   - HCP Terraform  : user_claim = configurable                → value = claim value
#   - Userpass        : alias name = username
#   - GitHub PAT      : alias name = GitHub login (username)
# ------------------------------------------------------------------------------

resource "vault_identity_entity_alias" "this" {
  count = length(vault_identity_entity.this) > 0 ? 1 : 0

  namespace      = vault_namespace.this.path_fq
  name           = coalesce(var.hcp_jwt_entity_alias_name, var.hcp_jwt_bound_claim_value)
  mount_accessor = vault_jwt_auth_backend.jwt_hcp[0].accessor
  canonical_id   = vault_identity_entity.this[0].id
}
