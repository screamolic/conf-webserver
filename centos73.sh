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

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
yum -y install epel-release nano git unzip wget htop

# Execute: update
ee_lib_echo "Updating, please wait..."
yum -y update
clear

# Execute: installing
ee_lib_echo "Installing webserver, please wait..."
yum -y install httpd
systemctl start httpd.service
systemctl enable httpd.service


ee_lib_echo "Installing php7.1, please wait..."
rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install yum-utils
yum -y update
yum-config-manager --enable remi-php71
yum -y install php php-common php-opcache php-xml php-mbstring php-gd php-ldap php-odbc php-pear php-xmlrpc php-soap curl curl-devel
systemctl restart httpd.service

chkconfig httpd on

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
rm -rf /var/www/html/ioncube*
clear
ee_lib_echo "Cek Spesifikasi PHP & IONCUBE:"
php -v
httpd -v
