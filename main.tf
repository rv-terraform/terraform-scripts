
# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myInfrastructure"
    location = "${var.access_location}"

    tags {
        environment = "Development"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.access_location}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    tags {
        environment = "Development"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "${var.access_location}"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Development"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "${var.access_location}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "80"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

 
    tags {
        environment = "Development"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = "${var.access_location}"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }

    tags {
        environment = "Development"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "mylinuxGUI"
    location              = "${var.access_location}"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "Standard_D1_V2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "7.4"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "${var.admin_user}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/venerari/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPj8ZTnznnsJ7PfLckx8Xp6UMm9tr1Mj8KV6/Ki0S0aJ9dZOT+ayAfZDYf88m+RnaUnYiEu1cDl3vuM1Yr8PR/hwnzuPRIFvserxoJZTwxgy5XvvQMRlVxgV3LBINmD5L/PPuVvqpdZLWzhbWENQjar4IG+JdvnZdP2ncYocVQglSmKQXaz/Xz/xdaaTsYAuHeeuXlqoLWDWb0pPTAmau7I/G+urORs6lkH+dwvfZe7NuMNjFBnbvOB38XhaqbF5/y0EVgiy1IbXXX96wcZzXMbUpmojWExySfV1ZOJzzKQiLM51m7DWdra89bjnORUGDMCKBxoqOjImiTDWxk+FnJ venerari@sdcgigdcapmdw01"
        }
    }

    tags {
        environment = "Development"
    }
}

resource "azurerm_virtual_machine_extension" "scripts" {
  name                 = "myvm"
  location             = "${var.access_location}"
  resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
  virtual_machine_name = "${azurerm_virtual_machine.myterraformvm.name}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
    {
        "commandToExecute": "curl -o  /etc/yum.repos.d/centos.repo https://raw.githubusercontent.com/tso-ansible/ansible-tower/master/centos.repo"
    }
SETTINGS

  tags {
    environment = "Development"
  }
}

resource "azurerm_virtual_machine_extension" "scripts2" {
  name                 = "myvm"
  location             = "${var.access_location}"
  resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
  virtual_machine_name = "${azurerm_virtual_machine.myterraformvm.name}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
    {
        "commandToExecute": "yum install epel-release -y"
    }
SETTINGS

  tags {
    environment = "Development"
  }
}

resource "azurerm_virtual_machine_extension" "scripts3" {
  name                 = "myvm"
  location             = "${var.access_location}"
  resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
  virtual_machine_name = "${azurerm_virtual_machine.myterraformvm.name}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
    {
        "commandToExecute": "yum update -y"
    }
SETTINGS

  tags {
    environment = "Development"
  }
}

resource "azurerm_virtual_machine_extension" "scripts4" {
  name                 = "myvm"
  location             = "${var.access_location}"
  resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
  virtual_machine_name = "${azurerm_virtual_machine.myterraformvm.name}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
    {
        "commandToExecute": "yum install httpd -y"
    }
SETTINGS

  tags {
    environment = "Development"
  }
}

resource "azurerm_virtual_machine_extension" "scripts5" {
  name                 = "myvm"
  location             = "${var.access_location}"
  resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
  virtual_machine_name = "${azurerm_virtual_machine.myterraformvm.name}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
    {
        "commandToExecute": "firewall-cmd --permanent --add-port=80/tcp"
    }
SETTINGS

  tags {
    environment = "Development"
  }
}
