/*
 * The section below build on the configuration files in server.tf and includes resource
 * definitions to create a virtual listener against existing VM's via Terraform.  The 
 * information below is meant to be added to the existing file but is separated for 
 * learning purposes.
 * 
 */
 
#  "Resource" sections below cover (4) independent resourcess that (3) of which (i.e. 
#  "ddcloud_vip_node", "ddcloud_vip_pool", and "ddcloud_vip_pool_member") are used 
#  for input into "ddcloud_virtual_listener" which defines how Terraform builds
#  infrastructure assets.  This resource creates a virtual listener complete with node
#  assignments and a server pool to place existing VM's within the network domain and  
#  network VLAN's previously created.  It is assumed that the network domain is set to
#  ADVANCED to allow load balancer components to be used.

resource "ddcloud_vip_node" "vip-node" {
  name                = "dbnode_01"
  description         = "DB Server assigned to act as a load balanced node"
  networkdomain       = "${ddcloud_networkdomain.networkdomain.id}"
  ipv4_address        = "${ddcloud_server.db-server.primary_adapter_ipv4}"
  status              = "ENABLED"
  depends_on          = ["ddcloud_server.db-server"]
}

resource "ddcloud_vip_pool" "vip-pool" {
  name                    = "www_pool"
  description             = "Test pool for providing WWW services"
  load_balance_method     = "ROUND_ROBIN"
  service_down_action     = "NONE",
  slow_ramp_time          = 5,
  networkdomain           = "${ddcloud_networkdomain.networkdomain.id}"
  depends_on              = ["ddcloud_vip_node.vip-node"]
}

resource "ddcloud_vip_pool_member" "pool_member" {
  pool              = "${ddcloud_vip_pool.vip-pool.id}"
  node              = "${ddcloud_vip_node.vip-node.id}"
  port              = 80
  status            = "ENABLED"
  depends_on        = ["ddcloud_vip_pool.vip-pool"]
}

resource "ddcloud_virtual_listener" "virtual-listener" {
  name                    = "www_virtual_listener"
  protocol                = "HTTP"
  optimization_profiles   = ["TCP"]
  ipv4                    = "192.168.3.11"
  pool                    = "${ddcloud_vip_pool.vip-pool.id}"
  networkdomain           = "${ddcloud_networkdomain.networkdomain.id}"
  depends_on              = ["ddcloud_vip_pool.vip-pool"]
}


#  "Resource" Section Notes:
#  
#  1.  There are (4) resource sections which uses the depends_on field in order to ensure the
#      previous resource is created before the next resource in the configuration.
#  2.  The ipv4_address field in "ddcloud_vip_node" uses a variable from the server.tf file to
#      refer to the internal private IP address assigned to the web server.
#  3.  The "ddcloud_vip_pool" sets default values for how the load balancer will treat nodes
#      assigned to it.  More documentation on these options and what they do can be found at
#      the URL - https://goo.gl/8EOTgU
#  4.  The pool and node options in "ddcloud_vip_pool_member_ use the previously ran resources
#      above it and grabs the assigned id for each asset as variables.  This is the reason why
#      a depends_on attribute is set to ensure the infrastructure is built so the id field can
#      be pulled.
#  5.  The "ddcloud_virtual_listener" sets fields for how the load balancer will treat traffic
#      ingress into the assigned IP address to the pool of nodes associated with the same.  For
#      more information on these options go to the URL - https://goo.gl/xXVpyI
#  6.  The ipv4 field in "ddcloud_virtual_listener" is worth noting that it references a private
#      IP address from a range that IS NOT in use.  This is a feature set that is allowed for 
#      internally defined virtual listeners assigned within the network domain and network VLAN's
#      in Dimension Data's cloud.
#  3.  If nothing is changed, the resource definition will assign a VM as a node, place that node
#      as a member into a pool which then gets assigned to a virtual listener.  This all looks
#      like the following definitions:
#
#      + ddcloud_vip_node.vip-node
#          connection_limit:      "20000"
#          connection_rate_limit: "2000"
#          description:           "DB Server assigned to act as a load balanced node"
#          ipv4_address:          "192.168.2.11"
#          name:                  "dbnode_01"
#          networkdomain:         "0d899624-3fa7-4a24-80de-18f4ea36a792"
#          status:                "ENABLED"
#      
#      + ddcloud_vip_pool.vip-pool
#          description:         "Test pool for providing WWW services"
#          load_balance_method: "ROUND_ROBIN"
#          name:                "www_pool"
#          networkdomain:       "0d899624-3fa7-4a24-80de-18f4ea36a792"
#          service_down_action: "NONE"
#          slow_ramp_time:      "5"
#      
#      + ddcloud_vip_pool_member.pool_member
#          node:      "${ddcloud_vip_node.vip-node.id}"
#          node_name: "<computed>"
#          pool:      "${ddcloud_vip_pool.vip-pool.id}"
#          pool_name: "<computed>"
#          port:      "80"
#          status:    "ENABLED"
#      
#      + ddcloud_virtual_listener.virtual-listener
#          connection_limit:                "20000"
#          connection_rate_limit:           "2000"
#          enabled:                         "true"
#          ipv4:                            "192.168.3.11"
#          name:                            "www_virtual_listener"
#          networkdomain:                   "0d899624-3fa7-4a24-80de-18f4ea36a792"
#          optimization_profiles.#:         "1"
#          optimization_profiles.617288268: "TCP"
#          pool:                            "${ddcloud_vip_pool.vip-pool.id}"
#          port:                            "0"
#          protocol:                        "HTTP"
#          source_port_preservation:        "PRESERVE"
#          type:                            "STANDARD"
#      
#  4.  For more information on resource usage, please go to the URL below for:
#
#        ddcloud_vip_node - https://goo.gl/wxDWPx
#        ddcloud_vip_pool - https://goo.gl/E8wkDh
#        ddcloud_vip_pool_member - https://goo.gl/5MHP8F
#        ddcloud_virtual_listener - https://goo.gl/OhiAzM