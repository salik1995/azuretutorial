resource "azurerm_public_ip" "addressed" {
  name                = "PublicIPForLB"
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "designed" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.addressed.id
  }
}
