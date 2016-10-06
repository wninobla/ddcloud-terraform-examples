/*
 * This file represents a consolidated view of all the assets created from the previous examples.
 * Do note that you can keep these separate or consolidate them into a single view.  How things
 * are defined is up to the end user and how they work towards :
 *
 *   1.  Initially defining the infrastructure AND
 *   2.  How the infrastructure will handule updates both incrementally and as a whole
 *
 * All comments have been removed from the examples below to show a clean view of the same content
 * as it would potentially appear for production use.
 */

provider "ddcloud" {
  "username"           = "ENTER USERNAME HERE"
  "password"           = "ENTER PASSWORD HERE"
  "region"             = "ENTER REGION CODE HERE"
}

resource "ddcloud_networkdomain" "networkdomain" {
  name                 = "Test Network Domain"
  description          = "New network domain created via Terraform"
  datacenter           = "NA12"
plan = "ADVANCED"
}

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

resource "ddcloud_nat" "nat" {
  networkdomain       = "${ddcloud_networkdomain.networkdomain.id}"
  private_ipv4        = "${ddcloud_server.webapp-server.primary_adapter_ipv4}"
  depends_on          = ["ddcloud_vlan.dmz-vlan"]
}

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

resource "ddcloud_server_anti_affinity" "server_anti_affinity" {
  server1             = "${ddcloud_server.webapp-server.id}"
  server2             = "${ddcloud_server.db-server.id}"
  depends_on          = ["ddcloud_server.db-server"]
}