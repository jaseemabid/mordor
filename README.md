## VPS Setup

Get AWS credentials

    $ touch ~/.aws/credentials

Generate a key pair for SSH access into the newly minted instances.

    $ make primary

    $ terraform init
    $ terraform plan -out this
    $ terraform apply this

Get the public IP

    $ terraform output ip

You should be able to login to the new box.

    $ ssh -i primary ubuntu@`terraform output ip`

Install Pi hole

    $ curl -sSL https://install.pi-hole.net | bash

Pick default answer for all questions, copy the admin password in the last
screen. Use the private IP since this instance should not be publicly
accessible.

Install wireguard

    $ sudo apt install wireguard
    $ wg-quick up ./server.conf

Enabling IP forwarding on server

    $ Uncomment `net.ipv4.ip_forward=1` in /etc/sysctl.conf
    $ sudo sysctl -p

## Reading list

https://github.com/n1trux/awesome-sysadmin
https://github.com/Kickball/awesome-selfhosted
https://blog.albertoacuna.com/using-terraform-to-create-an-ec2-instance-within-a-public-subnet-in-aws/
