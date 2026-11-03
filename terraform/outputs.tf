output "resource_group_name" { value = azurerm_resource_group.lab.name }
output "storage_account_name" { value = azurerm_storage_account.lab.name }
output "container_name" { value = azurerm_storage_container.reports.name }
output "container_resource_id" { value = azurerm_storage_container.reports.resource_manager_id }
output "tenant_id" { value = data.azurerm_client_config.current.tenant_id }
output "application_client_id" { value = azuread_application.reporting.client_id }
output "service_principal_object_id" { value = azuread_service_principal.reporting.object_id }
