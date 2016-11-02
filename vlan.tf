/*
 * The section below build on the configuration files in create_networkdomain and includes resource
 * definitions to create networks via Terraform.  The information below is meant to be added to the
 * existing file but is separated for learning purposes.
 * 
 */

#  "Resource" section for "ddcloud_vlan" which defines how Terraform builds infrastructure assets.
#  This resource creates network VLANs.

resource "ddcloud_vlan" "dmz-vlan" {
  name                 = "DMZ"
  description          = "This is an automated Terraform VLAN designated for DMZ hosts"
  networkdomain        = "${ddcloud_networkdomain.networkdomain.id}"
  ipv4_base_address    = "192.168.1.0"
  ipv4_prefix_size     = 24
  depends_on           = ["ddcloud_networkdomain.networkdomain"]
}

resource "ddcloud_vlan" "trust-vlan" {
  name                 = "TRUST"
  description          = "This is an automated Terraform VLAN designated for TRUST hosts"
  networkdomain        = "${ddcloud_networkdomain.networkdomain.id}"
  ipv4_base_address    = "192.168.2.0"
  ipv4_prefix_size     = 24
  depends_on           = ["ddcloud_networkdomain.networkdomain"]
}

resource "ddcloud_vlan" "utility-vlan" {
  name                 = "UTILITY"
  description          = "This is an automated Terraform VLAN designated for UTILITY hosts"
  networkdomain        = "${ddcloud_networkdomain.networkdomain.id}"
  ipv4_base_address    = "192.168.0.0"
  ipv4_prefix_size     = 24
  depends_on           = ["ddcloud_networkdomain.networkdomain"]
}

#  "Resource" Section Notes:
#  
#  1.  The networkdomain field makes use of Terraform's HCL language and references a variable 
#      for in this case the ID field that the cloud API assigned to the network domain created
#      previously.
#  2.  The ipv4_base_address defines the network block associated with the newtwork VLAN being
#      created.
#  3.  The ipv4_prefix_size defines the CIDR block size being defined.  This has to follow RFC1918
#      guidelines in otder to be valid.
#  4.  The depends_on field sets a dependency on the network domain being crated BEFORE executing
#      the resources defined here for VLAN creation.
#  5.  If nothing is changes, the resource definition will create (3) network VLANs with the
#      following definitions:
#
#      + ddcloud_vlan.dmz-vlan
#          description:       "This is an automated Terraform VLAN designated for DMZ hosts"
#          ipv4_base_address: "192.168.1.0"
#          ipv4_prefix_size:  "24"
#          ipv6_base_address: "<computed>"
#          ipv6_prefix_size:  "<computed>"
#          name:              "DMZ"
#          networkdomain:     "6a0390aa-da05-47dd-a535-17434b8d409b"
#
#      + ddcloud_vlan.trust-vlan
#          description:       "This is an automated Terraform VLAN designated for TRUST hosts"
#          ipv4_base_address: "192.168.2.0"
#          ipv4_prefix_size:  "24"
#          ipv6_base_address: "<computed>"
#          ipv6_prefix_size:  "<computed>"
#          name:              "TRUST"
#          networkdomain:     "6a0390aa-da05-47dd-a535-17434b8d409b"
#      
#      + ddcloud_vlan.utility-vlan
#          description:       "This is an automated Terraform VLAN designated for UTILITY hosts"
#          ipv4_base_address: "192.168.0.0"
#          ipv4_prefix_size:  "24"
#          ipv6_base_address: "<computed>"
#          ipv6_prefix_size:  "<computed>"
#          name:              "UTILITY"
#          networkdomain:     "9c4033c9-3c2c-4ea0-bf20-52929c74140c"
#
#  6.  For more information on resource usage, please go to the URL - https://goo.gl/bax4qD