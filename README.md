# ddcloud-terraform-examples
Terraform configuration files with comments to help walk new users through writing their own infrastructure definitions for automation

This repository holds several individual examples of how to utilize Terraform in conjunction with the Dimension Data Cloud.  All examples are as-is and will incur realtime charges if used with valid credentials.  Be sure you read and understand the examples before applying them in any test to production scenario.

The files included in this bundle are meant to build upon each other culminating into a fully realized deployment configuration file.  The files are referenced below:

- create_networkdomain
- create_vlan
- create_server
- create_nat
- create_vip
- create_firewall_acl
- create_infrastructure

To get started using the files, you will require the following:

1)  Valid Dimension Data cloud account
2)  Terraform binaries from where you expect to execute scripts from (https://www.terraform.io/downloads.html)
3)  Dimension Data Terraform plugin (https://github.com/DimensionDataResearch/dd-cloud-compute-terraform)
4)  Some spare time to read the example files...

When running Terraform, its important to note that its meant to spin up ENTIRE infrastructures in a single shot.  Any modifications whether adding, modifying a configuration or detroying parts of or an entire infrastructure are done AFTER an initial rollout is performed.  For more information on how to utilize Terraform, please visit their website documentation at:

https://www.terraform.io/docs/index.html

