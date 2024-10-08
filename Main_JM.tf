resource "azurerm_resource_group" "test_RG" {
  name     = var.resource_group_name
  location = var.Azure_location
}

resource "azurerm_virtual_network" "test_VNET" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name
}

resource "azurerm_subnet" "test_SUBNET" {
  for_each             = var.subnet_identification
  name                 = each.key
  resource_group_name  = azurerm_resource_group.test_RG.name
  virtual_network_name = azurerm_virtual_network.test_VNET.name
  address_prefixes     = [each.value]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_network_security_group" "nsg_sub1" {
  name                = "nsg-sub1"
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "Allow-Load-Balancer"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg_sub3" {
  name                = "nsg-sub3"
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name

  security_rule {
    name                       = "Allow-Internal"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Load-Balancer"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

      security_rule {
    name                       = "Allow-SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic_sub1_vm1" {
  name                = "nic-sub1-vm1"
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.test_SUBNET["sub1"].id
    private_ip_address_allocation = "Dynamic"
    
    public_ip_address_id          = azurerm_public_ip.publicIP_vm1.id
  }
}

resource "azurerm_network_interface_security_group_association" "Nic_1_nsg" {
  network_interface_id      = azurerm_network_interface.nic_sub1_vm1.id
  network_security_group_id = azurerm_network_security_group.nsg_sub1.id
}

resource "azurerm_network_interface" "nic_sub1_vm2" {
  name                = "nic-sub1-vm2"
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name

  ip_configuration {
    name                          = "testconfiguration2"
    subnet_id                     = azurerm_subnet.test_SUBNET["sub2"].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "Nic_2_nsg" {
  network_interface_id      = azurerm_network_interface.nic_sub1_vm2.id
  network_security_group_id = azurerm_network_security_group.nsg_sub1.id
}

resource "azurerm_network_interface" "nic_sub3_vm" {
  name                = "nic-sub3-vm"
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name

  ip_configuration {
    name                          = "testconfiguration3"
    subnet_id                     = azurerm_subnet.test_SUBNET["sub3"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicIP_vm3.id
  }
}

resource "azurerm_network_interface_security_group_association" "Nic_3_nsg" {
  network_interface_id      = azurerm_network_interface.nic_sub3_vm.id
  network_security_group_id = azurerm_network_security_group.nsg_sub3.id
}

resource "azurerm_availability_set" "test_availability_set" {
  name                = "test-as"
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name
  managed             = true
}

resource "azurerm_virtual_machine" "vm_sub1_1" {
  name                = "vm-sub1-1"
  resource_group_name = azurerm_resource_group.test_RG.name
  location            = azurerm_resource_group.test_RG.location
  vm_size             = "Standard_DS1_v2"
  network_interface_ids = [
    azurerm_network_interface.nic_sub1_vm1.id,
  ]
  availability_set_id = azurerm_availability_set.test_availability_set.id

  storage_os_disk {
    name          = "osdisk-vm-sub1-1"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = 256
  }

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8_4"
    version   = "latest"
  }

  os_profile {
    computer_name  = "vm-sub1-1"
    admin_username = "Jack_Admin"
    admin_password = "Bears3423!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine" "vm_sub1_2" {
  name                = "vm-sub1-2"
  resource_group_name = azurerm_resource_group.test_RG.name
  location            = azurerm_resource_group.test_RG.location
  vm_size             = "Standard_DS1_v2"
  network_interface_ids = [
    azurerm_network_interface.nic_sub1_vm2.id,
  ]
  availability_set_id = azurerm_availability_set.test_availability_set.id

  storage_os_disk {
    name          = "osdisk-vm-sub-2"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = 256
  }

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8_4"
    version   = "latest"
  }

  os_profile {
    computer_name  = "vm-sub1-2"
    admin_username = "Jack_Admin"
    admin_password = "Bears3423!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine" "vm_sub3" {
  name                = "vm-sub3"
  resource_group_name = azurerm_resource_group.test_RG.name
  location            = azurerm_resource_group.test_RG.location
  vm_size             = "Standard_DS1_v2"
  network_interface_ids = [
    azurerm_network_interface.nic_sub3_vm.id,
  ]
  availability_set_id = azurerm_availability_set.test_availability_set.id

#Unable to get 32gb stroage, complciations with the image. 64 gb was utilized.
  storage_os_disk {
    name          = "osdisk-vm-sub3"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = 64
  }

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8_4"
    version   = "latest"
  }

  os_profile {
    computer_name  = "vm-sub3"
    admin_username = "Jack_Admin"
    admin_password = "Bears3423!"
    custom_data = base64encode(var.apache_install_script)
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  #one of the issues ran into, could not get access to http added and ssh not working
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.publicIP_vm3.ip_address  # Reference the public IP
      user        = "Jack_Admin"
      password    = "Bears3423!"  # Use SSH keys in production for better security
    }

    inline = [
      "sudo firewall-cmd --permanent --zone=public --add-service=http",
      "sudo firewall-cmd --reload",
    ]
  }
}

resource "azurerm_public_ip" "publicIP_vm1" {
  name                = "public-ip-vm1"
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name
  sku                 = "Standard"
  allocation_method   = "Static"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "publicIP_vm3" {
  name                = "public-ip-vm3"
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name
  sku                 = "Standard"
  allocation_method   = "Static"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "publicIP_test" {
  name                = "test-public-ip"
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name
  sku                 = "Standard"
  allocation_method   = "Static"    
  ip_version          = "IPv4"
}

resource "azurerm_lb" "LB_test" {
  name                = "test_LB"
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.publicIP_test.id
  }  
}

resource "azurerm_lb_backend_address_pool" "test_lb_backend_pool" {
  loadbalancer_id = azurerm_lb.LB_test.id
  name            = "test-backend-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_sub3_lb" {
  network_interface_id      = azurerm_network_interface.nic_sub3_vm.id
  ip_configuration_name     = "testconfiguration3"
  backend_address_pool_id   = azurerm_lb_backend_address_pool.test_lb_backend_pool.id
}

resource "azurerm_lb_probe" "test_lb_Probe" {
  loadbalancer_id     = azurerm_lb.LB_test.id
  name                = "http-probe"
  port                = 80
  protocol            = "Http"
  request_path        = "/"
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_probe" "ssh_probe" {
  loadbalancer_id     = azurerm_lb.LB_test.id
  name                = "ssh-probe"
  port                = 22
  protocol            = "Tcp"
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "ssh_lb_rule" {
  loadbalancer_id                     = azurerm_lb.LB_test.id
  name                                = "test-rule"
  protocol                            = "Tcp"
  frontend_port                        = 22
  backend_port                         = 22
  frontend_ip_configuration_name       = "frontend-ip"
  probe_id                            = azurerm_lb_probe.ssh_probe.id
  backend_address_pool_ids            = [azurerm_lb_backend_address_pool.test_lb_backend_pool.id]
}

resource "azurerm_lb_rule" "http_lb_rule" {
  loadbalancer_id                     = azurerm_lb.LB_test.id
  name                                = "http-rule"
  protocol                            = "Tcp"
  frontend_port                        = 80
  backend_port                         = 80
  frontend_ip_configuration_name       = "frontend-ip"
  probe_id                            = azurerm_lb_probe.test_lb_Probe.id
  backend_address_pool_ids            = [azurerm_lb_backend_address_pool.test_lb_backend_pool.id]
}

resource "azurerm_storage_account" "test_storage_acct" {
  name                     = var.storageAcct
  resource_group_name      = azurerm_resource_group.test_RG.name
  location                 = azurerm_resource_group.test_RG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = []
    virtual_network_subnet_ids = [
      azurerm_subnet.test_SUBNET["sub1"].id,
      azurerm_subnet.test_SUBNET["sub2"].id,
      azurerm_subnet.test_SUBNET["sub3"].id,
      azurerm_subnet.test_SUBNET["sub4"].id
    ]
  }
}

output "load_balancer_ip" {
  value = azurerm_public_ip.publicIP_test.ip_address
}

output "vm1_public_ip" {
  value = azurerm_public_ip.publicIP_vm1.ip_address
}

output "vm3_public_ip" {
  value = azurerm_public_ip.publicIP_vm3.ip_address
}
