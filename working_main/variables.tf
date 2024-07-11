#subscription_details
#azure_resource_location
variable "location" {
  description = "resource group location"
  type        = any
  default     = "eastus2"
}
#provide client_name in 3-5 char
variable "cust_name" {
  description = "customer name"
  default     = "rancho"
  type        = any
}

# Define variables for user input
variable "number_of_instances" {
  description = "Number of storage account instances to create"
  type        = number
  default     = 1
}

variable "num_ins" {
  description = "Number of rcv instances to create"
  type        = number
  default     = 1
}

variable "account_tiers" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  default     = ["Premium"]
}

variable "account_kinds" {
  description = "List of account kinds for the storage accounts (e.g., StorageV2, BlobStorage, FileStorage, Storage)"
  type        = list(string)
  default     = ["FileStorage"]
}

variable "account_replication_types" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  default     = ["LRS"]
}

variable "access_tiers" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  default     = ["Cool", "Hot"]
}

variable "names" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  default     = ["mb"]
}

variable "name" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  default     = ["Vault"]
}
variable "types" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  default     = ["fs2"]
}

variable "skus" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  default     = ["Standard"]
}

variable "quota"{
  description = "size in GB"
  type = number
  default = 100
}
#########################

variable "enable_bkup" {
  default = "true"
}


variable "vm_names" {
  type = list(string)
  default = ["prod-vm"]
 }
 
 variable "vms"{
  type = map(object({
     name               = string
     size               = string
     admin_username     = string
     admin_password     = string
     os_disk_image_urn  = string
   }))
  default = {
   
  0 = {
  	
  name              = "dev-vm"
  size              = "Standard_B1s"
  admin_username    = "azureuser"
  admin_password    = "P@ssw0rd1234!"
  os_disk_image_urn = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"
  
 },

 1  = {
   name              = "prd-vm"
  size              = "Standard_B1s"
  admin_username    = "azureuser"
  admin_password    = "P@ssw0rd1234!"
  os_disk_image_urn = "MicrosoftWindowsServer:WindowsServer:2016-Datacenter:latest"
   
  }
  
 }
}

variable lin_vms{
  default = ["vm1"]
}
variable win_vms{
  default = ["vm2"]
}

variable "asg_names" {
 default = {
    asg1 = "rancho-asg1"
    asg2 = "rancho-asg2"
  }
}

variable "vm_asg_map" {
  default = [0, 1]
}


variable "asg" {
  default = [0, 1]
}

variable "launch_lin" {
  default = "true"
}
variable "launch_win" {
  default = "true"
}



