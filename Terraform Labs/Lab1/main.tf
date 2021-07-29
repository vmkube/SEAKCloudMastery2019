# Connecting to vCD
provider "vcd" {
  user                  = "??"
  password              = "??"
  org                   = "System"
  url                   = "https://vcd-01a.corp.local/api"
  version               = "~> 2.5"
}
# Create new org

resource "vcd_org" "org-name" {
  name             = "??"
  full_name        = "??"
  is_enabled       = "true"
  delete_recursive = "true"
  delete_force     = "true"#  
  deployed_vm_quota = "10"
  can_publish_catalogs = "false"
}


