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
# Define variables for later use
ee_branch=$1
readonly ee_linux_distro=$(lsb_release -i | awk '{print $3}')
readonly ee_distro_version=$(lsb_release -sc)

# Checking linux distro
if [ "$ee_linux_distro" != "CentOS" ]; then
    ee_lib_echo_fail "iki Go Centos tok Cok!!!!!"
    exit 100
fi

# Execute: update
ee_lib_echo "Updating, please wait..."
yum -y update

# Execute: installing
ee_lib_echo "Installing webserver, please wait..."
yum -y install httpd
service httpd start
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
/etc/rc.d/init.d/iptables save
yum -y install php php-common php-xml php-mbstring unzip curl wget htop
yum install epel*

wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
sudo rpm -Uvh remi-release-6*.rpm

yum -y update
yum -y --enablerepo=remi,remi-php56 update
yum -y --enablerepo=remi,remi-php56 upgrade
chkconfig httpd on
rm -f /etc/httpd/conf/httpd.conf
wget -O /etc/httpd/conf/httpd.conf https://pastebin.com/raw/k0exPpa4

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
