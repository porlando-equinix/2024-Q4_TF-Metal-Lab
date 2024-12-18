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
  user_data        = <<-EOT
package_update: true
package_upgrade: true
package_reboot_if_required: true
write_files:
- path /etc/network/interfaces
append: true 
content: |
auto bond0.444
iface bond0.444 inet static 
address 10.10.10.1
netmask: 255.255.255.0
runcmd:
- systemctl restart networking
EOT

}
resource "equinix_metal_device" "svr2" {
  hostname         = "pat-q4-tf-da-svr2"
  plan             = "c3.small.x86"
  metro            = "da"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = "aba4bb63-5932-4203-a297-5338d5e9daa3"

  user_data        = <<-EOT
package_update: true
package_upgrade: true
package_reboot_if_required: true
write_files:
- path /etc/network/interfaces
append: true
content: |
auto bond0.444
iface bond0.444 inet static
address 10.10.10.2
netmask: 255.255.255.0
runcmd:
- systemctl restart networking
EOT
}


resource "equinix_metal_vlan" "vlan1" {
  description = "VLAN in NY"
  metro       = "ny"
  project_id  = "aba4bb63-5932-4203-a297-5338d5e9daa3"
  vxlan       = 444
}
resource "equinix_metal_vlan" "vlan2" {
  description = "VLAN in DA"
  metro       = "da"
  project_id  = "aba4bb63-5932-4203-a297-5338d5e9daa3"
  vxlan       = 444
}

resource "equinix_metal_port" "NY-port" {
  depends_on  = [equinix_metal_device.svr1]
  port_id     = "2a027f9f-dae6-454b-a783-2a25c678f506"
  vlan_ids    = [equinix_metal_vlan.vlan1.id]
  bonded      = true
}
resource "equinix_metal_port" "DA-port" {
  depends_on  = [equinix_metal_device.svr2]
  port_id     = "c3b18488-4d4a-4764-9330-a67521d8ed6a"
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

resource "equinix_metal_connection" "pat-tf-fabric-da" {
  name               = "pat-tf-fabric-da"
  project_id         = "aba4bb63-5932-4203-a297-5338d5e9daa3"
  type               = "shared"
  redundancy         = "primary"
  metro              = "da"
  speed              = "50Mbps"
  service_token_type = "z_side"
  contact_email      = "porlando@equinix.com"
  vlans              = [equinix_metal_vlan.vlan2.vxlan]
}

resource "equinix_fabric_connection" "pat-tf-fabric" {
  name = "pat-tf-fabric"
  type = "EVPL_VC"
  bandwidth = 50
  a_side {
    access_point {
      type = "COLO"
      port {
        uuid = ""
      }
      link_protocol {
        type = "QINQ"
        vlan_s_tag = "444"
      }
    }
  }
  z_side {
    service_token {
      uuid = equinix_metal_connection.pat-tf-fabric-da.service_token.0.id
    }
  }
  depends_on = [equinix_metal_connection.pat-tf-fabric-da]
}

