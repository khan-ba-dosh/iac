variable "location" {
  description = "The Azure region to deploy resources"
  type        = string
  #default     = "East US"
}

variable "rg_name" {
  description = "The name of the resource group"
  type        = string
  #default     = "myResourceGroup"
}

variable "instances" {
  description = "List of instances to create"
  type = list(object({
    name               = string
    size               = string
    admin_username     = string
    admin_password     = string
    os_disk_image_urn  = string
  }))

}

variable "subnet_id" {
  
}
