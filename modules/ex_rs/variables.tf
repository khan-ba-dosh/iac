# Define variables for user input
variable "number_of_instances" {
  description = "Number of storage account instances to create"
  type        = number
  #default     = 1
}

variable "vm_instances" {
  description = "Number of storage account instances to create"
  type        = number
  #default     = 1
}


variable "rg_name"{}

variable "names" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  #default     = ["Standard"]
}
variable "vm_names" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  #default     = ["Standard"]
}


variable "storage_account_names" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  #type        = list(string)
  #default     = ["Standard"]
}

variable "enable_fetch_stg" {

}

variable "enable_fetch_vm" {

}

