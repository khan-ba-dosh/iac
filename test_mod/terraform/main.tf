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

# Create a resource group
resource "azurerm_resource_group" "arcgis" {
  name     = "rg-${var.cust_name}-001"
  location = var.location
}

resource "azurerm_virtual_network" "macs-vnet" {
  name                = "${var.cust_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.arcgis.name
}

resource "azurerm_subnet" "macs-snet" {
  name                 = "${var.cust_name}-subnet"
  resource_group_name  = azurerm_resource_group.arcgis.name
  virtual_network_name = azurerm_virtual_network.macs-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#provider "azurerm" {
#  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
#  feature {}
#}

module "vm" {
  source = "../modules/vm"
  instances = var.vms
  #storage_account_names = var.stg_name
  #cust_name = var.cust_name
  location = var.location
  rg_name = azurerm_resource_group.arcgis.name
  subnet_id = azurerm_subnet.macs-snet.id
}

module "rsv" {
  source = "../modules/rcv"
  number_of_instances = var.num_ins
  names = var.name
  skus = var.skus
  cust_name = var.cust_name
  location = var.location
  resource_group_name =  azurerm_resource_group.arcgis.name
}

module "backups" {
  count = var.enable_bkup == "true" ? 1:0
  source  = "../modules/vm_bkup"
  rg_name = azurerm_resource_group.arcgis.name 
  location = var.location
  rsv_name = module.rsv.rsv_name
  all_vm_details = module.vm.all_vm
  #ins_vm_details = module.vm.ins_vm_details
  #stg_ids = module.storage_accounts.stg_ids
 
 #depends_on = [module.rsv]

}


# Define
/*
# Create a resource group
resource "azurerm_resource_group" "arcgis" {
  name     = "rg-${var.cust_name}-002"
  location = var.location
}

module "storage_accounts" {
  source  = "../modules/stg"
  resource_group_name = azurerm_resource_group.arcgis.name
  cust_name = var.cust_name
  names = var.names
  types = var.types
  location = var.location
  number_of_instances = var.number_of_instances
  account_tiers = var.account_tiers
  account_kinds = var.account_kinds
  account_replication_types = var.account_replication_types
  access_tiers = var.access_tiers
  quota = var.quota
 }



module "ex_rs" {
  source = "../modules/ex_rs"
  number_of_instances = var.quant
  names = var.vm_names
  #storage_account_names = var.stg_name
  #cust_name = var.cust_name
  #location = var.location
  rg_name = var.rg_name
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

module "backups" {
  count = var.enable_bkup == "true" ? 1:0
  source  = "../modules/ex_bkup"
  rg_name = var.rg_name 
  #location = var.location
  rsv_name = module.rsv.rsv_name
  existing_details = module.ex_rs.existing_details
  #stg_ids = module.storage_accounts.stg_ids
 
 depends_on = [module.rsv]

}

*/
