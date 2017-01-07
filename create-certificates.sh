set -x
CA_NAME=rootCA
GITLAB_SERVER=192.168.0.7

#generate self signed local root certificate
openssl genrsa -nodes -out ${CA_NAME}.key 
openssl req -subj "/CN=$CA_NAME" -new -x509 -key ${CA_NAME}.key \
            -sha256 -days 3650 -out ${CA_NAME}.cert

#create a gitlab server host certificate
openssl genrsa -nodes -out ${GITLAB_SERVER}.key 
openssl req -subj "/CN=${GITLAB_SERVER}" -new -key ${GITLAB_SERVER}.key -out ${GITLAB_SERVER}.csr
openssl x509 -req -in ${GITLAB_SERVER}.csr -CA ${CA_NAME}.cert -CAkey ${CA_NAME}.key \
             -CAcreateserial -out ${GITLAB_SERVER}.crt -days 3650 -sha256

#create a client key
openssl genrsa -nodes -out client.key 
openssl req -subj "/CN=client" -new -key client.key -out client.csr
openssl x509 -req -in client.csr -CA ${CA_NAME}.cert -CAkey ${CA_NAME}.key \
             -CAcreateserial -out client.crt -days 3650 -sha256

sudo mkdir -p  /mnt/data/gitlab/config/ssl
sudo chmod 700 /mnt/data/gitlab/config/ssl

sudo cp ${GITLAB_SERVER}.key /mnt/data/gitlab/config/ssl/
sudo cp ${GITLAB_SERVER}.crt /mnt/data/gitlab/config/ssl/
sudo cp ${CA_NAME}.cert /mnt/data/gitlab/config/trusted-certs/
