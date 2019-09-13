#!/bin/bash
clear
# Checking permissions
if [[ $EUID -ne 0 ]]; then
   ee_lib_echo_fail "Sudo privilege required..."
   exit 100
fi

# Define echo function
# Blue color
function ee_lib_echo()
{
   echo $(tput setaf 4)$@$(tput sgr0)
}
# White color
function ee_lib_echo_info()
{
   echo $(tput setaf 7)$@$(tput sgr0)
}
# Red color
function ee_lib_echo_fail()
{
   echo $(tput setaf 1)$@$(tput sgr0)
}

# Execute: update
ee_lib_echo "Updating, please wait..."
yum -y update
yum group install "Development Tools" -y

# Execute: installing
ee_lib_echo "Installing webserver, please wait..."
yum -y install nginx wget

# install php 7
ee_lib_echo "Installing PHP 7, please wait..."
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum install -y yum-utils nano wget git unzip gcc make curl htop fail2ban epel-release mod_ssl python-certbot-apache composer
yum-config-manager --enable remi-php72
yum install -y php php-common php-dev php-xml php-mbstring php-pear php-fpm php-pecl-geoip php-devel geoip geoip-devel php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo
rm -f /etc/nginx/nginx.conf
curl -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/screamolic/conf-webserver/master/nginx.conf


sudo iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
service nginx start

echo "0 1 * * * reboot >/dev/null " >> /etc/crontab

systemctl restart crond.service
systemctl enable nginx.service
systemctl restart nginx.service

clear
ee_lib_echo "Cek Spesifikasi:"
php -v
nginx -v
