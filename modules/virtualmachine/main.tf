resource "azurerm_network_interface" "network_interface" {
   name                = "nic-${var.name}"
   location            = var.location
   resource_group_name = var.resource_group_name

   ip_configuration {
     name                          = "psConfiguration"
     subnet_id                     = var.subnet_id
     private_ip_address_allocation = "Dynamic"
   }
 }
 
resource "azurerm_network_interface_application_security_group_association" "asgassign" {
  network_interface_id          = azurerm_network_interface.network_interface.id
  application_security_group_id = var.application_security_group
}
resource "azurerm_windows_virtual_machine" "virtual_machine" {
  name                = "vm-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = "operateadmin"
  admin_password      = var.key_vault_secret
  network_interface_ids = [azurerm_network_interface.network_interface.id] #[element(azurerm_network_interface.network_interface.*.id, count.index)]
  zone = "1"

  os_disk {
    name                 = "osdisk-${var.name}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.osdisk_size
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
#create_data_disk#
resource "azurerm_managed_disk" "data_disk" {
  name                 = "datadisk-${var.name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.datadisk_size
  zone = "1"
}
#data_disk_attachment#
resource "azurerm_virtual_machine_data_disk_attachment" "datadisk-attachment" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id #azurerm_managed_disk.mon-disk[element(azurerm_managed_disk.mon-disk.*.id, count.index)]
  virtual_machine_id = azurerm_windows_virtual_machine.virtual_machine.id #azurerm_windows_virtual_machine.mon[element(azurerm_windows_virtual_machine.mon.*.id, count.index)]
  lun                = "20"
  caching            = "ReadWrite"
}
resource "azurerm_managed_disk" "log_disk" {
  name                 = "logdisk-${var.name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.logdisk_size
  zone = "1"
}
#log_disk_attachment#
resource "azurerm_virtual_machine_data_disk_attachment" "logdisk-attachment" {
  managed_disk_id    = azurerm_managed_disk.log_disk.id #azurerm_managed_disk.mon-disk[element(azurerm_managed_disk.mon-disk.*.id, count.index)]
  virtual_machine_id = azurerm_windows_virtual_machine.virtual_machine.id #azurerm_windows_virtual_machine.mon[element(azurerm_windows_virtual_machine.mon.*.id, count.index)]
  lun                = "10"
  caching            = "ReadWrite"
}

#data_disk_initialization#
resource "azurerm_virtual_machine_extension" "disk_init" {
  depends_on=[
    azurerm_windows_virtual_machine.virtual_machine,
    azurerm_virtual_machine_data_disk_attachment.datadisk-attachment,
    azurerm_virtual_machine_data_disk_attachment.logdisk-attachment
    ]
  name = "ext-disk-init-${var.name}"
  virtual_machine_id =  azurerm_windows_virtual_machine.virtual_machine.id
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
     name = "Disk_Init"
   }
 }
#disk-encryption#
resource "azurerm_virtual_machine_extension" "disk_encry" {
  name                       = "ext-diskeEncryption-${var.name}"
  virtual_machine_id         = azurerm_windows_virtual_machine.virtual_machine.id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryption"
  type_handler_version       = "2.2"
  auto_upgrade_minor_version = true
  depends_on = [
   azurerm_virtual_machine_extension.disk_init
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

module "lb_backend_pool" {
  source = "../lb_backend_pool"
  count = var.in-box && var.in-box-ha || var.multi-tier && var.multi-tier-ha != false ? 1 : 0
   name                    = "backend_address_pool_address-${var.name}"
   #backend_address_pool_id = data.azurerm_lb_backend_address_pool.azlb.id
   virtual_network_id      = var.virtual_network_id
   ip_address              = azurerm_windows_virtual_machine.virtual_machine.private_ip_address
   resource_group_name     = var.resource_group_name
   cust_name               = var.cust_name
}
