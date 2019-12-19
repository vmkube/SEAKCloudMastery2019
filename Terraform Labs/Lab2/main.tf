# Connecting to vCD
provider "vcd" {
  user                  = var.vcd_user
  password              = var.vcd_pass
  org                   = var.vcd_org
  url                   = var.vcd_url
}

# Create new org

resource "vcd_org" "org-name" {
  name             = var.org_name
  full_name        = var.org_full_name
  is_enabled       = "true"
  delete_recursive = "true"
  delete_force     = "true"
  deployed_vm_quota = "10"
  can_publish_catalogs = "false"
}

#Create new VDC

resource "vcd_org_vdc" "my-vdc" {
  name        = var.vdc_name
  org         = var.org_name

  allocation_model = "??"
  network_pool_name = "??"
  provider_vdc_name = "??"


  compute_capacity {
    cpu {
      allocated = 2048
    }

    memory {
      allocated = 2048
    }
  }

  #insert code here

  metadata = {
    role    = "customerName"
    env     = "staging"
    version = "v1"
  }  

  network_quota = 10
  enabled                  = true
  enable_thin_provisioning = true
  enable_fast_provisioning = true
  delete_force             = true
  delete_recursive         = true
}

# Create Edge GW

resource "vcd_edgegateway" "egw" {
	org = var.org_name
	vdc = var.vdc_name

#insert code here
}




