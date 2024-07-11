data "azurerm_recovery_services_vault" "vault" {
  #for_each = var.rsv_name
  name                = var.rsv_name[0]#each.value.name
  #location            = var.location
  resource_group_name = var.rg_name
  #sku                 = "Standard"
}

resource "azurerm_backup_policy_file_share" "global" {
    #for_each = var.rsv_name
    name                = "global-rcvfs-policy"
    resource_group_name = var.rg_name
    recovery_vault_name = data.azurerm_recovery_services_vault.vault.name#each.value.name
  #timezone
    backup {
      frequency = "Daily"
      time      = "23:00"
    }
  
    retention_daily {
      count = 2
    }

 }

  resource "azurerm_backup_container_storage_account" "protection-container" {
    for_each = var.fs_stg_details
    resource_group_name = var.rg_name
    recovery_vault_name = data.azurerm_recovery_services_vault.vault.name
    storage_account_id  = each.value.id
    
    #depends_on = [azurerm_recovery_services_vault.vault]
}
#FS
resource "azurerm_backup_protected_file_share" "share1" {
    for_each = var.fs_stg_details
    resource_group_name       = var.rg_name
    recovery_vault_name       =  data.azurerm_recovery_services_vault.vault.name
    source_storage_account_id = azurerm_backup_container_storage_account.protection-container[each.key].storage_account_id
    source_file_share_name    = each.value.name
    backup_policy_id          = azurerm_backup_policy_file_share.global.id

    depends_on = [
        azurerm_backup_container_storage_account.protection-container
      ]
  }
#########################################################

resource "azurerm_backup_policy_vm" "globalvm" {
  #for_each = var.rsv_name
 #count = length(var.rsv_name)
  name                = "global-recovery-vault-policy"
  resource_group_name = var.rg_name
  recovery_vault_name = data.azurerm_recovery_services_vault.vault.name #each.value.name
#timezone
 policy_type = "V2"
  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }

}

resource "azurerm_backup_protected_vm" "all_vm-bkup-pool" {
  #for_each = local.vm_ids_map
  count = length(var.all_vm_details)
  resource_group_name = var.rg_name
  recovery_vault_name = data.azurerm_recovery_services_vault.vault.name

  source_vm_id        = var.all_vm_details[count.index]
  backup_policy_id    = azurerm_backup_policy_vm.globalvm.id

  #depends_on = [ data.azurerm_recovery_services_vault.vault]
}
