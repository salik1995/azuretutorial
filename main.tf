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
resource "azurerm_web_application_firewall_policy" "security" {
  name                = "${var.prefix}storage${var.env}"
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_resource_group.tutorial.location

  custom_rules {
    name      = "Rule1"
    priority  = 1
    rule_type = "MatchRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }

      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
    }

    action = "Block"
  }

  custom_rules {
    name      = "Rule2"
    priority  = 2
    rule_type = "MatchRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }

      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["192.168.1.0/24"]
    }

    match_conditions {
      match_variables {
        variable_name = "RequestHeaders"
        selector      = "UserAgent"
      }

      operator           = "Contains"
      negation_condition = false
      match_values       = ["Windows"]
    }

    action = "Block"
  }

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    exclusion {
      match_variable          = "RequestHeaderNames"
      selector                = "x-company-secret-header"
      selector_match_operator = "Equals"
    }
    exclusion {
      match_variable          = "RequestCookieNames"
      selector                = "too-tasty"
      selector_match_operator = "EndsWith"
    }

    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
      rule_group_override {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
        rule {
          id      = "920300"
          enabled = true
          action  = "Log"
        }

        rule {
          id      = "920440"
          enabled = true
          action  = "Block"
        }
      }
    }
  }
}
resource "azurerm_virtual_network" "trainning" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_resource_group.tutorial.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.tutorial.name
  virtual_network_name = azurerm_virtual_network.trainning.name
  address_prefixes     = ["10.254.0.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "backend"
  resource_group_name  = azurerm_resource_group.tutorial.name
  virtual_network_name = azurerm_virtual_network.trainning.name
  address_prefixes     = ["10.254.2.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_resource_group.tutorial.location
  allocation_method   = "Dynamic"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.trainning.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.trainning.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.trainning.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.trainning.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.trainning.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.trainning.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.trainning.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "example-appgateway"
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_resource_group.tutorial.location

   sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
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
  location            = "${azurerm_resource_group.tutorial.location}"
  resource_group_name = "${azurerm_resource_group.tutorial.name}"

  tags = {
    environment = "Production"
  }
}
resource "azurerm_container_group" "storage" {
  name                = "example-continst"
  location            = "${azurerm_resource_group.tutorial.location}"
  resource_group_name = "${azurerm_resource_group.tutorial.name}"
  ip_address_type     = "none"
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
  location            = "${azurerm_resource_group.tutorial.location}"
  resource_group_name = "${azurerm_resource_group.tutorial.name}"
}

resource "azurerm_data_factory_linked_service_mysql" "waterfall" {
  name                = "example"
  resource_group_name = "${azurerm_resource_group.tutorial.name}"
  data_factory_name   = "${azurerm_data_factory.firewall.name}"
  connection_string   = "Server=test;Port=3306;Database=test;User=test;SSLMode=1;UseSystemTrustStore=0;Password=test"
}

resource "azurerm_data_factory_dataset_mysql" "bubbleball" {
  name                = "example"
  resource_group_name = "${azurerm_resource_group.tutorial.name}"
  data_factory_name   = "${azurerm_data_factory.firewall.name}"
  linked_service_name = "${azurerm_data_factory_linked_service_mysql.waterfall.name}"
}

  

