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
  firewall_policy_id  = azurerm_web_application_firewall_policy.security.id 
  

 waf_configuration {
  enabled                   = true
  firewall_mode             = "Detection"
  rule_set_type             = "Microsoft_BotManagerRuleSet"
  rule_set_version          = 3.2
  disabled_rule_group       = "disabled_rule_group"
  file_upload_limit_mb      = 100
  request_body_check        = true
  max_request_body_size_kb  = 128
 
    exclusion {
    match_variable          = "RequestArgKeys"
    selector_match_operator = "Contains"
    selector                = "match_variable"
  }               
   
   
  disabled_rule_group {
  rule_group_name           = "BadBots"
  rules                     = "rules"
   }
}
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
    firewall_policy_id             = azurerm_web_application_firewall_policy.security.id 
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
