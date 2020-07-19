provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/26"
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/26"
}

resource "aws_internet_gateway" "iw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.iw.id
  }
}

resource "aws_route_table_association" "public_route_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Use `$ make primary` to create one
resource "aws_key_pair" "ssh" {
  key_name   = "primary"
  public_key = file("primary.pub")
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  vpc      = true

  tags = {
    Name = "Bastion"
  }
}

# Security groups are stateful and return traffic is automatically allowed,
# regardless of any rules. There is no need for an egress rule here.
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html
resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Inbound & return SSH traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "icmp" {
  name        = "icmp"
  description = "Allow ping"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "wg" {
  name        = "wg"
  description = "Wireguard traffic and egress to internet"
  vpc_id      = aws_vpc.main.id

  // Traffic to and from clients
  ingress {
    from_port   = 5555
    to_port     = 5555
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Egress to internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-0fb673bc6ff8fc282"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh.key_name
  subnet_id     = aws_subnet.public.id
  # associate_public_ip_address = "true"

  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.wg.id,
    aws_security_group.icmp.id
  ]

  tags = {
    Name = "Bastion"
  }

  # provisioner "local-exec" {
  #   command            = "echo ${aws_instance.example.public_ip} > ip_address.txt"
  # }
}

output "ip" {
  value = "${aws_eip.bastion.public_ip}"
}
