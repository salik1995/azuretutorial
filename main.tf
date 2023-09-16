resource "azurerm_resource_group" "tutorial" {
  name     = "${var.prefix}_resource_group_${var.env}"
  location = "Canada Central"
}

resource "azurerm_storage_account" "awp" {
  name                     = "${var.prefix}storageaccountname${var.env}"
  resource_group_name      = azurerm_resource_group.tutorial.name
  location                 = azurerm_resource_group.tutorial.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
