resource "azurerm_service_plan" "casting" {
  for_each            ={for app in local.linux_app_list: "${app.name}"=>app }
  name                = each.value.name
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_resource_group.tutorial.location
  sku_name            = each.value.sku_name
  os_type             = each.value.os_type
}

resource "azurerm_windows_web_app" "diet" {
  for_each            = azurerm_service_plan.casting
  name                = each.value.name
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_service_plan.casting[each.key].location
  service_plan_id     = azurerm_service_plan.casting[each.key].id

  site_config {}
}
