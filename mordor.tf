provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_key_pair" "terraform" {
  key_name               = "master"
  public_key             = "${file("master.pub")}"
}

# Add this IP to the DNS resolver of the hosting provider

resource "aws_eip" "bastion" {
  instance               = "${aws_instance.bastion.id}"

  tags {
    Name                 = "Bastion"
  }
}

resource "aws_security_group" "ssh" {
  name                   = "ssh"
  description            = "Allow inbound SSH traffic"

  ingress {
    from_port            = 22
    to_port              = 22
    protocol             = "tcp"
    cidr_blocks          = ["0.0.0.0/0"]
  }

  // Not sure if this block is needed for outbound connections.
  egress {
    from_port            = 0
    to_port              = 0
    protocol             = "-1"
    cidr_blocks          = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpn" {
  name                   = "vpn"
  description            = "Allow inbound VPN traffic"

  ingress {
    from_port            = 1194
    to_port              = 1194
    protocol             = "udp"
    cidr_blocks          = ["0.0.0.0/0"]
  }
}

# This allows anyone on the internet to use this IP address as their DNS server,
# which is probably a bad idea.

resource "aws_security_group" "pi" {
  name                   = "pi"
  description            = "Allow inbound DNS queries"

  ingress {
    from_port            = 53
    to_port              = 53
    protocol             = "tcp"
    cidr_blocks          = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = "ami-0b0a60c0a2bd40612"
  instance_type          = "t2.micro"
  key_name               = "master"

  vpc_security_group_ids = ["${aws_security_group.ssh.id}",
                            "${aws_security_group.vpn.id}",
                            "${aws_security_group.pi.id}"]

  tags {
    Name                 = "Bastion"
  }

  # provisioner "local-exec" {
  #   command            = "echo ${aws_instance.example.public_ip} > ip_address.txt"
  # }
}

output "ip" {
  value                  = "${aws_eip.bastion.public_ip}"
}
