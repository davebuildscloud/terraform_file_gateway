# Terraform Storage Gateway for File - NFS

## Overview
This project deploys a Storage Gateway environment, including S3 back-end, cache volume, DNS record, security groups, and the necessary IAM policies and roles.
Deploying this project in an AWS account will launch resources that are not free to deploy and use.  Consult the various AWS pricing guides available for the resources included in this project before deploying these resources.

## Disclaimer
The author of this terraform example bears no responsibility for any costs that may arise as a result of using this project.  User of this example code assumes full responsibility for it's use and any results that may come from its deployment.
  
## Usage Instructions
The code in the /example directory should be enough to deploy an AWS storage gateway for file and create an NFS export.  In order to deploy, you'll need the following:

  * Terraform 11.5 or newer installed
  * AWS CLI
  * AWS API Keys allowing you to deploy infrastructure into an AWS account
    * Make sure you have run `aws configure` and provided your API keys during the configuration process
    
You'll need to be able to provide the following details in the /example/test.tf file in order to properly deploy this infrastructure

  * the name of the vpc into which you're deploying the gateway
  * an ssh key in your AWS account that you can define for the EC2 instance creation
  * at least one private subnet configured in each availability zone in your preferred AWS region
  * CIDR block for the host or hosts from which this project will be deployed
    * Make sure there are no firewalls or other policies that would prevent the deployment host from issuing API calls and HTTP requests to your AWS account.
    
    
Deployment code 
 ```hcl-terraform
module "gateway" {
  source                = "../terraform"
  bucket_region         = "us-east-1"
  bucket_name           = "TestGateayBucket"
  gateway_time_zone     = "GMT-6:00"
  vpc_id                = "" #your VPC ID goes here.
  subnet_id             = "" #the subnet into which you are launching the gateway
  key_name              = "" #your ec2 ssh key goes here
  gateway_name          = "TestGateway"
  ebs_cache_volume_size = 200
  instance_type         = "m4.xlarge"  #consult the AWS deployment guides for supported instance types
  deployment_cidr       = ""#the CIDR block for your deployment host goes here.  Example:  "172.0.0.0/8"
  zone_name             = "" #the DNS Zone into which your gateway's record should be created
  client_access_list    = ["10.10.0.0/16"] #replace with your own list
}
```

Once you've configured the parameters in the gateway module, you can then deploy the gateway environment by running:
`terraform init`

`terraform apply`
