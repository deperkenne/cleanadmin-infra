terraform {                                  
  required_providers {                       
    azurerm = {                              
      source  = "hashicorp/azurerm"          
      version = "~> 4.0"                     
    }                                        
  }                                          
}                                            
                                             
                                             
terraform {                                  
  backend "azurerm" {                        
    resource_group_name  = "depRG"           
    storage_account_name = "terraspeicher"   
    container_name       = "terracontenaire" 
    key                  = "dev2.tfstate"    
  }                                          

}

provider "azurerm" {    
  features {}           
}                       