terraform {
  required_version = ">=0.12"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "f1ecd7ae-5b1e-4316-9c95-0d105138ac45"
}

variable "Azure_location" {
  default     = "West US"
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
  default = <<EOF
#!/bin/bash
# Install Apache, add proper listener, create default page, correct permissions, & restrat services
sudo yum install -y httpd

sudo sed -i 's/^Listen .*/Listen 0.0.0.0:80/' /etc/httpd/conf/httpd.conf

cat << 'EOL' | sudo tee /var/www/html/index.html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
        <head>
                <title>Test Page for the HTTP Server on Red Hat Enterprise Linux</title>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
                <style type="text/css">
                        /*<![CDATA[*/
                        body {
                                background-color: #fff;
                                color: #000;
                                font-size: 0.9em;
                                font-family: sans-serif,helvetica;
                                margin: 0;
                                padding: 0;
                        }
                        :link {
                                color: #c00;
                        }
                        :visited {
                                color: #c00;
                        }
                        a:hover {
                                color: #f50;
                        }
                        h1 {
                                text-align: center;
                                margin: 0;
                                padding: 0.6em 2em 0.4em;
                                background-color: #900;
                                color: #fff;
                                font-weight: normal;
                                font-size: 1.75em;
                                border-bottom: 2px solid #000;
                        }
                        h1 strong {
                                font-weight: bold;
                        }
                        h2 {
                                font-size: 1.1em;
                                font-weight: bold;
                        }
                        hr {
                                display: none;
                        }
                        .content {
                                padding: 1em 5em;
                        }
                        .content-columns {
                                /* Setting relative positioning allows for
                                absolute positioning for sub-classes */
                                position: relative;
                                padding-top: 1em;
                        }
                        .content-column-left {
                                /* Value for IE/Win; will be overwritten for other browsers */
                                width: 47%;
                                padding-right: 3%;
                                float: left;
                                padding-bottom: 2em;
                        }
                        .content-column-left hr {
                                display: none;
                        }
                        .content-column-right {
                                /* Values for IE/Win; will be overwritten for other browsers */
                                width: 47%;
                                padding-left: 3%;
                                float: left;
                                padding-bottom: 2em;
                        }
                        .content-columns>.content-column-left, .content-columns>.content-column-right {
                                /* Non-IE/Win */
                        }
                        .logos {
                                text-align: center;
                                margin-top: 2em;
                        }
                        img {
                                border: 2px solid #fff;
                                padding: 2px;
                                margin: 2px;
                        }
                        a:hover img {
                                border: 2px solid #f50;
                        }
                        /*]]>*/
                </style>
        </head>

        <body>
                <h1>Red Hat Enterprise Linux <strong>Test Page</strong></h1>

                <div class="content">
                        <div class="content-middle">
                                <p>This page is used to test the proper operation of the HTTP server after it has been installed. If you can read this page, it means that the HTTP server installed at this site is working properly.</p>
                        </div>
                        <hr />

                        <div class="content-columns">
                                <div class="content-column-left">
                                        <h2>If you are a member of the general public:</h2>

                                        <p>The fact that you are seeing this page indicates that the website you just visited is either experiencing problems, or is undergoing routine maintenance.</p>

                                        <p>If you would like to let the administrators of this website know that you've seen this page instead of the page you expected, you should send them e-mail. In general, mail sent to the name "webmaster" and directed to the website's domain should reach the appropriate person.</p>

                                        <p>For example, if you experienced problems while visiting www.example.com, you should send e-mail to "webmaster@example.com".</p>

                                        <p>For information on Red Hat Enterprise Linux, please visit the <a href="http://www.redhat.com/">Red Hat, Inc. website</a>. The documentation for Red Hat Enterprise Linux is <a href="http://www.redhat.com/docs/manuals/enterprise/">available on the Red Hat, Inc. website</a>.</p>
                                        <hr />
                                </div>

                                <div class="content-column-right">
                                        <h2>If you are the website administrator:</h2>

                                        <p>You may now add content to the webroot directory. Note
                                        that until you do so, people visiting your website will see
                                        this page, and not your content.</p>

                                        <p>For systems using the Apache HTTP Server:
                                        You may now add content to the directory <tt>/var/www/html/</tt>. Note that until you do so, people visiting your website will see this page, and not your content. To prevent this page from ever being used, follow the instructions in the file <tt>/etc/httpd/conf.d/welcome.conf</tt>.</p>

                                        <p>For systems using NGINX:
                                        You should now put your content in a location of your
                                        choice and edit the <code>root</code> configuration directive
                                        in the <strong>nginx</strong> configuration file
                                        <code>/etc/nginx/nginx.conf</code>.</p>

                                        <div class="logos">
                                                <a href="https://access.redhat.com/products/red-hat-enterprise-linux"><img src= "/icons/poweredby.png" alt="[ Powered by Red Hat Enterprise Linux ]" /></a>
                                                <img src= "poweredby.png" alt="[ Powered by Red Hat Enterprise Linux ]" />
                                        </div>
                                </div>
                        </div>
                </div>
        </body>
</html>

EOL

sudo chmod 644 /var/www/html/index.html

sudo chmod 755 /var/www/html

sudo systemctl start httpd
sudo systemctl enable httpd

sudo systemctl restart httpd
EOF
}


variable "storageAcct" {
  default = "storageaccttestjackm"
}




#Resources:
#https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows
# https://httpd.apache.org/docs/current/install.html
# https://www.youtube.com/watch?v=UETRaGjpJoQ
# https://registry.terraform.io/
#https://medium.com/@jorge.gongora2610/how-to-set-up-an-apache-web-server-on-azure-using-terraform-f7498daa9d66
#https://learn.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-internal-terraform
#https://github.com/hashicorp/terraform/issues/9311
#https://www.geeksforgeeks.org/how-to-create-azure-storage-account-using-terraform/
#https://learn.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/error-storage-account-name?tabs=bicepte
#https://stackoverflow.com/questions/70694552/how-to-set-default-values-for-a-object-in-terraform
#https://stackoverflow.com/questions/50998306/how-to-obtain-default-apache-getting-started-html
#https://stackoverflow.com/questions/19884484/how-to-run-my-html-file-with-apache2
