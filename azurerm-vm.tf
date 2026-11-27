
locals {
   project_name = var.project
   vm_rg= azurerm_resource_group.this
   #vm_size = coalesce(var.size, var.env == "dev" ?"Standard_B2s_v2": "Standard_D4_v5")
   vm_size  = var.size
   tags = {                 
           project = var.project
  
         }
}                        

# 2. Le réseau virtuel et son sous-réseau
resource "azurerm_virtual_network" "this" {
  name                = "vnet-${local.project_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["10.0.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "this" {
  name                 = "snet-${local.project_name}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}


# 3. Le pare-feu : seul le SSH (port 22) depuis VOTRE IP est autorisé
resource "azurerm_network_security_group" "this" {
  name                = "nsg-${local.project_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.tags

  security_rule {
    name                       = "allow-ssh-from-my-ip"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    #source_address_prefix      = "${var.my_ip}/32"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# 4. L'IP publique : l'adresse de la VM sur Internet
resource "azurerm_public_ip" "this" {
  name                = "pip-${local.project_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"   # l'IP ne change pas, même si la VM redémarre
  sku                 = "Standard" # obligatoire pour les nouvelles IP publiques
  tags                = local.tags
}


resource "azurerm_network_interface" "this"{
    name = "ni-${local.project_name}" 
    location = azurerm_resource_group.this.location
    resource_group_name = azurerm_resource_group.this.name

    ip_configuration {
       name = "ipconfig"
       subnet_id   = azurerm_subnet.this.id
       private_ip_address_allocation = "Dynamic"
       public_ip_address_id = azurerm_public_ip.this.id
    }

}


resource "azurerm_linux_virtual_machine" "this" {   
      name = "vm-${local.project_name}"                    
      resource_group_name = azurerm_resource_group.this.name
      location = azurerm_resource_group.this.location       
      size = local.vm_size
      disk_controller_type = "NVMe"                    
      admin_username = "userkenne" 
      custom_data = base64encode(file("${path.module}/cloud-init.yaml"))                 
                                                    
                                                    
      network_interface_ids = [                     
       azurerm_network_interface.this.id,        
      ]                                             
                                                    
                                                    
  admin_ssh_key {                                   
    username   = "userkenne" 
    public_key = tls_private_key.ssh.public_key_openssh                        
    #public_key = file("~/.ssh/id_rsa.pub")          
  }                                                 
                                                    
                                                    
  os_disk {                                         
    caching              = "ReadWrite"              
    storage_account_type = "Standard_LRS"           
  }                                                 
                                                    
                                                    
       
       
  source_image_reference {
   publisher = "Canonical"
   offer     = "0001-com-ubuntu-server-jammy"
   sku       = "22_04-lts-gen2"    # ← le "-gen2" à la fin est important
   version   = "latest"
}
       
       
       
                                                    
}    


# 1. Terraform FABRIQUE une paire de clés (cadenas + clé)
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Terraform ENREGISTRE la clé privée dans un fichier, sur votre PC
resource "local_sensitive_file" "ssh_private_key" {
  filename        = "${path.module}/cle-vm.pem"
  content         = tls_private_key.ssh.private_key_openssh
  file_permission = "0600"
}