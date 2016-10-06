/*
 * This configuration will create the following demo infrastructure for an end user given variables set in the script:
 *
 *   -  A default network domain assigned as Advanced
 *   -  (3) VLANs Called DMZ Network, TRUST Network, and Utility Network
 *   -  (4) Web and (4) App servers in the DMZ Network and (2) Database servers in the TRUST Network and (1) Utility 
 *      Server in the Utility Netork
 *   -  Configure a NAT rule assigned to the Utility server and opening 3389 from the Internet inbound to the server
 *   -  Load Balancing configuration for (2) Web Servers in Round Robin pool under port 80 (Pending)
 *   -  Server aniti-affinity for each group of servers (e.g. web, app and db) 
 * 
 * To use this script, a user generally just needs to edit the variables in top half of the script.  If there are some
 * modifications to the areas below, you may need to add additional resource configurations as necessary.  For instance,
 * you may want to change the firewall ACL rule that allows access into an environment.  Or, you may want to edit a node
 * or pool and mark hosts up or down.
 *
 */

#  Set variables related to network deployment
variable "networkdomain" {
  default = {
    "name"             = "Test network domain"
	"description"      = "This is a test network domain via Terraform automation"
	"datacenter"       = "NA12"
	"plan"             = "ADVANCED"
  }
}

variable "vlan_count" {
  default = 3
}

variable "vlan_name" {
  default = {
    "0"                = "DMZ network test"
	"1"                = "TRUST network test"
	"2"                = "Utility network test"
  }
}

variable "vlan_name_dependson" {
  default = {
    "0"                = "ddcloud_vlan.vlan.0"
	"1"                = "ddcloud_vlan.vlan.1"
	"2"                = "ddcloud_vlan.vlan.2"
  }
}

variable "vlan_description" {
  default = {
    "0"                = "Autogenerated via terraform network for web and app VM's"
	"1"                = "Autogenerated via terraform network for database VM's"
	"2"                = "Autogenerated via terraform network for utility VM's"
  }
}

variable "ipv4_base_address" {
  default = {
    "0"                = "192.168.0.0"
	"1"                = "192.168.2.0"
	"2"                = "192.168.4.0"
  }
}

variable "ipv4_prefix_size" {
  default = 23
}

variable "webserver_count" {
  default = 4
}

variable "webserver_name" {
  default = {
    "0"                = "WEB01"
	"1"                = "WEB02"
	"2"                = "WEB03"
	"3"                = "WEB04"
  }
}

variable "webserver_ip" {
  default = {
    "0"                = "192.168.0.101"
	"1"                = "192.168.0.102"
	"2"                = "192.168.0.103"
	"3"                = "192.168.0.104"
  }
}

variable "webserver_password" {
  default = "password"
}

variable "webserver_resources" {
  default = {
    "cpu_count"        = 2
	"memory_gb"        = 2
	"dns_primary"      = "8.8.8.8"
	"dns_secondary"    = "8.8.4.4"
    "os_image_name"    = "CentOS 7 64-bit 2 CPU"
    "scsi_unit_id"     = 0
    "size_gb"          = 10
    "tagname"          = "Application"
	"tagvalue"          = "Web"
  }
}

variable "appserver_count" {
  default = 4
}

variable "appserver_name" {
  default = {
    "0"                = "APP01"
	"1"                = "APP02"
	"2"                = "APP03"
	"3"                = "APP04"
  }
}

variable "appserver_ip" {
  default = {
    "0"                = "192.168.0.201"
	"1"                = "192.168.0.202"
	"2"                = "192.168.0.203"
	"3"                = "192.168.0.204"
  }
}

variable "appserver_password" {
  default = "password2"
}

variable "appserver_resources" {
  default = {
    "cpu_count"        = 2
	"memory_gb"        = 2
	"dns_primary"      = "8.8.8.8"
	"dns_secondary"    = "8.8.4.4"
    "os_image_name"    = "CentOS 7 64-bit 2 CPU"
    "scsi_unit_id"     = 0
    "size_gb"          = 10
    "tagname"          = "Application"
	"tagvalue"          = "App"
  }
}

variable "dbserver_count" {
  default = 2
}

variable "dbserver_name" {
  default = {
    "0"                = "DB01"
	"1"                = "DB02"
  }
}

