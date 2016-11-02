/*
 * The section below build on the configuration files in vlan.tf and includes resource
 * definitions to create firewall address lists via Terraform.  The information below is 
 * meant to be added to the existing file but is separated for learning purposes.
 * 
 */

#  "Resource" section for "ddcloud_address_list" which defines how Terraform builds 
#  infrastructure assets.  This resource creates firewall address lists to augment large
#  firewall definitions by referencing a variable that encapsulates a larger group of
#  object.  In this case, IP addresses whether singular or multiples.

resource "ddcloud_address_list" "dmz-list" {
  name                 = "DMZ_Address_List"
  ip_version           = "IPv4"

  address {
    network            = "192.168.1.0"
	prefix_size        = 24
  }
  
  networkdomain        = "${ddcloud_networkdomain.networkdomain.id}"
  depends_on           = ["ddcloud_networkdomain.networkdomain"]
}

resource "ddcloud_address_list" "trust-list" {
  name                 = "TRUST_Address_List"
  ip_version           = "IPv4"

  address {
    network            = "192.168.2.0"
	prefix_size        = 24
  }
  
  networkdomain        = "${ddcloud_networkdomain.networkdomain.id}"
  depends_on           = ["ddcloud_networkdomain.networkdomain"]
}

resource "ddcloud_address_list" "utility-list" {
  name                 = "UTILITY_Address_List"
  ip_version           = "IPv4"

  address {
    network            = "192.168.0.0"
	prefix_size        = 24
  }
  
  networkdomain        = "${ddcloud_networkdomain.networkdomain.id}"
  depends_on           = ["ddcloud_networkdomain.networkdomain"]
}

resource "ddcloud_address_list" "prod-list" {
  name                 = "PROD_Address_List"
  ip_version           = "IPv4"
  
  child_lists          = [
    "${ddcloud_address_list.dmz-list.id}",
    "${ddcloud_address_list.trust-list.id}",
  ]

  networkdomain        = "${ddcloud_networkdomain.networkdomain.id}"
  depends_on           = ["ddcloud_networkdomain.networkdomain"]
}

#  "Resource" Section Notes:
#  
#  1.  The code defines individual address lists to be used as aliases for firewall rules
#  2.  The depends_on field is set to the networkdomain being present as that is required
#      before any firewall address lists can be created
#  3.  If nothing is changes, the resource definition will create (3) firewall address lists 
#      and (1) nested address list with the following definitions:
#
#      
#      + ddcloud_address_list.prod-list
#          child_lists.#: "2"
#          child_lists.0: "01ec9196-7c1d-44f5-bc66-b80bb97f7190"
#          child_lists.1: "d3a73729-d87f-4f6d-bf67-3d7b0c0bb52c"
#          ip_version:    "IPv4"
#          name:          "PROD_Address_List"
#          networkdomain: "9c4033c9-3c2c-4ea0-bf20-52929c74140c"
#      
#  4.  For more information on resource usage, please go to the URL - https://goo.gl/sPoRcm