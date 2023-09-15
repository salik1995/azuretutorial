terraform {
  required_providers{
    azurerm={
      source="hashicorp/azurerm"
        version= ">=3.70.0"
        }
}
required_version=">=1.5.0"
}
provider "azurerm"{
  features {}
  skip_provider_registration="true"

subscription_id=var.subscription_id
client_id=var.client_id
clientsecret=var.client_secret
tenant_id=var.tenent_id
}







