#le fichier terraform.tfvars est lu automatiquement 

env = "dev"
# Votre IP publique : tapez "curl ifconfig.me" dans le terminal
my_ip = "0.0.0.0"

location = "eastus2"

keycloack_image = "quay.io/keycloak/keycloak:26.0"

postgres_image = "postgres:15-alpine"
