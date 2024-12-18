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
  hostname         = "pat-q4-tf-sv-svr1"
  plan             = "c3.small.x86"
  metro            = "ny"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = "aba4bb63-5932-4203-a297-5338d5e9daa3"
}
resource "equinix_metal_device" "svr2" {
  hostname         = "pat-q4-tf-da-svr2"
  plan             = "c3.small.x86"
  metro            = "da"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = "aba4bb63-5932-4203-a297-5338d5e9daa3"
}


resource "equinix_metal_vlan" "vlan1" {
  description = "VLAN in "NY"
  metro       = "ny"
  project_id  = "bdc6d5d4-91d3-44e1-a44b-cb5beda4b4c6"
  vxlan       = 444
}
resource "equinix_metal_vlan" "vlan2" {
  description = "VLAN in DA"
  metro       = "da"
  project_id  = "bdc6d5d4-91d3-44e1-a44b-cb5beda4b4c6"
  vxlan       = 444
}

resource "equinix_metal_port" "NY-port" {
  depends_on  = [equinix_metal_device.svr1]
  port_id     = [2a027f9f-dae6-454b-a783-2a25c678f506]
  vlan_ids    = [equinix_metal_vlan.vlan1.id]
  bonded      = true
}
resource "equinix_metal_port" "DA-port" {
  depends_on  = [equinix_metal_device.svr2]
  port_id     = [c3b18488-4d4a-4764-9330-a67521d8ed6a]
  vlan_ids    = [equinix_metal_vlan.vlan2.id]
  bonded      = true
}


resource "equinix_metal_virtual_circuit" "NY-to-dedicated-port" {
  connection_id = ""
  project_id = "aba4bb63-5932-4203-a297-5338d5e9daa3"
  port_id = ""
  vlan_id = equinix_metal_vlan.vlan1.id
  nni_vlan = 444
}




