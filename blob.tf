locals {
   cars_names=["bmw","toyotta","honda","mazda"]
}
resource "azurerm_storage_account" "racing" {
  name                     = "${var.prefix}cluster-${each.key}"
  resource_group_name      = azurerm_resource_group.tutorial.name
  location                 = azurerm_resource_group.tutorial.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "height" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.racing.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "fast" {
  for_each               =  {for cars in local.cars_names: cars=>cars}
  name                   = "my-awesome-content.zip"
  storage_account_name   = azurerm_storage_account.racing.name
  storage_container_name = azurerm_storage_container.height.name
  type                   = "Block"
  source                 = "some-local-file.zip"
}
