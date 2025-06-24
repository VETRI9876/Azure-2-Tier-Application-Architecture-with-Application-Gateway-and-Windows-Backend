# Network Interface 1
resource "azurerm_network_interface" "nic1" {
  name                = "nic1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.backend_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
  }
}

# Network Interface 2
resource "azurerm_network_interface" "nic2" {
  name                = "nic2"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.backend_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.5"
  }
}

# NSG associations
resource "azurerm_network_interface_security_group_association" "nic1_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.backend_nsg.id
}

resource "azurerm_network_interface_security_group_association" "nic2_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.backend_nsg.id
}

# VM1
resource "azurerm_windows_virtual_machine" "vm1" {
  name                  = "vm1"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic1.id]
  size                  = "Standard_B1s"
  admin_username        = var.admin_username
  admin_password        = var.admin_password

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

# VM2
resource "azurerm_windows_virtual_machine" "vm2" {
  name                  = "vm2"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic2.id]
  size                  = "Standard_B1s"
  admin_username        = var.admin_username
  admin_password        = var.admin_password

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

# Script Extension for VM1 (IIS + Sleep)
resource "azurerm_virtual_machine_extension" "vm1_script" {
  name                 = "install-iis-vm1"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
{
  "commandToExecute": "powershell -Command \"Install-WindowsFeature -Name Web-Server; Start-Sleep -Seconds 300; echo 'Hello from VM1' > C:\\inetpub\\wwwroot\\index.html\""
}
SETTINGS
}

# Script Extension for VM2 (IIS + Sleep)
resource "azurerm_virtual_machine_extension" "vm2_script" {
  name                 = "install-iis-vm2"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm2.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
{
  "commandToExecute": "powershell -Command \"Install-WindowsFeature -Name Web-Server; Start-Sleep -Seconds 300; echo 'Hello from VM2' > C:\\inetpub\\wwwroot\\index.html\""
}
SETTINGS
}
