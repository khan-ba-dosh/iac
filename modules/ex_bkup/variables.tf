
variable "rg_name" {
  
}

variable "existing_vm" {
 type = list(string)

}

variable "existing_fs" {
 type = list(string)

}


variable "rsv_name" {
  type = any
}

variable "stg_id" {
 type = list(string) 
}

variable "bkup_fs" {

}

variable "bkup_vm" {

}

