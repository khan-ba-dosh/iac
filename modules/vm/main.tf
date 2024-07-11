locals {

  ext_val_list = flatten([

   for key, obj in var.vm_asg_map : [
   
      for num in obj.asg_num: {
     
        key = key
        value = num  
      }
 
    ]


  ])

  ext_val_map: {
     for key, obj in var.vm_asg_map: key => obj.asg_num
  }

}



resource "azurerm_network_interface" "macs-nic" {
  
  #count               = var.launch_win == "true" ? length(var.instances)  : 0
  for_each            =  var.instances
  name                = "${each.key}-nic"#"${var.instances[count.index].name}-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "${each.key}-ipconfig" #"${var.instances[count.index].name}-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "macs-vm" {
  depends_on = [azurerm_network_interface.macs-nic]
  #count               = var.launch_win == "true" ? length(var.instances)  : 0
  for_each            =  var.instances 
  name                = each.key
  location            = var.location
  resource_group_name = var.rg_name
  network_interface_ids = [
    azurerm_network_interface.macs-nic[each.key].id
  ]
  vm_size                = each.value.size
  
  zones  = ["2"]
  
  os_profile{
    computer_name       = "${each.key}-vm"
    admin_username      = each.value.admin_username
    admin_password      = each.value.admin_password
  }

  
  dynamic os_profile_linux_config {
    for_each = split(":", var.instances[each.key].os_disk_image_urn)[0]  == "Canonical" ? [1] : []
    content {
      disable_password_authentication = false
  }
  }

  dynamic os_profile_windows_config {
    for_each = split(":", var.instances[each.key].os_disk_image_urn)[0]  == "MicrosoftWindowsServer" ? [1] : []
    content {
      #disable_password_authentication = false
  }
  }


  storage_os_disk {
    caching              = "ReadWrite"
    managed_disk_type  = "Standard_LRS"
    create_option        = "FromImage"  
    name                 = "${each.key}-osdisk"
  }

  storage_image_reference {
    publisher = split(":", var.instances[each.key].os_disk_image_urn)[0]
    offer     = split(":", var.instances[each.key].os_disk_image_urn)[1]
    sku       = split(":", var.instances[each.key].os_disk_image_urn)[2]
    version   = split(":", var.instances[each.key].os_disk_image_urn)[3]
  }
}

