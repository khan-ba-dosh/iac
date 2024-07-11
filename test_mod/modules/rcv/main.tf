#Vaults map

locals {
   rec_vaults = { for i in range(var.number_of_instances) :
    i => {
      name = element(var.names, i % length(var.names))
      sku = element(var.skus, i % length(var.skus))
    }
  }
}

# Generate a random integer to ensure storage account names are unique
resource "random_integer" "suffix" {
  min = 10
  max = 99
}

resource "azurerm_recovery_services_vault" "vault" {
  for_each            = local.rec_vaults
  name                = "${each.value.name}${var.cust_name}${random_integer.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = each.value.sku

  soft_delete_enabled = false
}


output "rsv_name" {
  
  value = [for vault in azurerm_recovery_services_vault.vault: "${vault.name}"]  

}

/*
output "rsv_name" {
  value = {
    for key, account in azurerm_recovery_services_vault.vault:
    key => {
        name = account.name
     }
  }
}
*/
