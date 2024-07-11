variable "location" {
  
}

variable "fs_stg_details" {
  type = map(object({
      id = string
      name = string
   } 

  )
    
  )  
}

variable "rg_name" {

}


variable "all_vm_details" {
  type = any
}

variable "rsv_name"{
  type = any
}
