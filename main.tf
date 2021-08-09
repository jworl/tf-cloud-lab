provider "aws" {
    region                  = var.region
    profile                 = var.aws_acct_role
    shared_credentials_file = var.creds_file
}

data "http" "public_ip" {
    # url = "http://ifconfig.co/json"
    url = "https://api.ipify.org?format=json"
    request_headers = {
        Accept = "application/json"
    }
}

locals {
    ifconfig = jsondecode(data.http.public_ip.body)
    my_addr = format("%s/32", local.ifconfig.ip)
    yaml_trusted = fileexists("trusted_IPs.yml") ? yamldecode(file("trusted_IPs.yml"))["trusted_IPs"] : []

    trusted = compact(
        distinct(
            concat(
                [local.my_addr], local.yaml_trusted
            )
        )
    )

    build_machines = merge(
        var.salt_monarch, yamldecode(file("my_machines.yml"))
    )

    security_groups = distinct(
        flatten([
            for k,V in local.build_machines: [
                for v in V.security_groups: [
                    v
                ]
            ]
        ])
    )

    rsync_exclude = join(
        ",",
        var.monarch_exclusions
    )

    aws_library = yamldecode(file("aws_library.yml"))
}

resource "null_resource" "s1_pkgs" {
    count = var.skip_s1_pkgs ? 0 : 1

    provisioner "local-exec" {
        command = "python3 s1pkgs.py -t ${var.s1_api_token} -c ${var.s1_console} -s ${var.s1_site_id}"
    }
}

resource "null_resource" "cb_pkgs" {
    count = var.skip_cb_pkgs ? 0 : 1

    provisioner "local-exec" {
        command = "python3 cbpkgs.py -p ${var.aws_acct_role} -b ${var.cb_pkg_bucket} -c ${var.cb_company_code} -g ${var.cb_group_name} -e ${var.cb_email}"
    }
}

resource "null_resource" "victims" {
    provisioner "local-exec" {
        command = "python3 victims.py"
    }
}

resource "aws_vpc" "warzone" {
    cidr_block          = var.cidr
    instance_tenancy    = "default"

    tags = merge({Name="warzone"}, var.tags)
}

resource "aws_flow_log" "warzone" {
    log_destination = var.vpc_flow_log_bucket
    log_destination_type = "s3"
    log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"
    traffic_type = "ALL"
    vpc_id = aws_vpc.warzone.id

    depends_on  = [aws_vpc.warzone]
    tags        = merge({Name="warzone"}, var.tags)
}

resource "aws_internet_gateway" "warzone" {
    vpc_id      = aws_vpc.warzone.id

    depends_on  = [aws_vpc.warzone]
    tags        = merge({Name="warzone"}, var.tags)
}

resource "aws_route_table" "warzone" {
    vpc_id = aws_vpc.warzone.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.warzone.id
    }

    depends_on = [aws_internet_gateway.warzone]
    tags = merge({Name="warzone"}, var.tags)
}

resource "aws_subnet" "warzones" {
    for_each = var.warzones

    vpc_id              = aws_vpc.warzone.id
    availability_zone   = each.key
    cidr_block          = each.value

    depends_on = [aws_internet_gateway.warzone]
    tags       = merge({Name=each.key}, var.tags)
}

resource "aws_route_table_association" "warzones" {
    for_each = var.warzones

    subnet_id = aws_subnet.warzones[each.key].id
    route_table_id = aws_route_table.warzone.id

    depends_on = [aws_subnet.warzones]
}

resource "aws_security_group" "service_rules" {
    for_each = toset(local.security_groups)

    name        = each.value
    description = var.security_groups[each.value].description
    vpc_id      = aws_vpc.warzone.id

    ingress {
        cidr_blocks = var.security_groups[each.value].public ? local.trusted : [var.cidr]
        from_port   = var.security_groups[each.value].from_port
        to_port     = var.security_groups[each.value].to_port
        protocol    = var.security_groups[each.value].protocol
    }

    egress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
    }

    depends_on = [aws_subnet.warzones]
    tags       = merge({Name=each.key}, var.tags)
}

data "aws_ami" "library" {
    for_each = local.aws_library

    most_recent = true
    owners = [each.value.owner]

    filter {
        name    = "name"
        values  = [each.value.name]
    }
}

resource "aws_network_interface" "eni" {
    for_each = local.build_machines

    subnet_id = aws_subnet.warzones[var.zone].id
    security_groups = [
        for sg in each.value.security_groups:
            aws_security_group.service_rules[sg].id
    ]

    depends_on = [aws_subnet.warzones, aws_security_group.service_rules]
    tags       = merge({Name=each.key}, var.tags)
}

resource "aws_eip" "publics" {
    for_each = local.build_machines

    vpc                 = true
    network_interface   = aws_network_interface.eni[each.key].id

    depends_on = [aws_network_interface.eni]
    tags       = merge({Name=each.key}, var.tags)
}

resource "aws_instance" "test_machines" {
    for_each = local.build_machines

    ami = data.aws_ami.library[each.value.os].id
    instance_type           = each.value.size
    key_name                = var.aws_key

    network_interface {
        network_interface_id = aws_network_interface.eni[each.key].id
        device_index = 0
    }

    get_password_data = local.aws_library[each.value.os].get_pass
    user_data = each.value.bootstrap ? templatefile(
            each.value.bootstrap_file,
            {
                addr = aws_network_interface.eni["perpetua"].private_ip,
                name = each.key
            }
        ) : null

    # provisioner "local-exec" {
    #     when = destroy
    #     command = "python3 cb_removal.py -o ${var.cb_company_id} -q \"(${[aws_eip.publics[each.key].public_ip]}) AND ${var.cb_group_name}\" -u ${var.cb_console} -t ${var.cb_api_token}"
    # }

    depends_on = [aws_eip.publics]
    tags       = merge({Name=each.key}, var.tags)
}

resource "null_resource" "monarch_data" {
    provisioner "local-exec" {
        command = "until nc -z ${aws_eip.publics["perpetua"].public_ip} 22 &> /dev/null; do echo waiting for ${aws_eip.publics["perpetua"].public_ip} response; sleep 1; done; for A in pillar salt; do rsync -urpv --delete --exclude={${local.rsync_exclude}} --rsync-path=\"sudo rsync\" -e \"ssh -o StrictHostKeyChecking=no -i ${var.local_key}\" $A ubuntu@${aws_eip.publics["perpetua"].public_ip}:/srv; done"
    }

    depends_on = [
        aws_instance.test_machines["perpetua"],
        null_resource.s1_pkgs, null_resource.cb_pkgs,
        null_resource.victims
    ]
}

output "trusted_address_list" {
    description = "Trusted IPs for public SGs"
    value = local.trusted
}

output "build_machines_map" {
    description = "Test machines requested"
    value = local.build_machines
}

output "test_server_addresses" {
    description = "Public IPs for accessing test machines"
    value = {
        for k,v in local.build_machines:
            k => aws_eip.publics[k].public_ip
    }
}

output "victim_account_info" {
    description = "How to find victim account information"
    value = "cat pillar/common/victims.sls for login information"
}

# output "admin_pass" {
#     description = "Passphrases for test machines"
#     value = {
#         for k,v in local.build_machines:
#             k => aws_instance.test_machines[k].get_password_data ?
#                 rsadecrypt(
#                     aws_instance.test_machines[k].password_data,
#                     file(var.local_key)
#                 )
#                 : "No password, use private key"
#     }
# }