variable "dbserver_ip" {
  default = {
    "0"                = "192.168.2.101"
	"1"                = "192.168.2.102"
  }
}

variable "dbserver_password" {
  default = "password3"
}

variable "dbserver_resources" {
  default = {
    "cpu_count"        = 2
	"memory_gb"        = 2
	"dns_primary"      = "8.8.8.8"
	"dns_secondary"    = "8.8.4.4"
    "os_image_name"    = "CentOS 7 64-bit 2 CPU"
    "scsi_unit_id"     = 0
    "size_gb"          = 10
    "tagname"          = "Application"
	"tagvalue"         = "Database"
  }
}

variable "utilserver_count" {
  default = 1
}

variable "utilserver_name" {
  default = {
    "0"                = "UTIL01"
  }
}

variable "utilserver_ip" {
  default = {
    "0"                = "192.168.4.101"
  }
}

variable "utilserver_password" {
  default = "password4"
}

variable "utilserver_resources" {
  default = {
    "cpu_count"        = 2
	"memory_gb"        = 2
	"dns_primary"      = "8.8.8.8"
	"dns_secondary"    = "8.8.4.4"
    "os_image_name"    = "CentOS 7 64-bit 2 CPU"
    "scsi_unit_id"     = 0
    "size_gb"          = 10
    "tagname"          = "Application"
	"tagvalue"         = "Utility"
  }
}


#  Begin actual terraform resource creation of infrastructure components

#  Set provider login information into the Dimension Data cloud API.  User name and password can also be specified via
#  DD_COMPUTE_USER and DD_COMPUTE_PASSWORD environment variables within the linux shell.

provider "ddcloud" {
  "username"           = "clouddemo_api"
  "password"           = "79r63aSQN_Q1"
  "region"             = "NA"
}

#  Creation of network domain to house all end user defined VLAN(s)

resource "ddcloud_networkdomain" "domain" {
  name                 = "${var.networkdomain["name"]}"
  description          = "${var.networkdomain["description"]}"
  datacenter           = "${var.networkdomain["datacenter"]}"
  plan                 = "${var.networkdomain["plan"]}"
}

# Creation of web server resources to go into the DMZ VLAN

resource "ddcloud_vlan" "vlan" {
  count                = "${var.vlan_count}"
  name                 = "${lookup(var.vlan_name,count.index)}"
  description          = "${lookup(var.vlan_description,count.index)}"
  networkdomain        = "${ddcloud_networkdomain.domain.id}"
  ipv4_base_address    = "${lookup(var.ipv4_base_address,count.index)}"
  ipv4_prefix_size     = "${var.ipv4_prefix_size}"
  depends_on           = ["ddcloud_networkdomain.domain"]
}

resource "ddcloud_server" "webserver" {
  count                = "${var.webserver_count}"
  name                 = "${lookup(var.webserver_name,count.index)}"
  admin_password       = "${var.webserver_password}"
  memory_gb            = "${var.webserver_resources["memory_gb"]}"
  cpu_count            = "${var.webserver_resources["cpu_count"]}"
  networkdomain        = "${ddcloud_networkdomain.domain.id}"
  primary_adapter_ipv4 = "${lookup(var.webserver_ip,count.index)}"
  dns_primary          = "${var.webserver_resources["dns_primary"]}"
  dns_secondary        = "${var.webserver_resources["dns_secondary"]}"
  os_image_name        = "${var.webserver_resources["os_image_name"]}"

  disk {
    scsi_unit_id       = "${var.webserver_resources["scsi_unit_id"]}"
    size_gb            = "${var.webserver_resources["size_gb"]}"
  }

  tag {
    name               = "${var.webserver_resources["tagname"]}"
    value              = "${var.webserver_resources["tagvalue"]}"
  }

  auto_start = "TRUE"
  depends_on           = ["ddcloud_vlan.vlan"]  # Add .0 since each resource created with count gets appended with the variable as aprt of the name?
}

