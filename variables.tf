variable "project"{
    type = string
    default = "dd-clean"
}

variable "env" {
   description = "Environnement : dev, test ou prod."
   type = string

   validation {
       condition = contains (["dev","prod"], var.env)
       error_message = "env muss be dev or prod"
   }

}


variable "location"{
    type =  string
    default = null
    validation {
    condition     = contains(["germanywestcentral", "westeurope", "northeurope","swedencentral" ], var.location)
    error_message = "Région non autorisée par l'entreprise."
  }
    
}


variable "size"{
   type = string
   default = null
   validation {
      condition =  var.size== null ||contains (["Standard_D2s_v6","Standard_D2s_v7"],var.size)
      error_message = "size muss be Standar for dev env"
   }

}


variable "my_ip" {
  description = "Votre IP publique (sans /32). Seule cette IP pourra se connecter en SSH."
  type        = string

  validation {
    condition     = can(cidrhost("${var.my_ip}/32", 0))
    error_message = "my_ip doit être une adresse IPv4, par exemple 81.23.45.67."
  }
}

variable "keycloak_image" {
   type = string 
}

variable "postgres_image"{
  type = string
}

variable "postgres_pass" {
  type = string
}
