resource "azurerm_application_gateway" "appgw" {
  name                = "appgw"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.agw_subnet.id
  }

  frontend_port {
    name = "frontend-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.agw_pip.id
  }

  backend_address_pool {
    name = "backend-pool"

    ip_addresses = [
      azurerm_windows_virtual_machine.vm1.private_ip_address,
      azurerm_windows_virtual_machine.vm2.private_ip_address
    ]
  }

  probe {
    name                = "default-probe"
    protocol            = "Http"
    path                = "/index.html"
    interval            = 30
    timeout             = 60                
    unhealthy_threshold = 3
    host                = "localhost"        

    match {
      status_code = ["200", "301", "302", "304"]
    }
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60                
    probe_name            = "default-probe"
    host_name             = "localhost"       
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 100
  }

  depends_on = [
    azurerm_windows_virtual_machine.vm1,
    azurerm_windows_virtual_machine.vm2
  ]
}
