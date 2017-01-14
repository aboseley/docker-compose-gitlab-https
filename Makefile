.PHONY: clean all
.SUFFIXES: .key .crt .crt .self.crt .csr
.PRECIOUS: %.key %.self.crt %.crt

###### config ##################

# Name of the gitlab server
SERVER_NAME := $(shell hostname)

# Name we will use for our root certificate
CA_NAME := $(USER)Certificate

# random ports numbers to use, hardcode as desired
HTTPS_PORT := $(shell shuf -i 1001-2000 -n 1)
SSH_PORT := $(shell shuf -i 2001-3000 -n 1)
REGISTRY_PORT := $(shell shuf -i 6000-10000 -n 1)

###### implementation #########

# self signed certificate and key to use as CA
CA_CRT  := config/trusted-certs/$(CA_NAME).self.crt
CA_KEY  := config/trusted-certs/$(CA_NAME).key

# we need a server certificate (signed by CA) and key
SERVER_CRT  := config/ssl/$(SERVER_NAME).crt
SERVER_KEY  := config/ssl/$(SERVER_NAME).key

#these are the files gitlab needs
REQUIRED_FILES := $(CA_KEY) \
                  $(CA_CRT) \
                  $(SERVER_CRT) \
                  $(SERVER_KEY) \
                  docker-compose.yml

REQUIRED_DIRS := config/ssl/ config/trusted-certs

#build the required files
all : $(REQUIRED_FILES)

# create the required directories before the files
$(REQUIRED_FILES) : | $(REQUIRED_DIRS)
$(REQUIRED_DIRS) :
	mkdir -p $(REQUIRED_DIRS)

$(CA_CRT) : SUBJ := "/CN=$(CA_NAME)"

# the server certificate needs two names
#  1. host name in the docker session and
#  2. external host name
config/ssl/$(SERVER_NAME).crt : SUBJ := "/CN=$(SERVER_NAME)/subjectAltName=DNS.1=gitlab_server"

# generate a compose file the correct host name
docker-compose.yml : docker-compose.template
	HTTPS_PORT=$(HTTPS_PORT) \
        SSH_PORT=$(SSH_PORT) \
        REGISTRY_PORT=$(REGISTRY_PORT) \
	HOSTNAME=$(SERVER_NAME) \
 		envsubst < $^ > $@

# ssl key generation rules
######################

# create private keys
%.key :
	openssl genrsa -out $@

# self signed certificate
%.self.crt : %.key
	openssl req -subj $(SUBJ) -new -x509 -key $^ -sha256 -days 3650 -out $@

# certificate signing requests
%.csr : %.key
	openssl req -subj $(SUBJ) -new       -key $^ -out $@

# certificate signed by CA_CRT
%.crt : %.csr $(CA_CRT)
	openssl x509 -req -in $< \
	     -CA $(CA_CRT) -CAkey $(CA_KEY) \
             -CAcreateserial -days 3650 -sha256 -out $@

clean :
	rm -rf config docker-compose.yml
