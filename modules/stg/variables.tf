# Define variables for user input
variable "number_of_instances" {
  description = "Number of storage account instances to create"
  type        = number
  #default     = 1
}

variable "account_tiers" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  #default     = ["Standard"]
}

variable "account_kinds" {
  description = "List of account kinds for the storage accounts (e.g., StorageV2, BlobStorage, FileStorage, Storage)"
  type        = list(string)
  #default     = ["StorageV2"]
}

variable "account_replication_types" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  #default     = ["Standard"]
}

variable "access_tiers" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  #default     = ["Standard"]
}



variable "resource_group_name"{}

variable "location"{}



variable "quota"{
  description = "size in GB"
  type = number
}

variable "cust_name" {
  description = "customer name"
}

variable "names" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  
}

variable "types" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)
  
}
