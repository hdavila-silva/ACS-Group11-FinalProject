# Default tags
output "default_tags" {
  value = {
    "Owner" = "group11"
    "App"   = "web"
  }
}

# Prefix to identify resources
output "prefix" {
  value     = "group11"
}