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

  allocation_model = "ReservationPool"
  network_pool_name = "PVDC-A01-VXLAN-NP"
  provider_vdc_name = "PVDC-A01"


  compute_capacity {
    cpu {
      allocated = 2048
    }

    memory {
      allocated = 2048
    }
  }

  storage_profile {
    name     = "Gold Tier Policy"
    limit    = 10240
    default  = true    
  }

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

  name                    = "terraform EGW"
  description             = "new edge gateway"
  configuration           = "compact"
  default_gateway_network = "Site-A-ExtNet"
  external_networks       = ["Site-A-ExtNet"] 
  advanced                = true
}

# Create Org Network
resource "vcd_network_routed" "net" {
 org = var.org_name
  vdc = var.vdc_name
  name         = "terraform-net"
  edge_gateway = "terraform EGW"
  gateway      = "10.10.0.1"
}

 # Create vApp - Servers
 resource "vcd_vapp" "vapp" {
   name = "Servers"
   org = var.org_name
   vdc = var.vdc_name
 }


