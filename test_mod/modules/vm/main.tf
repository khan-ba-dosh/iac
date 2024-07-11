resource "azurerm_network_interface" "macs-nic" {
  count               = length(var.instances)
  name                = "${var.instances[count.index].name}-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "${var.instances[count.index].name}-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "macs-vm" {
  count               = length(var.instances)
  name                = var.instances[count.index].name
  location            = var.location
  resource_group_name = var.rg_name
  network_interface_ids = [
    element(azurerm_network_interface.macs-nic.*.id, count.index)
  ]
  size                = var.instances[count.index].size
  admin_username      = var.instances[count.index].admin_username
  admin_password      = var.instances[count.index].admin_password
  disable_password_authentication = "false"  

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.instances[count.index].name}-osdisk"
  }

  source_image_reference {
    publisher = split(":", var.instances[count.index].os_disk_image_urn)[0]
    offer     = split(":", var.instances[count.index].os_disk_image_urn)[1]
    sku       = split(":", var.instances[count.index].os_disk_image_urn)[2]
    version   = split(":", var.instances[count.index].os_disk_image_urn)[3]
  }
}

output "all_vm"{
  
 value = [for vm in azurerm_linux_virtual_machine.macs-vm: "${vm.id}"]
}

/*
output "all_vm" {
  value = {
    for key, vm in azurerm_linux_virtual_machine.macs-vm:
    key => {
        id   = vm.id
     }
  }
}
output "ins_vm" {
  value = {
    for key, account in azurerm_linux_virtual_machine.macs-vm:
    key => {
        id   = account.id
     }
  if account.name == "dev-vm" ||  account.name == "prd-vm"
  }
}
*/
