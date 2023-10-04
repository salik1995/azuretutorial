locals {
   appslot_names=["appxabc","appcdb","appxbvc","app098","app3232"]
}
resource "azurerm_service_plan" "website" {
  for_each            =  {for appslot in local.appslot_names: appslot=>appslot}
  name                = each.key
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_resource_group.tutorial.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "ran" {
  for_each            =  {for appslot in local.appslot_names: appslot=>appslot}
  name                = "example-linux-web-app"
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_service_plan.website["appxabc"].location
  service_plan_id     = azurerm_service_plan.website["appxabc"].id

  site_config {}
}

resource "azurerm_linux_web_app_slot" "netwo" {
  name           = "${var.prefix}appslot${var.env}"
  app_service_id = each.value.id

  site_config {}
}
