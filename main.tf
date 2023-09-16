resource "azurerm_resource_group" "tutorial" {
  name     = "${var.prefix}_resource_group"
  location = "Canada Central"
}
