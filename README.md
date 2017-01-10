I'm trying to setup a local network gitlab server with a functioning docker container registry.  
The docker registry expects to run with a https connect. 

First install docker, docker-compose and make.
On the server you want to run the gitlab serve run.
``` bash
  make
  docker-compose up
```

To securely connect the certificate "config/trusted-certs/<ca_name>Certificate.self.cert" 
needs to be installed onto the connecting machine

Install into browser as an "authorities" certificate

Install into client docker daemon
- to run 'docker login' on another machine the be installed into
  /etc/docker/certs.d/<server_name>:5005
- restart the daemon
`sudo service docker restart`

