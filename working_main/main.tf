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

# Define

# Create a resource group
  resource "azurerm_resource_group" "arcgis" {
  name     = "rg-${var.cust_name}-001"
  location = var.location
}
/*
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
*/

resource "azurerm_virtual_network" "macs-vnet" {
  name                = "${var.cust_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.arcgis.name
  
  depends_on = [azurerm_resource_group.arcgis]
}

resource "azurerm_subnet" "macs-snet" {
  name                 = "${var.cust_name}-subnet"
  resource_group_name  = azurerm_resource_group.arcgis.name
  virtual_network_name = azurerm_virtual_network.macs-vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [azurerm_virtual_network.macs-vnet]
}
#############################################################
/*

resource "random_id" "account_name_unique" {
  byte_length = 8
}
################## key Vault ######################
data "azurerm_client_config" "current" {}
#key_vault#
resource "azurerm_key_vault" "arcgis" {
  name                            = "kv-${var.cust_name}-${lower(random_id.account_name_unique.hex)}"
  location                        = azurerm_resource_group.arcgis.location
  resource_group_name             = azurerm_resource_group.arcgis.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  #soft_delete_enabled         = false
  purge_protection_enabled = false
  sku_name                 = "standard"
  #soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey",
      "GetRotationPolicy",
      "SetRotationPolicy",
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set",
    ]
  }
  #depends_on = [
  #  azurerm_virtual_network.arcgis
  #]

}
#key_vault_secret#
resource "azurerm_key_vault_secret" "arcgis" {
  name         = "operateadmin"
  value        = "P@$$w0rd1234!"
  key_vault_id = azurerm_key_vault.arcgis.id
}

########################disk_encryption_key#################
#key_vault_key#
resource "azurerm_key_vault_key" "arcgis" {
  name         = "des-arcgis-key"
  key_vault_id = azurerm_key_vault.arcgis.id
  key_type     = "RSA"
  key_size     = 2048

  #depends_on = [
  #  azurerm_key_vault_access_policy.myPolicy
  #]

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}



#############################################################

*/

module "asg"{

  source = "../modules/asg"
  asg_name = var.asg_names
  location = var.location
  rg_name = azurerm_resource_group.arcgis.name
  
}


module "vm" {
  source = "../modules/vm"
  instances = var.vms
  lin_instances = var.lin_vms
  win_instances = var.win_vms
  launch_lin  = var.launch_lin
  launch_win  = var.launch_win
  location = var.location
  rg_name = azurerm_resource_group.arcgis.name
  subnet_id = azurerm_subnet.macs-snet.id
  asg_id = module.asg.asg_id
  #vm-asg = var.asg
  vm_asg_map = var.vm_asg_map
  #key_vault           = azurerm_key_vault.arcgis.id
  #key_vault_key       = azurerm_key_vault_key.arcgis.id
  #key_vault_uri       = azurerm_key_vault.arcgis.vault_uri
  depends_on = [module.asg]
}



/*
module "rsv" {
  source = "../modules/rcv"
  number_of_instances = var.num_ins
  names = var.name
  skus = var.skus
  cust_name = var.cust_name
  location = var.location
  resource_group_name = azurerm_resource_group.arcgis.name
}

module "backups" {
  count = var.enable_bkup == "true" ? 1:0
  source  = "../modules/bkup"
  rg_name = azurerm_resource_group.arcgis.name
  location = var.location
  rsv_name = module.rsv.rsv_name
  fs_stg_details = module.storage_accounts.fs_stg_details
  all_vm_details = module.vm.all_vm    
}
*/