resource "ddcloud_server" "appserver" {
  count                = "${var.appserver_count}"
  name                 = "${lookup(var.appserver_name,count.index)}"
  admin_password       = "${var.appserver_password}"
  memory_gb            = "${var.appserver_resources["memory_gb"]}"
  cpu_count            = "${var.appserver_resources["cpu_count"]}"
  networkdomain        = "${ddcloud_networkdomain.domain.id}"
  primary_adapter_ipv4 = "${lookup(var.appserver_ip,count.index)}"
  dns_primary          = "${var.appserver_resources["dns_primary"]}"
  dns_secondary        = "${var.appserver_resources["dns_secondary"]}"
  os_image_name        = "${var.appserver_resources["os_image_name"]}"

  disk {
    scsi_unit_id       = "${var.appserver_resources["scsi_unit_id"]}"
    size_gb            = "${var.appserver_resources["size_gb"]}"
  }

  tag {
    name               = "${var.appserver_resources["tagname"]}"
    value              = "${var.appserver_resources["tagvalue"]}"
  }

  auto_start = "TRUE"
  depends_on           = ["ddcloud_vlan.vlan"]
}


resource "ddcloud_server" "dbserver" {
  count                = "${var.dbserver_count}"
  name                 = "${lookup(var.dbserver_name,count.index)}"
  admin_password       = "${var.dbserver_password}"
  memory_gb            = "${var.dbserver_resources["memory_gb"]}"
  cpu_count            = "${var.dbserver_resources["cpu_count"]}"
  networkdomain        = "${ddcloud_networkdomain.domain.id}"
  primary_adapter_ipv4 = "${lookup(var.dbserver_ip,count.index)}"
  dns_primary          = "${var.dbserver_resources["dns_primary"]}"
  dns_secondary        = "${var.dbserver_resources["dns_secondary"]}"
  os_image_name        = "${var.dbserver_resources["os_image_name"]}"

  disk {
    scsi_unit_id       = "${var.dbserver_resources["scsi_unit_id"]}"
    size_gb            = "${var.dbserver_resources["size_gb"]}"
  }

  tag {
    name               = "${var.dbserver_resources["tagname"]}"
    value              = "${var.dbserver_resources["tagvalue"]}"
  }

  auto_start = "TRUE"
  depends_on           = ["ddcloud_vlan.vlan"]
}

resource "ddcloud_server" "utilserver" {
  count                = "${var.utilserver_count}"
  name                 = "${lookup(var.utilserver_name,count.index)}"
  admin_password       = "${var.utilserver_password}"
  memory_gb            = "${var.utilserver_resources["memory_gb"]}"
  cpu_count            = "${var.utilserver_resources["cpu_count"]}"
  networkdomain        = "${ddcloud_networkdomain.domain.id}"
  primary_adapter_ipv4 = "${lookup(var.utilserver_ip,count.index)}"
  dns_primary          = "${var.utilserver_resources["dns_primary"]}"
  dns_secondary        = "${var.utilserver_resources["dns_secondary"]}"
  os_image_name        = "${var.utilserver_resources["os_image_name"]}"

  disk {
    scsi_unit_id       = "${var.utilserver_resources["scsi_unit_id"]}"
    size_gb            = "${var.utilserver_resources["size_gb"]}"
  }

  tag {
    name               = "${var.utilserver_resources["tagname"]}"
    value              = "${var.utilserver_resources["tagvalue"]}"
  }

  auto_start = "TRUE"
  depends_on           = ["ddcloud_vlan.vlan"]
}





resource "ddcloud_server_anti_affinity" "anti_affinity_001" {
  server1             = "${ddcloud_server.webserver.0.id}"
  server2             = "${ddcloud_server.webserver.1.id}"
  depends_on          = ["ddcloud_server.webserver"]
}

resource "ddcloud_server_anti_affinity" "anti_affinity_002" {
  server1             = "${ddcloud_server.webserver.2.id}"
  server2             = "${ddcloud_server.webserver.3.id}"
  depends_on          = ["ddcloud_server.webserver"]
}

resource "ddcloud_server_anti_affinity" "anti_affinity_003" {
  server1             = "${ddcloud_server.appserver.0.id}"
  server2             = "${ddcloud_server.appserver.1.id}"
  depends_on          = ["ddcloud_server.webserver"]
}

resource "ddcloud_server_anti_affinity" "anti_affinity_004" {
  server1             = "${ddcloud_server.appserver.2.id}"
  server2             = "${ddcloud_server.appserver.3.id}"
  depends_on          = ["ddcloud_server.appserver"]
}

resource "ddcloud_server_anti_affinity" "anti_affinity_005" {
  server1             = "${ddcloud_server.dbserver.0.id}"
  server2             = "${ddcloud_server.dbserver.1.id}"
  depends_on          = ["ddcloud_server.dbserver"]
}

