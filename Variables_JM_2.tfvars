terraform {
  required_version = ">=0.12"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "Azure_location" {
  default     = "East US"
}

variable "resource_group_name" {
  default     = "test-resource_group"
}

variable "vnet_name" {
  default     = "test-vnet"
}

variable "subnet_identification" {
  type        = map(string)
  default = {
    "sub1" = "10.0.0.0/24"
    "sub2" = "10.0.1.0/24"
    "sub3" = "10.0.2.0/24"
    "sub4" = "10.0.3.0/24"
  }
}

#variable "admin_username" {
#  default     = "Jack_Admin"
#}

#variable "admin_password" {
# default     = "Bears3423!"
#}

variable "apache_install_script" {
  default     = "#!/bin/bash\nsudo yum install -y httpd\nsudo systemctl start httpd\nsudo systemctl enable httpd"
}

variable "storage_account_name" {
  default     = "storage_acct_test"
}



#Resources:
# https://httpd.apache.org/docs/current/install.html
# https://www.youtube.com/watch?v=UETRaGjpJoQ
# https://registry.terraform.io/
#https://medium.com/@jorge.gongora2610/how-to-set-up-an-apache-web-server-on-azure-using-terraform-f7498daa9d66