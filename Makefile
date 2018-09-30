master master.pub:
	ssh-keygen -t rsa -b 4096 -C "AWS Keys for Jaseem Abid <jaseemabid@gmail.com>" -f master

client.ovpn: master
	scp -i master ubuntu@`(terraform output ip)`:client.ovpn .
