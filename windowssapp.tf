locals{
  windows_app=[for f in fileset("${path.module}/configs", "[^_]*.yaml") : yamldecode(file("${path.module}/configs/${f}"))]
  windows_app_list = flatten([
    for app in local.windows_app : [
      for windowsapps in try(app.listofwindowsapp, []) :{
        name=windowsapps.name
        os_type=windowsapps.os_type
        sku_name=windowsapps.sku_name     
      }
    ]
])

}
resource "azurerm_service_plan" "netwrokz" {
  for_each            ={for app in local.windows_app_list: "${app.name}"=>app }
  name                = each.value.name
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_resource_group.tutorial.location
}

resource "azurerm_windows_web_app" "storagez" {
  for_each            = azurerm_service_plan.netwrokz
  name                = each.value.name
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_service_plan.netwrokz[each.key].location
  service_plan_id     = azurerm_service_plan.netwrokz[each.key].id

  site_config {}
}
