# Home server setup #

Getting started

Generate keys for AWS login, the private key `master` and public key
`master.pub`.

    $ make master

Terraform apply to create the infra.

    $ terraform apply

Forward DNS to the elastic IP from the hosting provider's DNS config.

    $ terraform output ip

You should be able to login to the new box.

    $ ssh -i master ubuntu@`terraform output ip`

Install Pi hole

    $ curl -sSL https://install.pi-hole.net | bash

Pick default answer for all questions, copy the admin password in the last screen.

Install OpenVPN on the remote server

    $ wget https://git.io/vpn -O openvpn-install.sh && sudo bash openvpn-install.sh

Pick the default answer for every question, provide the output of `terraform
output ip` as the public IP. Use the system default as DNS to use Pi hole.

Copy the generated VPN config file `client.ovpn`. Keep this safe.

     $ make client.vpn

## Infrastructure ##

- 1 t2.micro Ubuntu VM as Bastion
- 1 Elastic IP to forward from DNS
- 1 Private key to manage SSH
- 2 Security groups to allow SSH and VPN traffic

## VPN ##

OpenVPN for all traffic, including HTTP, HTTPS and ~~DNS~~.

Options are tinc and OpenVPN, but going for Open VPN because of the [easy
installation script][openvpn-install].

The `client.ovpn` file can be opened in a VPN client like [Viscosity][viscosity]
to import the config and start the connection.

## SSH ##

SSH to bastion box with client generated certificates.

?? Limit SSH from VPN? There is a possibility that the VPN might break and I'd
get locked out of the setup.

## Pi Hole ##

Ad blocking at DNS level. Web UI than can be enabled inside the VPN.

## Issues ##

DNS setup on the client side is not smooth, works only when the DNS is
explicitly set to the *Private* IP of the instance. Automate this, change to
public IP so that phone can connect as well.

## Wishlist ##

- [ ] Automate openvpn installation in non interactive form
- [ ] Provision the entire setup with Terraform
- [ ] Enable 2fa for OpenVPN
- [ ] Enable 2fa for SSH
- [ ] Limit Pi admin to VPN
- [ ] Run everything as docker containers if possible, because a Dockerfile is
      the easiest way to configure compared to horrible config management tools
      like Puppet and Ansible.
- [ ] Limit DNS connections to pi hole server from trusted machines.
- [ ] Serve pi hole over tls, even in VPN
- [ ] WIN!

[openvpn-install]: https://github.com/Nyr/openvpn-install
[viscosity]: https://www.sparklabs.com/viscosity/
