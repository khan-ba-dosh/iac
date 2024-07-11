
variable "rg_name" {
  
}


variable "location" {
  
}

variable "all_vm_details" {
  type = any
}

variable "rsv_name"{
  type = any
}

/*
variable "all_vm_details" {
  type = map(object({
      id = string
     # name = string
   } 

  )
    
  )  
}


variable "ins_vm_details" {
  type = map(object({
      id = string
     # name = string
   } 

  )
    
  )  
}

variable "rsv_name" {
  type = map(object({
      name = string
   }

  )

  )
}

*/

