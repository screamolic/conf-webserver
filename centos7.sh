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

# Execute: installing
ee_lib_echo "Installing webserver, please wait..."
yum -y install httpd

/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
/etc/rc.d/init.d/iptables save

service httpd start

# install php 7
ee_lib_echo "Installing PHP 7, please wait..."
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum install -y yum-utils nano wget git unzip gcc make curl htop
yum-config-manager --enable remi-php71
yum install -y httpd php php-common php-dev php-xml php-mbstring php-pear php-pecl-geoip php-devel geoip geoip-devel php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo
sudo pecl install geoip
rm -f /etc/httpd/conf/httpd.conf
wget -O /etc/httpd/conf/httpd.conf https://raw.githubusercontent.com/screamolic/conf-webserver/master/httpd-7.conf

#d install geoip
cd /usr/share/GeoIP
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
gunzip GeoIP.dat.gz

# Php version
echo -n "[In progress] Detect PHP version ..."
VER_PHP="$(command php --version 2>'/dev/null' \
   | command head -n 1 \
   | command cut --characters=5-7)"
sleep 3s
echo -e "\r\e[0;32m[OK]\e[0m Detect PHP version  : $VER_PHP   "

# Execute: installing ioncube
ee_lib_echo "Installing ioncube, please wait..."
cd /var/www/html
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xvfz ioncube*
cp /var/www/html/ioncube/ioncube_loader_lin_${VER_PHP}.so /usr/lib64/php/modules
echo "zend_extension = /usr/lib64/php/modules/ioncube_loader_lin_${VER_PHP}.so" >> /etc/php.d/00-ioncube.ini
service httpd restart
clear
ee_lib_echo "Cek Spesifikasi:"
php -v
httpd -v
