/*
 * The section below build on the configuration files in vlan.tf and includes resource
 * definitions to create firewall ACL rules via Terraform.  The information below is 
 * meant to be added to the existing file but is separated for learning purposes.
 * 
 */

#  "Resource" section for "ddcloud_firewall_rule" which defines how Terraform builds 
#  infrastructure assets.  This resource creates firewall ACL rules against VM's within  
#  the network domain and network VLAN's previously created.  It is not required that
#  any VM's exist nor any network VLAN's.  But, the usefulness for these rules existing 
#  is dependent on assets to allow or deny network traffic to(or from).

resource "ddcloud_firewall_rule" "firewall-rule-001" {
  name                = "rdp.inbound"
  placement           = "first"
  action              = "accept"
  enabled             = true
  ip_version          = "ipv4"
  protocol            = "tcp"
  destination_address = "${ddcloud_nat.nat.public_ipv4}"
  destination_port    = "22"
  networkdomain       = "${ddcloud_networkdomain.networkdomain.id}"
}

resource "ddcloud_firewall_rule" "firewall-rule-002" {
  name                = "sql.inbound"
  placement           = "last"
  action              = "accept"
  enabled             = true
  ip_version          = "ipv4"
  protocol            = "tcp"
  source_network      = "192.168.1.0/24"
  destination_address = "${ddcloud_virtual_listener.virtual-listener.ipv4}"
  destination_port    = "1433"
  networkdomain       = "${ddcloud_networkdomain.networkdomain.id}"
  depends_on          = ["ddcloud_virtual_listener.virtual-listener"]
}

resource "ddcloud_firewall_rule" "firewall-rule-003" {
  name                     = "web.inbound"
  placement                = "last"
  action                   = "accept"
  enabled                  = true
  ip_version               = "ipv4"
  protocol                 = "tcp"
  destination_address      = "${ddcloud_nat.nat.public_ipv4}"
  destination_port_list    = "${ddcloud_port_list.web-services-list.id}"
  networkdomain            = "${ddcloud_networkdomain.networkdomain.id}"
  depends_on               = ["ddcloud_virtual_listener.virtual-listener"]
}

resource "ddcloud_firewall_rule" "firewall-rule-004" {
  name                     = "mgmt.inbound"
  placement                = "last"
  action                   = "accept"
  enabled                  = true
  ip_version               = "ipv4"
  protocol                 = "tcp"
#  source_address_list      = "${ddcloud_address_list.utility-list.id}" 
  destination_address_list = "${ddcloud_address_list.prod-list.id}"
  destination_port         = "3389" 
  networkdomain            = "${ddcloud_networkdomain.networkdomain.id}"
  depends_on               = ["ddcloud_virtual_listener.virtual-listener"]
}

#  "Resource" Section Notes:
#  
#  1.  Several fields comprise the creation of a firewall ACL rule.  Please refer to 
#      documentation at the URL - https://goo.gl/qKmzPA
#  2.  The depends_on field sets a dependency on the network domain and virtual listener.
#      However, this technically is not required depending on the resource configuration 
#      and the rules being defined.
#  3.  If nothing is changes, the resource definition will create a NAT rule one in the DMZ network
#      VLAN with the following definitions:
#
#      + ddcloud_firewall_rule.firewall-rule-001
#          action:              "ACCEPT_DECISIVELY"
#          destination_address: "168.128.29.214"
#          destination_port:    "22"
#          enabled:             "true"
#          ip_version:          "ipv4"
#          name:                "rdp.inbound"
#          networkdomain:       "0d899624-3fa7-4a24-80de-18f4ea36a792"
#          placement:           "first"
#          protocol:            "tcp"
#      
#      + ddcloud_firewall_rule.firewall-rule-002
#          action:              "ACCEPT_DECISIVELY"
#          destination_address: "192.168.3.11"
#          destination_port:    "1433"
#          enabled:             "true"
#          ip_version:          "ipv4"
#          name:                "sql.inbound"
#          networkdomain:       "0d899624-3fa7-4a24-80de-18f4ea36a792"
#          placement:           "last"
#          protocol:            "tcp"
#          source_network:      "192.168.1.0/24"
#      
#      + ddcloud_firewall_rule.firewall-rule-003
#          action:                "ACCEPT_DECISIVELY"
#          destination_address:   "168.128.29.36"
#          destination_port_list: "fac20a25-9ef1-42d0-a728-1ed959e59cf7"
#          enabled:               "true"
#          ip_version:            "ipv4"
#          name:                  "web.inbound"
#          networkdomain:         "9c4033c9-3c2c-4ea0-bf20-52929c74140c"
#          placement:             "last"
#          protocol:              "tcp"
#      
#  4.  For more information on resource usage, please go to the URL - https://goo.gl/BsGjrv