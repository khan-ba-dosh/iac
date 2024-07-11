locals {
   existing = { for i in range(var.number_of_instances) :
    i => {
     name = element(var.names, i % length(var.names))
     
    }
  }
   existing_vm = { for i in range(var.vm_instances) :
    i => {
     name = element(var.vm_names, i % length(var.vm_names))

    }
  }
}

data "azurerm_resource_group" "rg-existing" {
  name = var.rg_name
}


#vm
data "azurerm_virtual_machine" "env" {
  count = var.enable_fetch_vm ? 1 : 0
  name                = var.enable_fetch_vm ? local.existing_vm[count.index].name : null
  resource_group_name = var.rg_name
}

output "existing_vm" {
  value = [
    for vm in data.azurerm_virtual_machine.env: "${vm.id}"]
  }


data "azurerm_storage_account" "existing_stg" {
  count = var.enable_fetch_stg ? 1 : 0
  name                = var.storage_account_names
  resource_group_name = var.rg_name
}

data "azurerm_storage_share" "env" {
  count = var.enable_fetch_stg ? 1 : 0
  name                 = var.enable_fetch_stg ? local.existing[count.index].name : null
  storage_account_name = var.storage_account_names
}


output "existing_fs" {
  value = [
    for fs in data.azurerm_storage_share.env: "${fs.name}"]
}

output "stg_id" {

   value = [for stg in data.azurerm_storage_account.existing_stg: "${stg.id}" ]
}




########################################################################
/*
locals {
   existing = { for i in range(var.number_of_instances) :
    i => {
     name = element(var.names, i % length(var.names))
     #storage_account_name = element(var.storage_account_names, i % length(var.storage_account_names))
    }
  }
   existing_vm = { for i in range(var.vm_instances) :
    i => {
     name = element(var.vm_names, i % length(var.vm_names))
     
    }
  }
}

data "azurerm_resource_group" "rg-existing" {
  name = var.rg_name
}


#vm
data "azurerm_virtual_machine" "env" {
  #for_each           = enable_fetch_vm == "true" ? local.existing_vm : 0
  count               = enable_fetch_vm == "true" ? local.existing_vm : 0
  name                = var.names[count.index]
  resource_group_name = var.rg_name
}

output "existing_vm" {
  value = [
    for vm in data.azurerm_virtual_machine.env: "${vm.id}"]
  }


data "azurerm_storage_account" "existing_stg" {
  #for_each            = var.enable_fetch_stg == "true" ? 1 : 0
  count            = enable_fetch_vm == "true" ? 1: 0
  name                = var.storage_account_names
  resource_group_name = var.rg_name
}


data "azurerm_storage_share" "env" {
  #for_each             =  enable_fetch_stg == "true" ? local.existing : 0
  count                = enable_fetch_vm == "true" ? local.existing : 0
  name                 = var.names[count.index]
  storage_account_name = var.storage_account_names
}


output "existing_fs" {
  value = [
    for fs in data.azurerm_storage_share.env: "${fs.name}"]
}

output "stg_id" {

   value = [for stg in data.azurerm_storage_account.existing_stg: "${stg.id}" ]
}



output "stg_id" {
   
   value = ["${data.azurerm_storage_account.existing_stg.id}"]

}
*/
