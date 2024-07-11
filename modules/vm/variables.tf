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
  type = map(object({
    name               = string
    size               = string
    admin_username     = string
    admin_password     = string
    os_disk_image_urn  = string
  }))

}

variable "subnet_id" {

}

variable "lin_instances" {
  type = list(string)

}

variable "win_instances" {
  type = list(string)

}

variable "asg_id" {
  #type = list(string)
}

/*
variable "asg_id" {
  #type = list(string)
}

variable "asg" {
 #type = list(number)
}

variable "vm-asg" {
  type = list(string)
}
*/

variable "vm_asg_map" {
  

}

variable "launch_win" {
 #type = boolean
}
variable "launch_lin" {
 #type = boolean
}

/*
variable "key_vault_uri" {

}
variable "key_vault" {

}
variable "key_vault_key" {

}
*/
