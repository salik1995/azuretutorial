locals {
   wwindow_names=["wowxabc","wowcdb","wowbvc","wow098","wow3232"]
}
resource "azurerm_service_plan" "sim" {
  for_each            =  {for wwindow in local.wwindow_names: wwindow=>wwindow}
  name                = each.key
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_resource_group.tutorial.location
  os_type             = "Windows"
  sku_name            = "P1v2"
}

resource "azurerm_windows_web_app" "data" {
  for_each            =  {for wwindow in local.wwindow_names: wwindow=>wwindow}
  name                = "example-windows-web-app"
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_service_plan.sim["wowxabc"].location
  service_plan_id     = azurerm_service_plan.sim["wowxabc"].id

  site_config {}
}

resource "azurerm_windows_web_app_slot" "animal" {
  name           = "example-slot"
  app_service_id = azurerm_windows_web_app.data["wowxabc"].id

  site_config {}
}
