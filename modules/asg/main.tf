resource "azurerm_application_security_group" "gen-asg" {
  for_each = var.asg_name
  name                = each.value
  location            = var.location
  resource_group_name = var.rg_name
}

output asg_id {

 value = [for key in azurerm_application_security_group.gen-asg: "${key.id}"]

} 

