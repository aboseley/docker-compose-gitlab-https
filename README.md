
I'm trying to setup a local network gitlab server with a functioning docker container registry.  
The docker registry expects to run with a https connect. 

Since I'm on a local domain there are two choices to make https work :-
 -  use self signed certificate and with the associated security issues 
 -  create my own root certificate, that I manually install on client machines

First install docker, docker-compose and make.
On the server you want to run the gitlab serve run.
``` bash
  make
  docker-compose up
  hostname
```

To securely connect
- import "config/trusted-certs/ca.cert" into your browser as an authority certificate
- then open https://<gitlab_hostname> 
