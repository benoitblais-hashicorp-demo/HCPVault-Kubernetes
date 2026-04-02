variable "hcp_jwt_stack_name" {
  type        = string
  description = "(Optional) The HCP Terraform Stack name to bind to the Vault role. Setting this enables the JWT backend."
  default     = ""
}

variable "hcp_jwt_bound_claims_type" {
  type        = string
  description = "(Optional) Type of bound claims matching for the Vault JWT role. Use 'glob' to allow wildcard matching (useful for Stacks)."
  default     = "glob"

  validation {
    condition     = contains(["string", "glob"], var.hcp_jwt_bound_claims_type)
    error_message = "`hcp_jwt_bound_claims_type` must be either \"string\" or \"glob\"."
  }
}

variable "entity_metadata" {
  type        = map(string)
  description = "(Optional) Metadata attached to the Vault identity entity used by the HCP Terraform workspace for the Kubernetes integration demonstration."
  default     = {}

  validation {
    condition     = alltrue([for key, value in var.entity_metadata : length(trimspace(key)) > 0 && length(trimspace(value)) > 0])
    error_message = "`entity_metadata` keys and values must be non-empty strings when provided."
  }
}

variable "entity_name" {
  type        = string
  description = "(Optional) Name of the Vault identity entity representing the HCP Terraform workspace in the demo namespace."
  default     = "demo-app"

  validation {
    condition     = length(trimspace(var.entity_name)) > 0
    error_message = "`entity_name` must not be empty."
  }
}

variable "hcp_jwt_backend_description" {
  type        = string
  description = "(Optional) Description of the JWT auth backend dedicated to the HCP Terraform workspace in the demo namespace."
  default     = "JWT auth method for HCP Terraform workload identity tokens."

  validation {
    condition     = length(trimspace(var.hcp_jwt_backend_description)) > 0
    error_message = "`hcp_jwt_backend_description` must not be empty."
  }
}

variable "hcp_jwt_backend_path" {
  type        = string
  description = "(Optional) Mount path of the JWT auth backend used by the HCP Terraform workspace in the demo namespace."
  default     = "jwt_hcp"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9_-]*$", var.hcp_jwt_backend_path))
    error_message = "`hcp_jwt_backend_path` must contain only lowercase letters, numbers, hyphen (-), and underscore (_), and it must start with a lowercase letter or number."
  }

  validation {
    condition     = var.hcp_jwt_backend_path != "kubernetes"
    error_message = "`hcp_jwt_backend_path` must not be \"kubernetes\" because that value is reserved for the Kubernetes auth method mount path."
  }
}


variable "hcp_jwt_bound_issuer" {
  type        = string
  description = "(Optional) Expected issuer claim for HCP Terraform workload identity JWT tokens."
  default     = "https://app.terraform.io"

  validation {
    condition     = can(regex("^https://", var.hcp_jwt_bound_issuer))
    error_message = "`hcp_jwt_bound_issuer` must be a valid \"https://\" URL."
  }
}

variable "hcp_jwt_discovery_url" {
  type        = string
  description = "(Optional) OIDC discovery URL used by Vault to validate HCP Terraform workload identity JWT tokens."
  default     = "https://app.terraform.io"

  validation {
    condition     = can(regex("^https://", var.hcp_jwt_discovery_url))
    error_message = "`hcp_jwt_discovery_url` must be a valid \"https://\" URL."
  }
}

variable "hcp_jwt_entity_alias_name" {
  type        = string
  description = "(Optional) Explicit Vault identity alias name for the HCP Terraform workload identity."
  default     = "hcp-terraform"

  validation {
    condition     = length(trimspace(var.hcp_jwt_entity_alias_name)) > 0
    error_message = "``hcp_jwt_entity_alias_name`` must not be an empty string when set."
  }
}

variable "hcp_jwt_role_name" {
  type        = string
  description = "(Optional) Name of the Vault JWT role used by the HCP Terraform workspace to obtain demo-scoped access in the namespace."
  default     = "jwt_hcp_role"

  validation {
    condition     = length(trimspace(var.hcp_jwt_role_name)) > 0
    error_message = "`hcp_jwt_role_name` must not be empty."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]*$", var.hcp_jwt_role_name))
    error_message = "`hcp_jwt_role_name` must contain only letters, numbers, dot (.), underscore (_), and hyphen (-), and it must start with a letter or number."
  }
}

variable "hcp_jwt_token_max_ttl" {
  type        = number
  description = "(Optional) Maximum lifetime in seconds for Vault tokens issued to the HCP Terraform workspace."
  default     = 600

  validation {
    condition     = var.hcp_jwt_token_max_ttl > 0
    error_message = "`hcp_jwt_token_max_ttl` must be greater than 0."
  }
}

variable "hcp_jwt_token_ttl" {
  type        = number
  description = "(Optional) Default lifetime in seconds for Vault tokens issued to the HCP Terraform workspace."
  default     = 300

  validation {
    condition     = var.hcp_jwt_token_ttl > 0
    error_message = "`hcp_jwt_token_ttl` must be greater than 0."
  }

  validation {
    condition     = var.hcp_jwt_token_ttl <= var.hcp_jwt_token_max_ttl
    error_message = "`hcp_jwt_token_ttl` must be less than or equal to `hcp_jwt_token_max_ttl`."
  }
}

variable "hcp_jwt_user_claim" {
  type        = string
  description = "(Optional) JWT claim used as the Vault entity alias source for auditability."
  default     = "terraform_workspace_name"

  validation {
    condition     = length(trimspace(var.hcp_jwt_user_claim)) > 0
    error_message = "``hcp_jwt_user_claim`` must not be empty."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.hcp_jwt_user_claim))
    error_message = "``hcp_jwt_user_claim`` must contain only \"letters\", \"numbers\", and \"underscore (_)\"."
  }
}

variable "namespace_path" {
  type        = string
  description = "(Optional) Child Vault namespace path used to isolate the Kubernetes and secret-management demonstration."
  default     = "kubernetes-demo"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.namespace_path))
    error_message = "`namespace_path` must contain only lowercase letters, numbers, and hyphen (-), and it must start and end with a lowercase letter or number."
  }
}
