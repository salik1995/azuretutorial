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
  backend_address_pool_name      = "${azurerm_virtual_network.example.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.trainning.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.trainning.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.example.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.example.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.example.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.example.name}-rdrcfg"
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
  }
  }
  }

