output "app_gateway_public_ip" {
  value = azurerm_public_ip.agw_pip.ip_address
}
