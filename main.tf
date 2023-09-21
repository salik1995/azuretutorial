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
}
resource "azurerm_storage_container" "security" {
  name                     = "${var.prefix}storage${var.env}"
  storage_account_name  = azurerm_storage_account.awp.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "tutoral" {
  name                     = "${var.prefix}storage${var.env}"
  storage_account_name   = azurerm_storage_account.awp.name
  storage_container_name = azurerm_storage_container.security.name
  type                   = "Block"
  source                 = "some-local-file.zip"
}

resource "azurerm_sql_server" "trial" {
  name                     = "${var.prefix}storage${var.env}"
  resource_group_name          = azurerm_resource_group.tutorial.name
  location                     = azurerm_resource_group.tutorial.location
  version                      = "4.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"

  tags = {
    environment = "production"
  }
 }
