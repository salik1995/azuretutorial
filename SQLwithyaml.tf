locals{
  sql_server=[for f in fileset("${path.module}/configs", "[^_]*.yaml") : yamldecode(file("${path.module}/configs/${f}"))]
  sql_server_list = flatten([
  for app in local.sql_server : [
    for linuxapps in try(app.listofsqlserver, []) :{
      name=linuxapps.name
      version=linuxapps.version
      }
    ]
])
}

resource "azurerm_sql_server" "networking" {
  for_each                     ={for sp in local.sql_server_list: "${sp.name}"=>sp }
  name                         = "sqlserver"
  resource_group_name          = azurerm_resource_group.tutorial.name
  location                     = azurerm_resource_group.tutorial.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"

  tags = {
    environment = "production"
  }
}
