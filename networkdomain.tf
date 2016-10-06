/*
 * In building any cloud based infrastructure, the same guidelines usually apply in that:
 * 
 *   1.  You need to have access to a cloud provider via some username/password combination AND
 *   2.  Access to a set of automation code that will execute commands to build out a desired 
 *       infrastructure state
 *
 * This configuration file focuses on the base components needed in any Terraform configuration  
 * file in order to build out a base infrastructure.  The following commands are specific to 
 * MCP 2.0 locations.  For more information on which locations run this version, please refer 
 * to the URL - https://goo.gl/iieXMZ
 *
 * The sections below include the following sections needed to connect to the Dimension Data
 * cloud API and to create a network domain which houses all other objects that will be built
 * out via Terraform:
 * 
 */

#  "Provider" section which defines how Terraform connects to Dimension Data's Cloud API to run 
#  commands against it.

provider "ddcloud" {
  "username"           = "ENTER USERNAME HERE"
  "password"           = "ENTER PASSWORD HERE"
  "region"             = "ENTER REGION CODE HERE"
}

#  "Provider" Section Notes:
#  
#  1.  The DD compute region code can be gathered from the cloud UI when you login (e.g. "AU",
#       "NA", "EU").  You can also get the region codes at the URL - https://goo.gl/NQ1JxF
#  2.  The username and password must have the "Networks" role assigned to it.  It is recommended
#      that a dedicated user account be used for API access
#

#  "Resource" section for "ddcloud_networkdomain" which defines how Terraform builds infrastructure
#  assets.  In this case, this resource creates network domains.

resource "ddcloud_networkdomain" "networkdomain" {
  name                 = "ENTER NAME HERE"
  description          = "ENTER DESCRIPTION HERE"
  datacenter           = "NA12"
  plan                 = "ADVANCED"
}

#  "Resource" Section Notes:
#  
#  1.  The DD data center is the physical designation assigned within the API for code to execute
#      against the same.  This can be gathered from the URL - https://goo.gl/iieXMZ
#  2.  If nothing is changes, the resource definition will create a new network domain with the
#      following definitions:
#
#      + ddcloud_networkdomain.networkdomain
#          datacenter:       "NA12"
#          description:      "ENTER DESCRIPTION HERE"
#          name:             "ENTER NAME HERE"
#          nat_ipv4_address: "<computed>"
#          plan:             "ADVANCED"
#
#  3.  The Network Domain Type specifies whether it allows load balancing and server anti-affinity
#      or not.  The plan for ADVANCED allows these features and will be the basis for the next set
#      of configuration files.
#  4.  For more information on resource usage, please go to the URL - https://goo.gl/lrtt3M