/*
#create_data_disk#
resource "azurerm_managed_disk" "data_disk" {
  for_each = var.instances
  name                 = "${each.key}-datadisc"
  location             = var.location
  resource_group_name  = var.rg_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "32"
  zone = "1"
}
#data_disk_attachment#
resource "azurerm_virtual_machine_data_disk_attachment" "datadisk-attachment" {
  for_each           =  var.instances
  managed_disk_id    = azurerm_managed_disk.data_disk[each.key].id #azurerm_managed_disk.mon-disk[element(azurerm_managed_disk.mon-disk.*.id, count.index)]
  virtual_machine_id = azurerm_virtual_machine.macs-vm[each.key].id #azurerm_windows_virtual_machine.mon[element(azurerm_windows_virtual_machine.mon.*.id, count.index)]
  lun                = "20"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_extension" "lin-datadinit" {
  #count = "${var.vmextensiondatadisk_count}"
  for_each = var.launch_lin == "true" ? toset(var.lin_instances) : []  #split(":",tostring(var.instances[*].os_disk_image_urn))[0] == "Canonical" ? [1]:[]  
  name                 = "runcommand-linuxvm"  #"runcommand-${var.virtual_machine_name[count.index]}"
  #location             = var.location  #"${azurerm_resource_group.main.location}"
  #resource_group_name  = rg_name    #"${azurerm_resource_group.main.name}"
  virtual_machine_id = azurerm_virtual_machine.macs-vm[each.value].id  #"${azurerm_virtual_machine.vm.*.name[count.index]}"
  #publisher           = "Microsoft.OSTCExtensions"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
  {
    "fileUris": ["https://saoperate001.blob.core.windows.net/diskinitialize/script.sh"],
    "commandToExecute": "sudo bash script.sh"
  }
SETTINGS
  depends_on =     [
      #azurerm_virtual_machine_data_disk_attachment.logdisk-attachment,
      azurerm_virtual_machine_data_disk_attachment.datadisk-attachment,
    ]

}


resource "azurerm_virtual_machine_extension" "linux-encry" {
  for_each            =  var.launch_lin == "true" ? toset(var.lin_instances) : []
  name                       = "runcommand-encryption"
  virtual_machine_id         = azurerm_virtual_machine.macs-vm[each.value].id 
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryptionForLinux"
  type_handler_version       = "1.1" 
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "EncryptionOperation"   : "EnableEncryption",
        "KeyVaultURL"           : "${var.key_vault_uri}",
        "KeyVaultResourceId"    : "${var.key_vault}",
        "KeyEncryptionKeyURL"   : "${var.key_vault_key}",
        "KekVaultResourceId"    : "${var.key_vault}", 
        "KeyEncryptionAlgorithm": "RSA-OAEP",
        "VolumeType"            : "All"        
    }
SETTINGS
  depends_on =     [
      azurerm_virtual_machine_extension.lin-datadinit,
    ]
}

###WIN######
#data_disk_initialization#
resource "azurerm_virtual_machine_extension" "win-disk_init" {
    #count                = var.data_disk != false ? var.data_disk_count : 0
  depends_on=[
    azurerm_virtual_machine.macs-vm,
    azurerm_virtual_machine_data_disk_attachment.datadisk-attachment,
    #azurerm_virtual_machine_data_disk_attachment.logdisk-attachment
    ]
  for_each = var.launch_win == "true" ? toset(var.win_instances) :[]#split(":", tostring(var.instances[*].os_disk_image_urn))[0]  == "MicrosoftWindowsServer" ? [1] : []
  name = "ext-disk-init"
  virtual_machine_id = azurerm_virtual_machine.macs-vm[each.value].id
  publisher = "Microsoft.Compute"
  type = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings = <<SETTINGS
     {
        "fileUris": ["https://saoperate001.blob.core.windows.net/diskinitialize/config_diskinit.ps1"],
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File config_diskinit.ps1"
    }
 SETTINGS
   tags = {
     name = "win_Disk_Init"
   }
 }
#disk-encryption#
resource "azurerm_virtual_machine_extension" "win_disk_encry" {
  #count                = var.data_disk != false ? var.data_disk_count : 0
  for_each            =   var.launch_win == "true" ? toset(var.win_instances) :[]
  name                       = "ext-diskeEncryption"
  virtual_machine_id         = azurerm_virtual_machine.macs-vm[each.value].id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryption"
  type_handler_version       = "2.2"
  auto_upgrade_minor_version = true
  depends_on = [
   azurerm_virtual_machine_extension.win-disk_init
  ]
  settings = <<SETTINGS
    {
        "EncryptionOperation": "EnableEncryption",
        "KeyVaultURL": "${var.key_vault_uri}",
        "KeyVaultResourceId": "${var.key_vault}",
        "KeyEncryptionKeyURL": "${var.key_vault_key}",
        "KekVaultResourceId": "${var.key_vault}",
        "KeyEncryptionAlgorithm": "RSA-OAEP",
        "VolumeType": "All"
    }
 SETTINGS
}
*/

resource "azurerm_network_interface_application_security_group_association" "asg-vm-bind" {
  for_each = local.ext_val_map
  network_interface_id          = azurerm_network_interface.macs-nic["${each.key}"].id
  application_security_group_id = var.asg_id[]

  depends_on = [azurerm_virtual_machine.macs-vm]
}

output "all_vm" {

  value = [for vm in azurerm_virtual_machine.macs-vm: "${vm.id}"]

}
