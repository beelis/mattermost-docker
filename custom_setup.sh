#!/bin/sh

# install docker
sudo apt-get update
sudo apt-get install wget
wget -qO- https://get.docker.com/ | sh
sudo usermod -aG docker simon
sudo service docker start
newgrp docker

# install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# build mattermost
sudo apt-get install git
git clone https://github.com/mattermost/mattermost-docker.git
cd mattermost-docker
docker-compose build

# create self signed cert and copy to destination
# https://letsencrypt.org/de/docs/certificates-for-localhost/
mkdir -pv ./volumes/app/mattermost/{data,logs,config,plugins,client-plugins}
sudo chown -R 2000:2000 ./volumes/app/mattermost/
openssl req -x509 -out /home/simon/cert/localhost.crt -keyout /home/simon/cert/key-no-password.pem -newkey rsa:2048 -nodes -days 1000 -sha256 -subj '/CN=localhost' -extensions EXT -config <( printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
openssl x509 -in /home/simon/cert/localhost.crt -out /home/simon/cert/cert.pem -outform PEM
rm -f /home/simon/cert/localhost.crt
cp -a /home/simon/cert/. /home/simon/mattermost-docker/volumes/web/cert

# start mattermost
docker-compose up -d
