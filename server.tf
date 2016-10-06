/*
 * The section below build on the configuration files in vlan.tf and includes resource
 * definitions to create VM's via Terraform.  The information below is meant to be added to the
 * existing file but is separated for learning purposes.
 * 
 */

#  "Resource" section for "ddcloud_server" which defines how Terraform builds infrastructure assets.
#  This resource creates VM's within the network domain and network VLAN's previously created.

resource "ddcloud_server" "webapp-server" {
  name                 = "WEBAPP SERVER"
  admin_password       = "password"
  memory_gb            = 4
  cpu_count            = 2
  networkdomain        = "${ddcloud_networkdomain.networkdomain.id}"
  primary_adapter_ipv4 = "192.168.1.11"
  dns_primary          = "8.8.8.8"
  dns_secondary        = "8.8.4.4"
  os_image_name        = "CentOS 7 64-bit 2 CPU"

  disk {
    scsi_unit_id       = 0
    size_gb            = 10
  }

  auto_start = "FALSE"
  depends_on           = ["ddcloud_vlan.dmz-vlan"]
}

resource "ddcloud_server" "db-server" {
  name                 = "DB SERVER"
  admin_password       = "password"
  memory_gb            = 4
  cpu_count            = 2
  networkdomain        = "${ddcloud_networkdomain.networkdomain.id}"
  primary_adapter_ipv4 = "192.168.2.11"
  dns_primary          = "8.8.8.8"
  dns_secondary        = "8.8.4.4"
  os_image_name        = "CentOS 7 64-bit 2 CPU"

  disk {
    scsi_unit_id       = 0
    size_gb            = 10
  }

  auto_start = "FALSE"
  depends_on           = ["ddcloud_vlan.trust-vlan"]
}

#  "Resource" Section Notes:
#  
#  1.  Each section for cpu_count, memory_gb, dns_primary, admin_password and others all refer to 
#      variables that are explicitly assigned.  Depending on the value, if no value is specified, 
#      the template default will be used.
#  2.  The os_image_name field references the common name of the VM template in the cloud available
#      in the data center location the code is executing against for a VM to be instantiated from.
#  3.  The primary_adapter_ipv4 field is specified based on the VLAN network range created in the 
#      vlan.tf example
#  4.  The depends_on field sets a dependency on the network VLAN being crated BEFORE executing
#      the resources defined here for VM creation.
#  5.  If nothing is changes, the resource definition will create (2) VM's one in each network VLAN
#      with the following definitions:
#
#      + ddcloud_server.db-server
#          admin_password:              "<sensitive>"
#          auto_start:                  "false"
#          cpu_count:                   "2"
#          customer_image_id:           "<computed>"
#          customer_image_name:         "<computed>"
#          disk.#:                      "1"
#          disk.219226128.disk_id:      "<computed>"
#          disk.219226128.scsi_unit_id: "0"
#          disk.219226128.size_gb:      "10"
#          disk.219226128.speed:        "STANDARD"
#          dns_primary:                 "8.8.8.8"
#          dns_secondary:               "8.8.4.4"
#          memory_gb:                   "4"
#          name:                        "DB SERVER"
#          networkdomain:               "0d899624-3fa7-4a24-80de-18f4ea36a792"
#          os_image_id:                 "<computed>"
#          os_image_name:               "CentOS 7 64-bit 2 CPU"
#          primary_adapter_ipv4:        "192.168.2.11"
#          primary_adapter_ipv6:        "<computed>"
#          primary_adapter_vlan:        "<computed>"
#          public_ipv4:                 "<computed>"
#      
#      + ddcloud_server.webapp-server
#          admin_password:              "<sensitive>"
#          auto_start:                  "false"
#          cpu_count:                   "2"
#          customer_image_id:           "<computed>"
#          customer_image_name:         "<computed>"
#          disk.#:                      "1"
#          disk.219226128.disk_id:      "<computed>"
#          disk.219226128.scsi_unit_id: "0"
#          disk.219226128.size_gb:      "10"
#          disk.219226128.speed:        "STANDARD"
#          dns_primary:                 "8.8.8.8"
#          dns_secondary:               "8.8.4.4"
#          memory_gb:                   "4"
#          name:                        "WEBAPP SERVER"
#          networkdomain:               "0d899624-3fa7-4a24-80de-18f4ea36a792"
#          os_image_id:                 "<computed>"
#          os_image_name:               "CentOS 7 64-bit 2 CPU"
#          primary_adapter_ipv4:        "192.168.1.11"
#          primary_adapter_ipv6:        "<computed>"
#          primary_adapter_vlan:        "<computed>"
#          public_ipv4:                 "<computed>"
#
#  6.  For more information on resource usage, please go to the URL - https://goo.gl/NFLGGe
