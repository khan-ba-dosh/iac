#RISHABH####################################################################################################

#subscription_details

#azure_resource_location
variable "location" {
  description = "resource group location"
  type        = any
  default     = "eastus"
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
  description = "Number of recovery vault instances to create"
  type        = number
  default     = 1
}

variable "quant" {
  description = "Number of exisiting file storage "
  type        = number
  default     = 1
}

variable "vm_quant" {
  description = "Number of existing vms"
  type        = number
  default     = 1
}



variable "storage_account_names" {
  description = "Name of existing stg acc"
  
  default     = "sarancho1"
}

variable "name" {
  description = "Name of recovery vault"
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

variable "rg_name" {
  description = "name of existing rg"
  default = "rg-rancho-001"
}

variable "enable_fetch_stg" {
  #type = "boolean"
  default = "true"
}
variable "enable_fetch_vm" {
  #type = "boolean"
  default = "true"
}

variable "names" {
 default = ["fs1"]
}

variable "vm_name" {
 default = ["dev"]
}

