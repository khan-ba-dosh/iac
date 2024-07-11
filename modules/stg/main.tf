#Generate a map of storage account instances based on the number_of_instances variable
locals {
  storage_accounts = { for i in range(var.number_of_instances) :
    i => {
      account_tier = element(var.account_tiers, i % length(var.account_tiers))
      account_kind = element(var.account_kinds, i % length(var.account_kinds))
      account_replication_type = element(var. account_replication_types, i % length(var. account_replication_types))
      access_tier = element(var.access_tiers, i % length(var.access_tiers))
      name = element(var.names, i % length(var.names))
      type = element(var.types, i % length(var.types))
    }
  }
  
   blob_storage_accounts = {
    for key, account in azurerm_storage_account.stg:
    key => account
    if account.account_kind == "BlobStorage" || account.account_kind == "BlockBlobStorage" || account.account_kind == "StorageV2"
  }

  fs_storage_accounts = {
    for key, account in azurerm_storage_account.stg:
    key => account
    if account.account_kind == "FileStorage" 
  }
 /*
 premium_stg_accounts = {
  
  for key, account in azurerm_storage_account.stg:
  key => account.id
  if account.account_tier == "Premiumm"
 }
*/
}

# Generate a random integer to ensure storage account names are unique
resource "random_integer" "suffix" {
  min = 10
  max = 99
}


# Create the storage accounts using a for_each loop
resource "azurerm_storage_account" "stg" {
  for_each             = local.storage_accounts
  name                 = "${each.value.name}${var.cust_name}${each.value.type}${random_integer.suffix.result}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  account_tier         = each.value.account_tier
  account_kind         = each.value.account_kind
  access_tier          = each.value.access_tier
  account_replication_type = each.value.account_replication_type
  is_hns_enabled       = each.value.account_tier == "Standard" ? true : false
  
  dynamic "blob_properties" {
    for_each =  each.value.account_tier == "Standard" ? [1] : []
   content{
      
      delete_retention_policy {
    
    }
   }
  }

  lifecycle {
    ignore_changes = [name]
  }
  
  depends_on = [random_integer.suffix]
}



#Blob
resource "azurerm_storage_container" "stg-con" {
  for_each = local.blob_storage_accounts
  name                  = "${each.value.name}-con"
  storage_account_name  = azurerm_storage_account.stg[each.key].name
  #container_access_type = "container"
}

resource "azurerm_storage_blob" "stg-blob" {
  for_each = local.blob_storage_accounts
  name                  = each.value.name
  storage_account_name   = azurerm_storage_account.stg[each.key].name
  storage_container_name = azurerm_storage_container.stg-con[each.key].name
  type                   = "Block"

  depends_on = [azurerm_storage_container.stg-con]
}

#FS
resource "azurerm_storage_share" "fs-pool" {
  for_each = local.fs_storage_accounts
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.stg[each.key].name
  quota                = var.quota
}
/*
data "azurerm_storage_account" "macs-fs-pool" {
  for_each = {for idx, tier in local.storage_accounts: idx => tier if account_tier == "Premium"}
  name                = each.value.name
  resource_group_name = var.resource_group_name
}
*/

output "fs_stg_details" {
  value = {
    for key, account in azurerm_storage_account.stg: 
    key => {
        id = account.id
        name = account.name
     }
    if account.account_tier == "Premium"
  }
}

