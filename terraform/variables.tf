variable "subscription_id" {
  description = "Authorized Azure subscription ID"
  type        = string
}
variable "location" {
  description = "Azure region"
  type        = string
  default     = "westus2"
}
variable "student_id" {
  description = "Short lowercase alphanumeric identifier"
  type        = string
  default     = "yeewi"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.student_id))
    error_message = "Use only lowercase letters and digits."
  }
}
variable "storage_suffix" {
  description = "Unique lowercase alphanumeric suffix for globally unique storage account name"
  type        = string
}
variable "enable_blob_role" {
  description = "Set false for the pre-RBAC negative test; true to grant container-scoped access"
  type        = bool
  default     = false
}
