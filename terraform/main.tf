########################### NEW VPC ##############################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = var.default_tags
}
########################### NEW VPC ##############################

########################### SUBNETS ##############################

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  # 251 IP addresses each
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags = merge(var.default_tags, {
    Name = "10.0.1.0 - Public Subnet"
    },
  )
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  # 251 IP addresses each
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2a"
  tags = merge(var.default_tags, {
    Name = "10.0.2.0 - Private Subnet"
    },
  )
}
########################### SUBNETS ##############################

########################### INTERNET GATWAY ######################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.default_tags, {
    Name      = "igw"
    CreatedBy = "tf-syslog-ng"
    },
  )
}

# create route table and attach to Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.default_tags, {
    Name = "public_route_table"
    },
  )
}

# associate designated subnet to public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
########################### INTERNET GATWAY ######################

########################### NAT GATWAY ###########################
resource "aws_eip" "ngw" {
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public.id

  # ensure proper ordering; add an explicit dependency on the IGW for the VPC
  depends_on = [aws_internet_gateway.igw]
  tags       = var.default_tags
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
  tags = merge(var.default_tags, {
    Name = "private_route_table"
    },
  )
}

# associate private subnet with private route table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
########################### NAT GATWAY ###########################


########################### DHCP OPTIONS #########################
#resource "aws_vpc_dhcp_options" "config" {
#domain_name = "tatooine.test"
##domain_name_servers = ["127.0.0.1", "10.0.0.2"]
##domain_name_servers = ["AmazonProvidedDNS", "${aws_instance.public_test[2].private_ip}" ]
#domain_name_servers = ["AmazonProvidedDNS"]
#tags = merge(var.default_tags, {
#Name = "VPC DCHP Options"
#},
#)
#}
#
#resource "aws_vpc_dhcp_options_association" "dns_resolver" {
#vpc_id          = aws_vpc.main.id
#dhcp_options_id = aws_vpc_dhcp_options.config.id
#}
#
#resource "aws_route53_zone" "private" {
#name = "tatooine.test"
#
#vpc {
#vpc_id = aws_vpc.main.id
#}
#tags = merge(var.default_tags, {
#Name = "aws_vpc_dhcp_options_association"
#},
#)
#}
#
#locals {
#host_names = {
#namea = "syslog-0.tatooine.test"
#nameb = "syslog-1.tatooine.test"
#namec = "dns.tatooine.test"
#named = "client.tatooine.test"
#namee = "mirror.tatooine.test"
#}
#deploy_names = {
#deploya = aws_instance.public_test[0]
#deployb = aws_instance.public_test[1]
#deployc = aws_instance.public_test[2]
#deployd = aws_instance.public_test[3]
#deploye = aws_instance.public_test[4]
#}
#host_deploy_names = zipmap(values(local.host_names), values(local.deploy_names))
#}
#
#resource "aws_route53_record" "domain_records" {
#for_each        = local.host_deploy_names
#zone_id         = aws_route53_zone.private.zone_id
#allow_overwrite = true
#name            = each.key
#type            = "A"
#ttl             = "300"
#records         = [each.value.private_ip]
#}
############################ DHCP OPTIONS #########################

############################ EC2 INSTANCES ########################
resource "aws_key_pair" "ssh" {
  key_name   = "ssh_key_pair"
  public_key = file(pathexpand("~/.ssh/id_ed25519_tf_acg.pub"))
  tags = merge(var.default_tags, {
    Name = "ssh_key_pair"
    },
  )
}

data "aws_ami" "latest-Redhat" {
  most_recent = true
  owners      = ["309956199498"] # Redhat owner ID

  filter {
    name   = "name"
    values = ["RHEL_HA-8.5.0_HVM-2*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  tags = var.default_tags
}

#public instance
resource "aws_instance" "public_test" {
  count           = 5
  ami             = data.aws_ami.latest-Redhat.id # Get latest RH 8.5x image
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.public_ssh.id, aws_security_group.icmp.id]
  instance_type   = "t3.micro"
  #iam_instance_profile = "EC2SSMRole"
  key_name = "ssh_key_pair"
  #user_data = <<EOF
  ##!/bin/bash
  #sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
  #sudo dnf install bind-utils git hping3 lsof nc nmap tcpdump tmux vim -y
  #EOF
  tags = merge(var.default_tags, {
    Name = "public-instance-test"
    },
  )
}

resource "aws_instance" "private_test" {
  ami             = data.aws_ami.latest-Redhat.id # Get latest RH 8.5x image
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.priv_to_priv_ssh.id, aws_security_group.icmp.id, aws_security_group.pub_to_priv_ssh.id, aws_security_group.vault.id]
  instance_type   = "t3.micro"
  count           = 1
  key_name        = "ssh_key_pair"
  #user_data       = <<EOF
  ##!/bin/bash
  #sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
  #sudo dnf install bind-utils git hping3 lsof nc nmap tcpdump tmux vim -y
  #setenforce 0
  #EOF
  tags = merge(var.default_tags, {
    Name = "private-instance-test"
    },
  )

}
########################### EC2 INSTANCES ########################
