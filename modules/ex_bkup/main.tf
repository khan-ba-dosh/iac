data "azurerm_recovery_services_vault" "vault" {
  name                = var.rsv_name[0]
  resource_group_name = var.rg_name
}


resource "azurerm_backup_policy_vm" "globalvm" {
    count               = var.bkup_vm ? 1: 0
    name                = "global-vm-rcv-policy"
    resource_group_name = var.rg_name
    recovery_vault_name = data.azurerm_recovery_services_vault.vault.name
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

resource "azurerm_backup_protected_vm" "vm-bkup-pool" {
  #count               = length(var.existing_vm)
  count               = var.bkup_vm ? 1: 0
  resource_group_name = var.rg_name
  recovery_vault_name = data.azurerm_recovery_services_vault.vault.name

  source_vm_id        = var.existing_vm[count.index]
  backup_policy_id    = azurerm_backup_policy_vm.globalvm[count.index].id

}
############FS########################

resource "azurerm_backup_policy_file_share" "globalfs" {
    count               = var.bkup_fs ?  1: 0
    name                = "global-fs-rcv-policy"
    resource_group_name = var.rg_name
    recovery_vault_name = data.azurerm_recovery_services_vault.vault.name
  #timezone
    backup {
      frequency = "Daily"
      time      = "23:00"
    }
  
    retention_daily {
      count = 10
    }
    #depends_on = [ azurerm_backup_container_storage_account.protection-container ]
 }

resource "azurerm_backup_container_storage_account" "protection-container" {
    count               =  var.bkup_fs ?  1: 0  
    resource_group_name = var.rg_name
    recovery_vault_name = data.azurerm_recovery_services_vault.vault.name
    storage_account_id  = var.stg_id[0]
    
}
#FS
resource "azurerm_backup_protected_file_share" "share1" {
   #count                     = length(var.existing_fs) 
    count                     = var.bkup_fs ?  1: 0
    resource_group_name       = var.rg_name
    recovery_vault_name       = data.azurerm_recovery_services_vault.vault.name
    source_storage_account_id = azurerm_backup_container_storage_account.protection-container[count.index].storage_account_id
    source_file_share_name    = var.existing_fs[count.index]
    backup_policy_id          = azurerm_backup_policy_file_share.globalfs[count.index].id

    depends_on = [
        azurerm_backup_container_storage_account.protection-container
      ]
  }


