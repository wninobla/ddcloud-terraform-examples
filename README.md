# ddcloud-terraform-examples
Terraform configuration files with comments to help walk new users through writing their own infrastructure definitions for automation

This repository holds several individual examples of how to utilize Terraform in conjunction with the Dimension Data Cloud.  All examples are as-is and will incur realtime charges if used with valid credentials.  Be sure you read and understand the examples before applying them in any test to production scenario.

The files included in this bundle are meant to build upon each other culminating into a fully realized deployment configuration file.  The files are referenced below:

- networkdomain.tf
- vlan.tf
- server.tf
- nat.tf
- vip.tf
- firewall_rules.tf
- server_anti_affinity.tf
- infrastructure.tf

To get started using the files, you will require the following:

1.  Valid Dimension Data cloud account
2.  Terraform binaries from where you expect to execute scripts from (https://www.terraform.io/downloads.html)
3.  Dimension Data Terraform plugin (https://github.com/DimensionDataResearch/dd-cloud-compute-terraform)
4.  Copy of the scripts above 
5.  Some spare time to read and understand the example files...

When working with the .tf files above, the content is meant to be created "one file at a time".  In other words, you would:

1.  Create/copy the first file networkdomain.tf into a folder that will house the terraform configuration files
2.  Execute the "terraform plan" and "terraform apply" commands to see what will be created and then accually apply the     
    configurations and creating the same
3.  Move onto the next file vlan.tf and repeat steps 1 and 2 until you get to the last file infrastructure.tf
4.  Run "terraform destroy -force" to tear down the entire build BEFORE executing the "terraform plan" and "terraform apply" 
    commands against the infrastructure.tf file
    
It's important to note that Terraform is meant to spin up ENTIRE infrastructures in a single shot.  Any modifications whether adding, modifying a configuration or detroying parts of or an entire infrastructure are done AFTER an initial rollout is performed.  As such, if one leave the previous .tf files in the same directory as the infrastructure.tf file Terraform will try to execute the content in ALL FILES in the directory in trying to create, modify or delete assets it things it needs to do work against.  This will result in errors for duplicate assets as they are defined more than once and may overlap what work Terraform needs to be done against the same. 

For more information on how to utilize Terraform, please visit their website documentation at:

https://www.terraform.io/docs/index.html

