# make concatenation                                          
locals {
     name = "${var.project}-${var.env}"
     rg_location = coalesce(var.location,var.env == "prod" ? "eastus": " westus2")
}

resource "azurerm_resource_group" "this" {  
  name     =  "rg-${local.name}"                
  location =  "${local.rg_location}"
}                                           