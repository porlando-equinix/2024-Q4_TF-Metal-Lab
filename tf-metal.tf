terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
      version = ">= 1.35.0"
    }
  }
}

provider "equinix" {
  client_id     = var.client_id
  client_secret = var.client_secret
  auth_token    = var.metal_auth_key
}

resource "equinix_metal_device" "svr1" {
  hostname         = "pat-q4-tf-svr1"
  plan             = "c3.small.x86"
  metro            = "sv"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = "bdc6d5d4-91d3-44e1-a44b-cb5beda4b4c6"
}
resource "equinix_metal_device" "svr2" {
  hostname         = "pat-q4-tf-svr1"
  plan             = "c3.small.x86"
  metro            = "da"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = "bdc6d5d4-91d3-44e1-a44b-cb5beda4b4c6"
}


resource "equinix_metal_vlan" "vlan1" {
  description = "VLAN in SV"
  metro       = "sv"
  project_id  = "bdc6d5d4-91d3-44e1-a44b-cb5beda4b4c6"
  vxlan       = 444
}
resource "equinix_metal_vlan" "vlan2" {
  description = "VLAN in DA"
  metro       = "da"
  project_id  = "bdc6d5d4-91d3-44e1-a44b-cb5beda4b4c6"
  vxlan       = 445
}


