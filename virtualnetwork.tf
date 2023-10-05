locals {
  virtuall_network=["network1","network2","network3","network4","network5"]
}
resource "azurerm_network_security_group" "threat" {
  name                = "example-security-group"
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name
}

resource "azurerm_virtual_network" "side" {
  for_each              =  {for virtuall in local.virtuall_network: virtuall=>virtuall}
  name                = "example-network"
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.side.id
  }

  tags = {
    environment = "Production"
  }
}
