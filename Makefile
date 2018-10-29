.PHONY: master
master master.pub:
	@if [ -z "$(NAME)" ]; then echo 'NAME is not set'; false; fi
	@if [ -z "$(EMAIL)" ]; then echo 'EMAIL is not set'; false; fi
	ssh-keygen -t rsa -b 4096 -C "AWS Keys for $(NAME) <$(EMAIL)>" -f master

.PHONY: client.ovpn
client.ovpn: master
	scp -i master ubuntu@`(terraform output ip)`:client.ovpn .

.PHONY: clean
clean:
	rm master master.pub
