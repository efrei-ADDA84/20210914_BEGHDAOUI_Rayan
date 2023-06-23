# Provider Azure
provider "azurerm" {
  features {}
}

# Variables
variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  default     = "765266c6-9a23-4638-af32-dd1e32613047"
}

variable "resource_group_name" {
  description = "Azure Resource Group"
  default     = "ADDA84-CTP"
}

variable "network_name" {
  description = "Azure Virtual Network"
  default     = "network-tp4"
}

variable "subnet_name" {
  description = "Azure Subnet"
  default     = "internal"
}

variable "vm_name" {
  description = "Azure VM Name"
  default     = "devops-20210914"
}

# Generate SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# Save private key to a file
#resource "local_file" "private_key_file" {
#  content  = tls_private_key.ssh_key.private_key_pem
#  filename = "~/.ssh/id_rsa"
#}

# Output private key
output "tls_private_key" {
  value = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "public_key" {
  value = tls_private_key.ssh_key.public_key_openssh
}

# Public IP
resource "azurerm_public_ip" "rayanb" {
  name                = "public-ip-tp4"
  location            = "francecentral"
  resource_group_name = "ADDA84-CTP"
  allocation_method   = "Static"
}

# Network Interface
resource "azurerm_network_interface" "rayanb" {
  name                = "nic-tp4"
  location            = "francecentral"
  resource_group_name = "ADDA84-CTP"

  ip_configuration {
    name                          = "ipconfig-tp4"
    subnet_id                     = "/subscriptions/765266c6-9a23-4638-af32-dd1e32613047/resourceGroups/ADDA84-CTP/providers/Microsoft.Network/virtualNetworks/network-tp4/subnets/internal"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rayanb.id
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "rayanb" {
  name                = var.vm_name
  location            = "francecentral"
  resource_group_name = "ADDA84-CTP"
  size                = "Standard_D2s_v3"
  admin_username      = "devops"
  network_interface_ids = [azurerm_network_interface.rayanb.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

disable_password_authentication = true

admin_ssh_key {
    username       = "devops"
    public_key     = tls_private_key.ssh_key.public_key_openssh

  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}