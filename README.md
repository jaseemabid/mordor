# Home server setup #

## Prerequisites

- Access to an AWS account (you can start with the free tier)
- [Terraform](https://www.terraform.io/downloads.html)

## Provisioning

Generate a key pair for SSH access into the newly minted instances.

    $ make master

Configure your AWS access keys by:

    $ cp terraform.tfvars.example terraform.tfvars

And populate it with your `access_key` and `secret_key`. You may also set the
following environment variables and `terraform` will pick them up for you:

    TF_VAR_access_key
    TF_VAR_secret_key

The default AWS region is set to `eu-west-2` but you can set it in
`terraform.tfvars` or confiure the environment variable `TF_VAR_region`.

Terraform apply to create the infra.

    $ terraform init
    $ terraform apply

Forward DNS to the elastic IP from the hosting provider's DNS config.

    $ terraform output ip

You should be able to login to the new box.

    $ ssh -i master ubuntu@`terraform output ip`

## Infrastructure

- 1 t2.micro Ubuntu VM as Bastion
- 1 Elastic IP to forward from DNS
- 1 Private key to manage SSH
- 2 Security groups to allow SSH and VPN traffic

## Setup

## VPN

WireGuard for all traffic, including HTTP, HTTPS and DNS.

## SSH ##

SSH to bastion box with client generated certificates.

?? Limit SSH from VPN? There is a possibility that the VPN might break and I'd
get locked out of the setup.

## Pi Hole ##

Ad blocking at DNS level. Web UI than can be enabled inside the VPN.

Install Pi hole

    $ curl -sSL https://install.pi-hole.net | bash

Pick default answer for all questions, copy the admin password in the last screen.

     $ make client.vpn




## Issues ##

DNS setup on the client side is not smooth, works only when the DNS is
explicitly set to the *Private* IP of the instance. Automate this, change to
public IP so that phone can connect as well.

## Wishlist ##

- [ ] Provision the entire setup with Terraform
- [ ] Enable 2fa for SSH
- [X] Limit Pi admin to VPN
- [ ] Run everything as docker containers if possible, because a Dockerfile is
      the easiest way to configure compared to horrible config management tools
      like Puppet and Ansible.
- [X] Limit DNS connections to pi hole server from trusted machines.
- [X] Serve pi hole over tls, even in VPN


[cf]: https://blog.cloudflare.com/enable-private-dns-with-1-1-1-1-on-android-9-pie/
