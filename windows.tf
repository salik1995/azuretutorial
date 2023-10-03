locals {
   windows_names=["w1","w2","w3","w4""w5"]

resource "azurerm_service_plan" "deploying" {
  for_each            =  {for windows in local.windows_names: windows=>windows}
  name                = each.key
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_resource_group.tutorial.location
  sku_name            = "P1v2"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "start" {
  for_each            =  {for windows in local.windows_names: windows=>windows}
  name                = each.key
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.deploying.location
  service_plan_id     = azurerm_service_plan.deploying.id

  site_config {}
}
