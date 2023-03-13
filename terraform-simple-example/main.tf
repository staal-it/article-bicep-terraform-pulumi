terraform {
  required_version = ">= 1.1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.27.0"
    }
  }
}

provider "azurerm" { 
  features {}
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

resource "azurerm_storage_account" "storage" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "storageId" {
  value = azurerm_storage_account.storage.id  
}