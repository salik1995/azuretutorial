locals {
   virtual_names=["azure","AWS","GCP","Mirco","Mircotech"]
}
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.tutorial.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  for_each              =  {for virtual in local.virtual_names: virtual=>virtual}
  name                  = "${var.prefix}virtual-$(each.key)"
  location              = azurerm_resource_group.tutorial.location
  resource_group_name   = azurerm_resource_group.tutorial.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"
}
