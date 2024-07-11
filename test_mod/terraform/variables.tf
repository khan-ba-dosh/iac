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


variable "vms"{
 type = list(object({
    name               = string
    size               = string
    admin_username     = string
    admin_password     = string
    os_disk_image_urn  = string
  }))
 default = [
  {
    name              = "prd-vm"
    size              = "Standard_F2"
    admin_username    = "azureuser"
    admin_password    = "P@ssw0rd1234!"
    os_disk_image_urn = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"
  },
  {
    name              = "dev-vm"
    size              = "Standard_F2"
    admin_username    = "azureuser"
    admin_password    = "P@ssw0rd1234!"
    os_disk_image_urn = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"
  }
]

}



# Define variables for user input
variable "number_of_instances" {
  description = "Number of storage account instances to create"
  type        = number
  default     = 1
}

variable "num_ins" {
  description = "Number of storage account instances to create"
  type        = number
  default     = 1
}

variable "quant" {
  description = "Number of storage account instances to create"
  type        = number
  default     = 1
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
  default     = ["fs1"]
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

#variable "rg_name" {
 # default = "rg-macs-001"
#}

variable "stg_name" {
 type = list(string) 
 default = ["saprdmb001"]
}

variable "vm_names" {
 type = list(string)
 default = ["prod-vm"]
}

