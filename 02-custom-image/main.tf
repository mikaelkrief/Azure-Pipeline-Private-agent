/************************************************/
/************ Provider *********************/
/************************************************/

provider "azurerm" {
  subscription_id = "<your subscription id>"
  client_id       = "<your client id>"
  client_secret   = "<your client secret>"
  tenant_id       = "<your tenant id>"
}

/************************************************/
/************ Declaration of variables *********************/
/************************************************/

variable "resource_group" {
  description = "The name of the resource group in which to create the virtual network."
  default = "rg-vsts-agent-linux"
}
  
variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default = "North Europe"
}


resource "azurerm_image" "vsts-linux" {
  name = "vsts-agent-linux"
  location = "${var.location}"
  resource_group_name = "${var.resource_group}"

  os_disk {
    os_type = "Linux"
    os_state = "Generalized"
    blob_uri = "https://${var.storageaccountname}.blob.core.windows.net/system/Microsoft.Compute/Images/images/${var.paker_vhd_name}.vhd"
    size_gb = 128
  }
}
