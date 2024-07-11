terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.106"   
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}

}


#provider "azurerm" {
#  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
#  feature {}
#}

#DEFINE

module "ex_rs" {
  source = "../modules/ex_rs"
  number_of_instances = var.quant
  vm_instances = var.vm_quant
  names = var.names
  vm_names = var.vm_name
  storage_account_names = var.storage_account_names
  rg_name = var.rg_name
  enable_fetch_vm = var.enable_fetch_vm
  enable_fetch_stg = var.enable_fetch_stg

}

module "rsv" {
  source = "../modules/rcv"
  number_of_instances = var.num_ins
  names = var.name
  skus = var.skus
  cust_name = var.cust_name
  location = var.location
  resource_group_name = var.rg_name
}

module "ex_backups" {
  count = var.enable_bkup == "true" ? 1:0
  source  = "../modules/ex_bkup"
  rg_name = var.rg_name 
  rsv_name = module.rsv.rsv_name
  stg_id = module.ex_rs.stg_id
  existing_fs = module.ex_rs.existing_fs
  existing_vm = module.ex_rs.existing_vm
  bkup_vm    =  var.enable_fetch_vm  
  bkup_fs    =  var.enable_fetch_stg

  depends_on = [ module.rsv ]

}


