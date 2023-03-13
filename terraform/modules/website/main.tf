resource "azurerm_service_plan" "app_service_plan" {
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "app_service" {
  name                = "app-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {}
}

resource "cloudflare_record" "domain-verification" {
  zone_id = var.cloudflare_zone_id
  name    = "asuid.${var.record}.${var.domain}"
  value   = azurerm_linux_web_app.app_service.custom_domain_verification_id
  type    = "TXT"
  ttl     = 3600
}

resource "cloudflare_record" "cname-record" {
  zone_id = var.cloudflare_zone_id
  name    = "${var.record}.${var.domain}"
  value   = azurerm_linux_web_app.app_service.default_hostname
  type    = "CNAME"
  ttl     = 3600
}

resource "azurerm_app_service_custom_hostname_binding" "hostname-binding" {
  hostname            = "${var.record}.${var.domain}"
  app_service_name    = azurerm_linux_web_app.app_service.name
  resource_group_name = var.resource_group_name

  depends_on = [
    cloudflare_record.domain-verification,
    cloudflare_record.cname-record
  ]
}
