#!/bin/bash

echo "Welcome to this jitsi setup script. You only need to run this the first time you set up this machine or cloud vm.

Please enter the web address that you will access this jitsi server from (the one you chose at dynu.com). Do not include https:// at the beginning."
read WEB_ADDRESS
echo "Please enter your dynu.com login name"
read DYNU_LOGIN
echo "Please enter your dynu login password or your dynu IP address password"
read -s DYNU_PASS
echo "Please enter an email address for your SSL certificate lets-encrypt registration (they won't spam you)"
read LETS_ENCRYPT_EMAIL

# update OS
sudo apt-get update -y
sudo apt-get full-upgrade -y --allow-downgrades --allow-remove-essential --allow-change-held-packages && sudo touch /etc/startup_upgrade

# install and configure firewall
sudo apt-get install ufw -y
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 10000/udp
sudo ufw allow 22/tcp
sudo ufw allow 3478/udp
sudo ufw allow 5349/tcp
yes | sudo ufw enable

# setup dynamic dns for a nice web address  
yes | sudo apt-get install ddclient

sudo echo "# Configuration file for ddclient generated by debconf
#
# /etc/ddclient.conf
daemon=60                               # check every 60 seconds
syslog=yes                              # log update msgs to syslog
mail=root                               # mail all msgs to root
mail-failure=root                       # mail failed update msgs to root
pid=/var/run/ddclient.pid               # record PID in file.
ssl=yes                                 # use ssl-support.  Works with

protocol=dyndns2
use=web, web=checkip.dynu.com/, web-skip='IP Address'
server=api.dynu.com
login=$DYNU_LOGIN
password='$DYNU_PASS'
$WEB_ADDRESS" > /etc/ddclient.conf

sudo systemctl enable ddclient
sudo systemctl restart ddclient

# Install jitsi and dependencies
sudo apt-get install gnupg2 apt-transport-https software-properties-common -y
sudo apt-get install nginx -y
curl https://download.jitsi.org/jitsi-key.gpg.key | sudo sh -c 'gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg'
echo 'deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/' | sudo tee /etc/apt/sources.list.d/jitsi-stable.list > /dev/null
sudo apt-get update -y

echo "jitsi-videobridge jitsi-videobridge/jvb-hostname string $WEB_ADDRESS" | debconf-set-selections
echo "jitsi-meet jitsi-meet/cert-choice select Self-signed certificate will be generated" | debconf-set-selections
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install jitsi-meet -y

# Set up SSL certificates for encryption
echo "$LETS_ENCRYPT_EMAIL" | sudo bash /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh

