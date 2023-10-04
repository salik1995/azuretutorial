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
resource "azurerm_lb_backend_address_pool" "tested" {
  loadbalancer_id = azurerm_lb.designed.id
  name            = "BackEndAddressPool"
}
resource "azurerm_lb_probe" "noted" {
  loadbalancer_id = azurerm_lb.designed.id
  name            = "ssh-running-probe"
  port            = 22
}
resource "azurerm_lb_rule" "strong" {
  loadbalancer_id                = azurerm_lb.designed.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"
}
resource "azurerm_lb_nat_pool" "strongest" {
  resource_group_name            = azurerm_resource_group.tutorial.name
  loadbalancer_id                = azurerm_lb.designed.id
  name                           = "SampleApplicationPool"
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 81
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
}
