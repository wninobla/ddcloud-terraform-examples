/*
 * The section below build on the configuration files in vlan.tf and includes resource
 * definitions to create NAT rules against existing VM's via Terraform.  The information below is 
 * meant to be added to the existing file but is separated for learning purposes.
 * 
 */

#  "Resource" section for "ddcloud_nat" which defines how Terraform builds infrastructure assets.
#  This resource creates NAT rules against VM's within the network domain and network VLAN's 
#  previously created.

resource "ddcloud_nat" "nat" {
  networkdomain       = "${ddcloud_networkdomain.networkdomain.id}"
  private_ipv4        = "${ddcloud_server.webapp-server.primary_adapter_ipv4}"
  depends_on          = ["ddcloud_vlan.dmz-vlan"]
}

#  "Resource" Section Notes:
#  
#  1.  The private_ipv4 field uses a variable to call the current value of the resource previously
#      created in the server.tf file.  Please note that since (2) servers were created, the syntax
#      references an explicit resource name (i.e. ddcloud_server.webapp-server)
#  2.  The depends_on field sets a dependency on the network VLAN being created BEFORE executing
#      the resources defined here for NAT rule creation.
#  3.  If nothing is changes, the resource definition will create a NAT rule one in the DMZ network
#      VLAN with the following definitions:
#
#      + ddcloud_nat.nat
#          networkdomain: "0d899624-3fa7-4a24-80de-18f4ea36a792"
#          private_ipv4:  "192.168.1.11"
#          public_ipv4:   "<computed>"
#
#  4.  For more information on resource usage, please go to the URL - https://goo.gl/BsGjrv
