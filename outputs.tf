output "entity_name" {
  description = "Name of the HCP Terraform workspace Vault entity. Null when no NHI auth method is configured."
  value       = try(vault_identity_entity.this[0].name, null)
}

output "jwt_hcp_backend_path" {
  description = "Mount path of the HCP Terraform JWT auth backend in the child namespace. Null when ``hcp_jwt_bound_claim_value`` is not set."
  value       = try(vault_jwt_auth_backend.jwt_hcp[0].path, null)
}

output "jwt_hcp_role_name" {
  description = "Name of the Vault role that the HCP Terraform workspace or stack must use for dynamic provider credentials. Null when ``hcp_jwt_bound_claim_value`` is not set."
  value       = try(vault_jwt_auth_backend_role.jwt_hcp[0].role_name, null)
}

output "namespace_path" {
  description = "Fully qualified path of the child namespace."
  value       = vault_namespace.this.path_fq
}

output "policy_name" {
  description = "Name of the Vault policy assigned to the HCP Terraform workspace identity in the child namespace for the Kubernetes integration demonstration."
  value       = vault_policy.hcp_workspace[0].name
}