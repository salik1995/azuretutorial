locals {
   student_names = ["hashim","thomas","salik"]
  }
  
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
  container_access_type = var.no_hardcoded
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
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"

  tags = {
    environment = "production"
  }
}
resource "azurerm_kubernetes_cluster" "firstclass" {
  name                = "${var.prefix}storage${var.env}"
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name
  dns_prefix          = var.exampleaks1

  default_node_pool {
    name       = "${var.prefix}${var.env}"
    node_count = var.numeric
    vm_size    = var.Standard_D2_v2
  }

  identity {
    type = var.system
  }

  tags = {
    Environment = var.env
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.firstclass.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.firstclass.kube_config_raw

  sensitive = true
}



resource "azurerm_postgresql_server" "testing" {
  name                = "postgresql-server-1"
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name

  sku_name = "B_Gen5_2"


  administrator_login          = "psqladminun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "deployment" {
  name                = "exampledb"
  resource_group_name = azurerm_resource_group.tutorial.name
  server_name         = azurerm_postgresql_server.testing.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_availability_set" "batcha06" {
  name                = "acceptanceTestAvailabilitySet1"
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name

  tags = {
    environment = "Production"
  }
}
resource "azurerm_container_group" "storage" {
  name                = "example-continst"
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name
  ip_address_type     = "None"
  dns_name_label      = "aci-label"
  os_type             = "Linux"

  container {
    name   = "hello-world"
    image  = "microsoft/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 443
      protocol = "TCP"
    }
  }

  container {
    name   = "sidecar"
    image  = "microsoft/aci-tutorial-sidecar"
    cpu    = "0.5"
    memory = "1.5"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_kubernetes_cluster" "sparx" {
  name                = "example-aks1"
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  service_principal {
    client_id     = "00000000-0000-0000-0000-000000000000"
    client_secret = "00000000000000000000000000000000"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "joined" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.sparx.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
}

resource "azurerm_data_factory" "firewall" {
  name                = "example"
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name
}

resource "azurerm_data_factory" "waterfall" {
  name                = "example"
  location            = azurerm_resource_group.tutorial.location
  resource_group_name = azurerm_resource_group.tutorial.name
}

resource "azurerm_data_factory_linked_service_mysql" "bubblefall" {
  name              = "example"
  data_factory_id   = azurerm_data_factory.waterfall.id
  connection_string = "Server=test;Port=3306;Database=test;User=test;SSLMode=1;UseSystemTrustStore=0;Password=test"
}

resource "azurerm_data_factory_dataset_mysql" "bubblegum" {
  name                = "example"
  data_factory_id     = azurerm_data_factory.waterfall.id
  linked_service_name = azurerm_data_factory_linked_service_mysql.bubblefall.name
}

resource "azurerm_public_ip" "public" {
  name                = "PublicIPForLB"
  location            = "Canada Central"
  resource_group_name = azurerm_resource_group.tutorial.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "private" {
  name                = "TestLoadBalancer"
  location            = "Canada Central"
  resource_group_name = azurerm_resource_group.tutorial.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public.id
  }
}

  

