locals{
  stg_acc = {
        for idx, sa in var.stg_ids: idx => sa
  }
}
resource "azurerm_data_protection_backup_vault" "Central_Blob-bkup_Macs" {
  name                = "example-backup-vault"
  resource_group_name = var.resource_group_name
  location            = var.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "bkup-Agent" {
  for_each = local.stg_acc
  scope                = each.value
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.Central_Blob-bkup_Macs.identity[0].principal_id
}

resource "azurerm_data_protection_backup_policy_blob_storage" "BkupVault" {
  name               = "CentralBlob-bkupMacs-backup-policy"
  vault_id           = azurerm_data_protection_backup_vault.Central_Blob-bkup_Macs.id
  retention_duration = "P30D"
}

resource "azurerm_data_protection_backup_instance_blob_storage" "Blob_Instance" {
  for_each = local.stg_acc
  name               = "Blob-bkupMacs-backup-instance${each.key}"
  vault_id           = azurerm_data_protection_backup_vault.Central_Blob-bkup_Macs.id
  location           = var.location
  storage_account_id = each.value
  backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.BkupVault.id

  depends_on = [azurerm_role_assignment.bkup-Agent]
}
