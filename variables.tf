variable "region" {
    default = "us-east-2"
}

variable "creds_file" {
    default = "~/.aws/credentials"
}

# CAUTION!
# strongly advise against creating
# folders/files with whitespace,
# be wise and stick with dashes or
# underscores
variable "monarch_exclusions" {
    type = list(string)
    default = [
        "salt/files/s1/archives",
        "salt/files/dummy",
        "salt/win"
    ]
}

# CAUTION!
# using the s1pkgs script requires
# corporate VPN connection :(
# before changing this to false
# in your tfvars, be certain you're
# on the VPN
variable "skip_s1_pkgs" {
    type = bool
    default = true
}

variable "skip_cb_pkgs" {
    type = bool
    default = true
}

# REQUIRED
# specify path in terraform.tfvars
variable "aws_key" {
    type = string
}

# REQUIRED
# specify path in terraform.tfvars
variable "s1_api_token" {
    type = string
}

# REQUIRED
# specify path in terraform.tfvars
variable "s1_console" {
    type = string
}

# REQUIRED
# specify path in terraform.tfvars
variable "s1_site_id" {
    type = string
}

variable "cb_pkg_bucket" {
    type = string
}

variable "cb_company_code" {
    type = string
}

variable "cb_group_name" {
    type = string
}

variable "cb_email" {
    type = string
}

variable "cb_company_id" {
    type = string
}

variable "cb_console" {
    type = string
}

variable "cb_api_token" {
    type = string
}

# Override with yours in terraform.tfvars
# if your AWS instances are deployed with
# a different key
variable "local_key" {
    type = string
    default = "~/.ssh/id_rsa"
}

# REQUIRED
# specify path in terraform.tfvars
variable "aws_acct_role" {
    type = string
}

variable "tags" {
    type = map
    default = {
        team = "team-name-here"
        application = "sandbox-name"
        environment = "dev"
        customer = "customer-name"
        contact-email = "distlist@domain.tld"
    }
}

variable "cidr" {
    type = string
    default = "192.168.123.0/24"
}

variable "zone" {
    type = string
    default = "us-east-2a"
}

variable "warzones" {
    type = map
    default = {
        us-east-2a = "192.168.123.0/25"
    }
}

variable "vpc_flow_log_bucket" {
    type = string
    default = "arn:aws:s3:::vpc-flowlogs"
}

# I really do not like the current SG
# data structure, but I have not developed
# anything better so we're stuck with this
# for now
variable "security_groups" {
    type    = map
    default = {
        victim_private = {
            # primarily for victim test machines
            description = "All private VPC",
            from_port   = 0,
            to_port     = 0,
            protocol    = "-1",
            public      = false
        },
        ping_private = {
            description = "Ping private VPC",
            from_port   = -1,
            to_port     = -1,
            protocol    = "icmp",
            public      = false
        },
        ping_public = {
            description = "Ping from trusted IPs",
            from_port   = -1,
            to_port     = -1,
            protocol    = "icmp",
            public      = true
        },
        ssh_mgmt = {
            description = "Allow SSH from trusted IPs",
            from_port   = 22,
            to_port     = 22,
            protocol    = "tcp",
            public      = true
        },
        rdp_mgmt = {
            description = "Allow RDP from trusted IPs",
            from_port   = 3389,
            to_port     = 3389,
            protocol    = "tcp",
            public      = true
        },
        salt_monarch = {
            description = "Allow encrypted salt channel",
            from_port   = 4505,
            to_port     = 4506,
            protocol    = "tcp",
            public      = false
        },
        attacker_listen = {
            description = "Allow attacker listening range",
            from_port   = 50000,
            to_port     = 60000,
            protocol    = "tcp",
            public      = false
        }
    }
}

variable "salt_monarch" {
    type = map
    default = {
        perpetua = {
            os = "ubuntu_focal"
            bootstrap = true
            bootstrap_file = "bootstrap/monarch.tpl"
            size = "t3a.micro"
            security_groups = [
                "ssh_mgmt", "salt_monarch",
                "ping_public", "ping_private"
            ]
        }
    }
}
