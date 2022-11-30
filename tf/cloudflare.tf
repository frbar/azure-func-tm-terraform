resource "cloudflare_record" "poc_cname" {
  zone_id = var.cf_zone_id
  name    = "*.${var.env_name}"
  value   = azurerm_traffic_manager_profile.poc.fqdn
  type    = "CNAME"
  ttl     = 1
  proxied = true
  lifecycle {
    ignore_changes = [
      proxied,
    ]
  }
}

resource "cloudflare_record" "poc_txt" {
  zone_id = var.cf_zone_id
  name    = "asuid.${var.env_name}"
  value   = azurerm_windows_function_app.poc[0].custom_domain_verification_id
  type    = "TXT"
  proxied = false
  ttl     = 3600
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [
    cloudflare_record.poc_txt
  ]

  create_duration = "30s"
}

resource "azurerm_app_service_custom_hostname_binding" "poc" {
  count               = 2
  hostname            = "*.${var.env_name}.${var.cf_domain}"
  app_service_name    = azurerm_windows_function_app.poc[count.index].name
  resource_group_name = azurerm_windows_function_app.poc[count.index].resource_group_name

  depends_on = [
    time_sleep.wait_30_seconds
  ]
}

resource "cloudflare_certificate_pack" "poc" {
  zone_id               = var.cf_zone_id
  type                  = "advanced"
  hosts                 = [ var.cf_domain, "*.${var.env_name}.${var.cf_domain}" ]
  validation_method     = "txt"
  validity_days         = 30
  certificate_authority = "digicert"
  cloudflare_branding   = false
}

resource "cloudflare_ruleset" "transform_uri_http_headers" {
  zone_id     = var.cf_zone_id 
  name        = "${var.env_name} - injects x-functions-key"
  description = "modify HTTP headers before reaching origin"
  kind        = "zone"
  phase       = "http_request_late_transform"

  rules {
    action = "rewrite"

    action_parameters {
      headers {
        name      = "x-functions-key"
        operation = "set"
        value     = random_password.function_key.result
      }
    }

    expression  = "(http.host contains \"${var.env_name}.${var.cf_domain}\")"
    description = "${var.env_name} - injects x-functions-key"
    enabled     = true
  }
}