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
  
  depends_on = [vcd_org.org-name]
}

# Create Edge GW

resource "vcd_edgegateway" "egw" {
  name                    = "terraform EGW"
  description             = "new edge gateway"
  configuration           = "compact"
  advanced                = true

  external_network {
    name = "Site-A-ExtNet"  

    subnet {
      gateway = "192.168.100.1"
      netmask = "255.255.255.0"
    }
  }

  depends_on = [vcd_org_vdc.my-vdc]
}

# Create Org Network
resource "vcd_network_routed" "net" {
 org = var.org_name
  vdc = var.vdc_name
  name         = "terraform-net"
  edge_gateway = "terraform EGW"
  gateway      = "10.10.0.1"
  
  depends_on = [vcd_edgegateway.egw]
}

 # Create vApp - Servers
 resource "vcd_vapp" "vapp" {
   name = "Servers"
   org = var.org_name
   vdc = var.vdc_name

   depends_on = [vcd_network_routed.net]
 }

 # Create a Catalog
resource "vcd_catalog" "catalog" {
  org = var.org_name

  name = "terraform-catalog"
  delete_recursive = "true"
  delete_force = "true"

  depends_on = [vcd_org.org-name]
}

 # Create a Catalog Item
resource "vcd_catalog_item" "catalog-item" {
  org = var.org_name
  catalog = "terraform-catalog"

  name = "test-item"
  description = "test ova for vApp VM"
  ova_path = "C:/SEAKCloudMastery2019/Terraform Labs/Bonus/test.ovf.ovf"

  depends_on = [vcd_catalog.catalog]
}

 # Create a Virtual Machine Within a vApp
resource "vcd_vapp_vm" "web" {
  org = var.org_name
  vdc = var.vdc_name

  vapp_name = "Servers"
  name = "test"
  catalog_name = "terraform-catalog"
  template_name = "test-item"

  depends_on = [vcd_vapp.vapp]

  #attach VM to an organization network
  network {
    type = "org"
    name = "terraform-net"
    ip = "10.10.0.11"  
    ip_allocation_mode = "MANUAL"  
  }

  #attach VM to a vapp network
  network {
    type               = "vapp"
    name               = "test-vapp-net"
    ip = "192.168.110.11"
    ip_allocation_mode = "MANUAL"
  }
}

resource "vcd_vapp_network" "vapp-net" {
  org = var.org_name
  vdc = var.vdc_name

  vapp_name = "Servers"
  name = "test-vapp-net"
  gateway = "192.168.110.1"
  netmask = "255.255.255.0"
  dns1 = "127.0.0.1"
  dns_suffix = "corp.local"

  depends_on = [vcd_vapp.vapp]
}

resource "vcd_vapp_vm" "web2" {
  org = var.org_name
  vdc = var.vdc_name

  
  vapp_name     = "Servers"
  name          = "test2"
  catalog_name  = "terraform-catalog"
  template_name = "test-item"

  depends_on = [vcd_vapp_vm.web]

  #attach VM to an organization network
  network {
    type = "org"
    name = "terraform-net"
    ip = "10.10.0.12"  
    ip_allocation_mode = "MANUAL"
  }

  #attach VM to a vapp network
  network {
    type               = "vapp"
    name               = "test-vapp-net"
    ip = "192.168.110.12"
    ip_allocation_mode = "MANUAL"  
  }
}