resource "ddcloud_nat" "servernat" {
  networkdomain       = "${ddcloud_networkdomain.domain.id}"
  private_ipv4        = "${var.utilserver_ip["0"]}"
  depends_on          = ["ddcloud_vlan.vlan"]
}

resource "ddcloud_vip_node" "node" {
  count               = "${var.webserver_count}"
  name                = "${lookup(var.webserver_name,count.index)}"
  description         = "Web Server assigned to act as a load balanced node"
  networkdomain       = "${ddcloud_networkdomain.domain.id}"
  ipv4_address        = "${lookup(var.webserver_ip,count.index)}"
  status              = "ENABLED"

  depends_on          = ["ddcloud_server.webserver"]
}

resource "ddcloud_vip_pool" "pool" {
  name                = "www_pool"
  description         = "Test pool for providing WWW services"
  load_balance_method = "ROUND_ROBIN"
  service_down_action = "NONE",
  slow_ramp_time      = 5,
  networkdomain       = "${ddcloud_networkdomain.domain.id}"
  depends_on          = ["ddcloud_vip_node.node"]
}

resource "ddcloud_vip_pool_member" "pool_member_001" {
  pool                = "${ddcloud_vip_pool.pool.id}"
  node                = "${ddcloud_vip_node.node.0.id}"
  port                = 80
  status              = "ENABLED"
  depends_on          = ["ddcloud_vip_pool.pool"]
}

resource "ddcloud_vip_pool_member" "pool_member_002" {
  pool                = "${ddcloud_vip_pool.pool.id}"
  node                = "${ddcloud_vip_node.node.1.id}"
  port                = 80
  status              = "ENABLED"
  depends_on          = ["ddcloud_vip_pool_member.pool_member_001"]
}

resource "ddcloud_vip_pool_member" "pool_member_003" {
  pool                = "${ddcloud_vip_pool.pool.id}"
  node                = "${ddcloud_vip_node.node.2.id}"
  port                = 80
  status              = "ENABLED"
  depends_on          = ["ddcloud_vip_pool_member.pool_member_002"]
}

resource "ddcloud_vip_pool_member" "pool_member_004" {
  pool                = "${ddcloud_vip_pool.pool.id}"
  node                = "${ddcloud_vip_node.node.3.id}"
  port                = 80
  status              = "ENABLED"
  depends_on          = ["ddcloud_vip_pool_member.pool_member_003"]
}

resource "ddcloud_virtual_listener" "virtual_listener" {
  name                    = "www_virtual_listener"
  protocol                = "HTTP"
  optimization_profiles   = ["TCP"]
  pool                    = "${ddcloud_vip_pool.pool.id}"
  networkdomain           = "${ddcloud_networkdomain.domain.id}"
  depends_on              = ["ddcloud_vip_pool.pool"]
}

resource "ddcloud_firewall_rule" "dmz-to-trust-mysql" {
  name                = "dmz_to_trust_3306_tcp_intervlan"
  placement           = "first"
  action              = "accept"
  enabled             = true
  ip_version          = "ipv4"
  protocol            = "tcp"
  source_network      = "192.168.0.0/23"
  source_port         = "any"
  destination_network = "192.168.2.0/23"
  destination_port    = "3306"
  networkdomain       = "${ddcloud_networkdomain.domain.id}"
}

resource "ddcloud_firewall_rule" "any-to-util-ssh" {
  name                = "any_to_util_22_tcp_inbound"
  placement           = "first"
  action              = "accept"
  enabled             = false
  ip_version          = "ipv4"
  protocol            = "tcp"
  destination_address = "${ddcloud_nat.servernat.public_ipv4}"
  destination_port    = "22"
  networkdomain       = "${ddcloud_networkdomain.domain.id}"
}

resource "ddcloud_firewall_rule" "any-to-virtual-listener-http" {
  name                = "any_to_virtual_listener_80_tcp_inbound"
  placement           = "first"
  action              = "accept"
  enabled             = true
  ip_version          = "ipv4"
  protocol            = "tcp"
  destination_address = "${ddcloud_virtual_listener.virtual_listener.ipv4}"
  destination_port    = "80"
  networkdomain       = "${ddcloud_networkdomain.domain.id}"
}