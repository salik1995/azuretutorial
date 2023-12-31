locals {
   linux_names=["linuxabc","linuscdb","linuxbvc","linux098","linux3232"]
}
resource "azurerm_service_plan" "icecream" {
  for_each            =  {for linux in local.linux_names: linux=>linux}
  name                = each.key
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_resource_group.tutorial.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "pops" {
  for_each            =  {for linux in local.linux_names: linux=>linux}
  name                = "example"
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_service_plan.icecream["linuxabc"].location
  service_plan_id     = azurerm_service_plan.icecream["linuxabc"].id

  site_config {}
}
