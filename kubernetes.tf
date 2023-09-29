locals {
   cluster_names=["batch123","batch456","batch678","batch098","batch3232"]
}

resource "azurerm_kubernetes_cluster" "mygroup" {
  for_each            =  {for cluster in local.cluster_names: cluster=>cluster}
  name                = "{$var.prefix}cluster-$(each.key)"
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate_1" {
  value     = [for cluster in azurerm_kubernetes_cluster.mygroup:cluster.kube_config.0.client_certificate]
  sensitive = true
}

output "kube_config_1" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw

  sensitive = true
}
