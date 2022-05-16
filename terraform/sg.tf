resource "aws_security_group" "public_ssh" {
  name        = "sg_public_ssh"
  description = "allow SSH from internet"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.default_tags, {
    Name = "public_sg_ssh_only"
    },
  )
}

resource "aws_security_group" "pub_to_priv_ssh" {
  name        = "sg_private_ssh"
  description = "allow SSH from public subnet"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.default_tags, {
    Name = "private_sg_ssh_only_from_public_subnet"
    },
  )
}


resource "aws_security_group" "priv_to_priv_ssh" {
  name        = "sg_priv_to_priv_ssh"
  description = "allow SSH from within private subnet"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.default_tags, {
    Name = "private_sg_ssh_only_from_within_private_subnet"
    },
  )
}


resource "aws_security_group" "icmp" {
  name        = "sg_icmp"
  description = "allow icmp from public or private subnet"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/20"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.default_tags, {
    Name = "private_sg_icmp_from_public_or_private_subnet"
    },
  )
}

resource "aws_security_group" "dns" {
  name        = "allow_dns"
  description = "allow dns UDP 53 ingress from public or private subnet"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/20"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.default_tags, {
    Name = "allow_dns_from_public_or_private_subnet"
    },
  )
}
