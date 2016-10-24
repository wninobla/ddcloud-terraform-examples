/*
 * The section below build on the configuration files in server.tf and includes resource
 * definitions to create additional VM NICs via Terraform.  The information below is meant
 *  to be added to the existing file but is separated for learning purposes.
 * 
 */

#  "Resource" section for "ddcloud_server_nic" which defines how Terraform builds infrastructure
#  assets.  This resource creates VM NIC's on existing assets.

resource "ddcloud_server_nic" "webapp-server" {
  server               = "${ddcloud_server.webapp-server.id}"
  private_ipv4         = "192.168.0.11"
  vlan                 = "${ddcloud_vlan.utility-vlan.id}"
  depends_on           = ["ddcloud_server.webapp-server"]
}

resource "ddcloud_server_nic" "db-server" {
  server               = "${ddcloud_server.db-server.id}"
  private_ipv4         = "192.168.0.12"
  vlan                 = "${ddcloud_vlan.utility-vlan.id}"
  depends_on           = ["ddcloud_server.db-server"]
}

#  "Resource" Section Notes:
#  
#  1.  Values for section pulled from previous examples namely server.tf and vlan.tf
#  2.  The depends_on field sets a dependency on the server being crated BEFORE executing
#      the resources defined here for adding a VM NIC.
#  3   Do note that adding a NIC requires that the network VLAN configured be unique on the
#      VM.  In other works, you cannot have a VM with (2) NIC's on the SAME network VLAN
#  4.  If nothing is changes, the resource definition will create (1) NIC per VM one in each 
#      network VLAN with the following definitions:
#
#      + ddcloud_server_nic.db-server
#          private_ipv4: "192.168.0.12"
#          private_ipv6: "<computed>"
#          server:       "b5f99711-8f46-4cec-b2c0-5361075f5f2b"
#          vlan:         "cd1e9af8-7062-466b-992e-e40a681f22c3"
#      
#      + ddcloud_server_nic.webapp-server
#          private_ipv4: "192.168.0.11"
#          private_ipv6: "<computed>"
#          server:       "6e1f29cf-08ad-4b62-b2b6-77b4802bf33a"
#          vlan:         "cd1e9af8-7062-466b-992e-e40a681f22c3"
#      
#  5.  For more information on resource usage, please go to the URL - https://goo.gl/3sx1O8