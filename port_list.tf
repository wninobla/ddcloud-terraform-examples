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

resource "ddcloud_port_list" "http-list" {
  name                 = "HTTP_Port_List"
  description          = "Port for non-encrypted HTTP traffic"

  port {
    begin              = 80
  }
  
  networkdomain        = "${ddcloud_networkdomain.networkdomain.id}"
  depends_on           = ["ddcloud_networkdomain.networkdomain"]
}

resource "ddcloud_port_list" "http-alt-list" {
  name                 = "HTTP_Alternate_Port_List"
  description          = "Port for non-encrypted HTTP traffic internally for Apache Tomcat"

  port {
    begin              = 8080
  }
  
  networkdomain        = "${ddcloud_networkdomain.networkdomain.id}"
  depends_on           = ["ddcloud_networkdomain.networkdomain"]
}

resource "ddcloud_port_list" "https-list" {
  name                 = "HTTPS_Port_List"
  description          = "Port for encrypted HTTP traffic"

  port {
    begin              = 443
  }
  
  networkdomain        = "${ddcloud_networkdomain.networkdomain.id}"
  depends_on           = ["ddcloud_networkdomain.networkdomain"]
}

resource "ddcloud_port_list" "web-services-list" {
  name                 = "WEB_Services_List"
  description          = "Port group for all HTTP/HTTPS traffic"
  
  child_lists          = [
    "${ddcloud_port_list.https-list.id}",
    "${ddcloud_port_list.http-alt-list.id}",
    "${ddcloud_port_list.http-list.id}",
  ]

  networkdomain        = "${ddcloud_networkdomain.networkdomain.id}"
  depends_on           = ["ddcloud_networkdomain.networkdomain"]
}

#  "Resource" Section Notes:
#  
#  1.  The code defines individual port lists to be used as aliases for firewall rules
#  2.  The depends_on field is set to the networkdomain being present as that is required
#      before any firewall address lists can be created
#  3.  If nothing is changes, the resource definition will create (3) firewall port lists 
#      and (1) nested port list with the following definitions:
#
#      + ddcloud_port_list.web-services-list
#          child_lists.#: "3"
#          child_lists.0: "274bad7f-9031-42c8-b349-2982a7b56182"
#          child_lists.1: "d7de85ac-3f6a-4633-8198-e24fd67a9293"
#          child_lists.2: "e395809e-0232-406b-9a95-e3b8459559db"
#          description:   "Port group for all HTTP/HTTPS traffic"
#          name:          "WEB_Services_List"
#          networkdomain: "9c4033c9-3c2c-4ea0-bf20-52929c74140c"
#      
#  4.  For more information on resource usage, please go to the URL - https://goo.gl/sPoRcm
