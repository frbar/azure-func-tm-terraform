resource "azurerm_traffic_manager_profile" "poc" {
  name                   = "${var.env_name}-tm"
  resource_group_name    = azurerm_resource_group.poc.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = var.env_name
    ttl           = 5             # low TTL for testing purposes
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/api/health"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "poc" {
  count              = 2
  name               = "func-${count.index}"
  profile_id         = azurerm_traffic_manager_profile.poc.id
  weight             = 100
  target_resource_id = azurerm_windows_function_app.poc[count.index].id
  
  custom_header {
    name  = "host"
    value = azurerm_windows_function_app.poc[count.index].default_hostname
  }
}