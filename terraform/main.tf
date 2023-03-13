locals {
  project_name = "article-terraform"
  location     = "westeurope"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.project_name}-${var.environment}"
  location = local.location
}

module "website" {
  source = "./modules/website"

  project_name        = local.project_name
  environment         = var.environment
  location            = local.location
  cloudflare_zone_id  = var.cloudflare_zone_id
  record              = var.record
  domain              = var.domain
  resource_group_name = azurerm_resource_group.rg.name
}
