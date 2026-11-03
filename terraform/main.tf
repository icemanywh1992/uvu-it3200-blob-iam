data "azurerm_client_config" "current" {}

locals {
  suffix       = "uvu-it3200-${var.student_id}"
  storage_name = "stuvuit3200${var.student_id}${var.storage_suffix}"
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-${local.suffix}-blob"
  location = var.location
}

resource "azurerm_storage_account" "lab" {
  name                            = local.storage_name
  resource_group_name             = azurerm_resource_group.lab.name
  location                        = azurerm_resource_group.lab.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = true
}

# ARM-management-plane creation avoids needing a data-plane role just to
# provision the container. Actual deployment permissions must be checked.
resource "azurerm_storage_container" "reports" {
  name                  = "reports"
  storage_account_id    = azurerm_storage_account.lab.id
  container_access_type = "private"
}

resource "azuread_application" "reporting" {
  display_name = "sp-${local.suffix}-blob-reporting"
}

resource "azuread_service_principal" "reporting" {
  client_id = azuread_application.reporting.client_id
}

# Intentionally do not create a client secret in Terraform state.
# Obtain an approved short-lived credential outside Terraform for lab tests.
# Start with enable_blob_role=false to demonstrate denied data access.
resource "azurerm_role_assignment" "reporting_blob_contributor" {
  count                = var.enable_blob_role ? 1 : 0
  scope                = azurerm_storage_container.reports.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.reporting.object_id
}
