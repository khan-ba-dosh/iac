variable "number_of_instances" {
  description = "Number of storage account instances to create"
  type        = number
  #default     = 1
}


variable "resource_group_name"{}

variable "location"{}

variable "skus"{
  description = "size in GB"
  type = list(string)
}

variable "cust_name" {
  description = "customer name"
}

variable "names" {
  description = "List of account tiers for the storage accounts (e.g., Standard, Premium)"
  type        = list(string)

}
