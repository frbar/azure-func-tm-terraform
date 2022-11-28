locals {
  locations = [var.location1, var.location2]
}

resource "azurerm_resource_group" "poc" {
  name     = "${var.env_name}-rg"
  location = local.locations[0]
}

resource "azurerm_application_insights" "poc" {
  name                = "${var.env_name}-application-insights"
  location            = azurerm_resource_group.poc.location
  resource_group_name = azurerm_resource_group.poc.name
  application_type    = "web"
}

resource "azurerm_storage_account" "poc" {
  count                    = 2
  name                     = "${var.env_name}func${count.index}"
  resource_group_name      = azurerm_resource_group.poc.name
  location                 = azurerm_resource_group.poc.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "poc" {
  count               = 2
  name                = "${var.env_name}-plan-${count.index}"
  resource_group_name = azurerm_resource_group.poc.name
  location            = azurerm_resource_group.poc.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_windows_function_app" "poc" {
  count               = 2
  name                = "${var.env_name}-func-${count.index}"
  resource_group_name = azurerm_resource_group.poc.name
  location            = azurerm_resource_group.poc.location

  storage_account_name       = azurerm_storage_account.poc[count.index].name
  storage_account_access_key = azurerm_storage_account.poc[count.index].primary_access_key
  service_plan_id            = azurerm_service_plan.poc[count.index].id

  site_config {
    
  }

  app_settings = {
    "AzureWebJobsStorage"            = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.poc[count.index].name};EndpointSuffix=core.windows.net;AccountKey=${azurerm_storage_account.poc[count.index].primary_access_key}"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "0",
    "WEBSITE_RUN_FROM_PACKAGE"       = "1",
    "FUNCTIONS_WORKER_RUNTIME"       = "dotnet-isolated",
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.poc.instrumentation_key,
    "FUNCTIONS_EXTENSION_VERSION"    = "~4"
  }

  # lifecycle {
  #   ignore_changes = [
  #     app_settings["WEBSITE_RUN_FROM_PACKAGE"]
  #   ]
  # }
}