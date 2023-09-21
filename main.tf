resource "azurerm_resource_group" "tutorial" {
  name     = "${var.prefix}_resource_group_${var.env}"
  location = "Canada Central"
}

resource "azurerm_storage_account" "awp" {
  name                     = "${var.prefix}storage${var.env}"
  resource_group_name      = azurerm_resource_group.tutorial.name
  location                 = azurerm_resource_group.tutorial.location
  account_tier             = var.storage
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }



resource "azurerm_storage_blob" "tutoral" "awp" {
  name                     = "${var.prefix}storage${var.env}"
  storage_account_name   = azurerm_storage_account.batch06.name
  storage_container_name = azurerm_storage_container.batch06.name
  type                   = "Block"
  source                 = "some-local-file.zip"
}
 }
