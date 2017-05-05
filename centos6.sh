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
yum -y update &>> /dev/null

# Execute: installing
ee_lib_echo "Installing webserver, please wait..."
yum -y install httpd &>> /dev/null
service httpd start &>> /dev/null
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT &>> /dev/null
/etc/rc.d/init.d/iptables save &>> /dev/null
yum install epel* &>> /dev/null
yum update &>> /dev/null

# yum -y install php php-common php-xml php-mbstring unzip curl wget htop &>> /dev/null

wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm &>> /dev/null
sudo rpm -Uvh remi-release-6*.rpm &>> /dev/null
yum -y update &>> /dev/null
yum -y install --enablerepo=remi,remi-php56  &>> /dev/null
yum -y --enablerepo=remi,remi-php56 update &>> /dev/null
yum -y --enablerepo=remi,remi-php56 upgrade &>> /dev/null
chkconfig httpd on &>> /dev/null
rm -f /etc/httpd/conf/httpd.conf
wget -O /etc/httpd/conf/httpd.conf https://pastebin.com/raw/k0exPpa4 &>> /dev/null



# Php version
echo -n "[In progress] Detect PHP version ..."
VER_PHP="$(command php --version 2>'/dev/null' \
   | command head -n 1 \
   | command cut --characters=5-7)"
sleep 3s
echo -e "\r\e[0;32m[OK]\e[0m Detect PHP version  : $VER_PHP   "

# Execute: installing ioncube
ee_lib_echo "Installing ioncube, please wait..."
cd /var/www/html &>> /dev/null
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz &>> /dev/null
tar xvfz ioncube* &>> /dev/null
cp /var/www/html/ioncube/ioncube_loader_lin_${VER_PHP}.so /usr/lib64/php/modules &>> /dev/null
echo "zend_extension = /usr/lib64/php/modules/ioncube_loader_lin_${VER_PHP}.so" >> /etc/php.d/00-ioncube.ini
service httpd restart &>> /dev/null

ee_lib_echo "beres..."
php -v
ee_lib_echo_info "silahkan akses http://ip-address/ioncube/loader-wizard.php"
