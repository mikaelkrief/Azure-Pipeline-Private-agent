
/*******************************************/
/************ Provider *********************/
/******************************************/

provider "azurerm" {
  subscription_id = "<your subscription id>"
  client_id       = "<your client id>"
  client_secret   = "<your client secret>"
  tenant_id       = "<your tenant id>"
}

/************************************************/
/************ Declaration of variables **********/
/************************************************/

variable "resource_group" {
  description = "The name of the resource group in which to create the virtual network."
  default = "rg-vsts-agent-linux"
}

variable "project_name" {
  description = "The shortened abbreviation to represent your project name."
  default     = "vsts-agent-linux"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default = "North Europe"
}

variable "admin_username" {
  description = "administrator user name"
  default     = "username"
}

variable "admin_password" {
  description = "vmpassword"
  default     = "passwordlinux"
}

variable "admin_sshkey" {
  description = "vmpassword"
}

/************************************************/
/************ Resources Azure *********************/
/************************************************/


resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}vnet"
  location            = "${var.location}"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = "${var.resource_group}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.project_name}subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${var.resource_group}"
  address_prefix       = "10.0.10.0/24"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.project_name}nic"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  ip_configuration {
    name                          = "${var.project_name}ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }
}

resource "azurerm_public_ip" "pip" {
  name                         = "${var.project_name}-ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group}"
  public_ip_address_allocation = "Dynamic"
  domain_name_label            = "vsts-agent-linux"
}


resource "azurerm_managed_disk" "datadisk" {
  name                 = "${var.project_name}-datadisk"
  location             = "${var.location}"
  resource_group_name  = "${var.resource_group}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}


# we assume that this Custom Image already exists
data "azurerm_image" "custom" {
  name                = "vsts-agent-linux"
  resource_group_name = "${var.resource_group}"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.project_name}vm"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group}"
  vm_size               = "Standard_DS2_v2"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]

  storage_image_reference {
      id = "${data.azurerm_image.custom.id}"
  }

  storage_os_disk {
    name              = "${var.project_name}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  storage_data_disk {
    name              = "${var.project_name}-datadisk"
    managed_disk_id   = "${azurerm_managed_disk.datadisk.id}"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "1023"
    create_option     = "Attach"
    lun               = 0
  }

  os_profile {
    computer_name  = "vsts-image-linux"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys = {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${var.admin_sshkey}"
    }
  }
}
