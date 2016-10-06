/*
 * The section below build on the configuration files in server.tf and includes resource
 * definitions to create server anti affinity rules against existing VM's via Terraform.  
 * The information below is meant to be added to the existing file but is separated for 
 * learning purposes.
 * 
 */
 
#  "Resource" section for "ddcloud_server_anti_affinity" which defines how Terraform builds 
#  infrastructure assets.  This resource creates server rules against VM's within the network
#  domain and network VLAN's previously created.  It specifically tries to physically separate
#  each VM from each other in a 1:1 relationship by starting them on different physical ESXi
#  servers in the virtualization stack.

resource "ddcloud_server_anti_affinity" "server_anti_affinity" {
  server1             = "${ddcloud_server.webapp-server.id}"
  server2             = "${ddcloud_server.db-server.id}"
  depends_on          = ["ddcloud_server.db-server"]
}

#  "Resource" Section Notes:
#  
#  1.  The server1 and server2 fields use the resource "ddcloud_server" id's on the VM's created
#      as variables for input.
#  2.  Typically, you separate functional server roles with this feature.  However, since the
#      examples make use of only (1) web and (1) db server these VM's are chosen for use.
#  3.  If nothing is changes, the resource definition will create a NAT rule one in the DMZ network
#      VLAN with the following definitions:
#
#      + ddcloud_server_anti_affinity.server_anti_affinity
#          networkdomain: "<computed>"
#          server1:       "1cbb8bcb-0969-4cea-891a-2b09352d80d0"
#          server1_name:  "<computed>"
#          server2:       "1b15ecfa-3bc5-4e87-8cce-965600e63b21"
#          server2_name:  "<computed>"
#      
#  4.  For more information on resource usage, please go to the URL - https://goo.gl/G7lLHW