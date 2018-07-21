#!/bin/bash
clear
# ScreamEngine installer script.
# This script is designed to install latest apache + php depend you choose
echo -n "Enter the PHP version (56 / 70 / 71 / 72) : "
read -e phpv

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

# Capture errors
function ee_lib_error()
{
    echo "[ `date` ] $(tput setaf 1)$@$(tput sgr0)"
    exit $2
}

# Checking lsb_release package
if [ ! -x /usr/bin/lsb_release ]; then
    ee_lib_echo "Installing lsb-release, please wait..."
    yum install redhat-lsb-core redhat-lsb -y &>> /dev/null
fi

# Define variables for later use
ee_branch=$1
readonly linux_distro=$(lsb_release -i | awk '{print $3}')
readonly distro_version_number=$(lsb_release -d | awk '{print $4}')

# Execute: apt-get update
ee_lib_echo "Executing apt-get update, please wait..."
yum -y update &>> /dev/null

ee_lib_echo "Installing Some Tools terminal usefull..."
apt-get install nano -y &>> /dev/null
apt-get install htop -y &>> /dev/null
apt-get install zip -y &>> /dev/null 
apt-get install fail2ban -y &>> /dev/null
apt-get install unzip -y &>> /dev/null
apt-get install curl libcurl3 libcurl3-dev -y &>> /dev/null
apt-get install bc -y &>> /dev/null


# Checking centos version
lsb_release -d | egrep -e "6.9|6.10" &>> /dev/null
if [ "$?" -ne "0" ]; then
		ee_lib_echo "Installing webserver, please wait..."
		yum -y install httpd composer  &>> /dev/null
		rm -f /etc/httpd/conf/httpd.conf
		wget -O /etc/httpd/conf/httpd.conf https://raw.githubusercontent.com/screamolic/conf-webserver/master/httpd.conf
		service httpd start
		/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
		/etc/rc.d/init.d/iptables save

		#php 5.6
		if [ "$phpv" == "56" ]; then
			ee_lib_echo "Installing PHP 5.6, please wait..."
			yum -y install php php-common php-xml php-mbstring unzip curl wget htop git
			yum -y install epel*
			wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
			sudo rpm -Uvh remi-release-6*.rpm
			yum -y update
			yum -y --enablerepo=remi,remi-php56 update
			yum -y --enablerepo=remi,remi-php56 upgrade
			chkconfig httpd on
		fi

		#php 7.0
		if [ "$phpv" == "70" ]; then
			ee_lib_echo "Installing PHP 7.0, please wait..."
			yum-config-manager --enable remi-php70
			yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-common php-xml php-mbstring unzip curl wget htop git
			chkconfig httpd on
		fi
		#php 7.1
		if [ "$phpv" == "71" ]; then
			ee_lib_echo "Installing PHP 7.0, please wait..."
			yum-config-manager --enable remi-php71
			yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-common php-xml php-mbstring unzip curl wget htop git
			chkconfig httpd on
		fi
		#php 7.2
		if [ "$phpv" == "72" ]; then
			ee_lib_echo "Installing PHP 7.0, please wait..."
			yum-config-manager --enable remi-php72
			yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-common php-xml php-mbstring unzip curl wget htop git
			chkconfig httpd on
		fi
fi

# Checking centos version
if [ "$distro_version_number" == "7" ]; then
		ee_lib_echo "Installing webserver, please wait..."
		yum -y install httpd composer  &>> /dev/null
		/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
		/etc/rc.d/init.d/iptables save
		sudo firewall-cmd --zone=public --add-service=http
		sudo firewall-cmd --zone=public --permanent --add-service=http
		sudo firewall-cmd --zone=public --add-service=https
		sudo firewall-cmd --zone=public --permanent --add-service=https
		service httpd start
		rm -f /etc/httpd/conf/httpd.conf
		wget -O /etc/httpd/conf/httpd.conf https://raw.githubusercontent.com/screamolic/conf-webserver/master/httpd-7.conf


		#php 7.1
		if [ "$phpv" == "7.1" ]; then
			ee_lib_echo "Installing PHP 7.1, please wait..."
			yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
			yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
			yum install -y yum-utils nano wget git unzip gcc make curl htop
			yum-config-manager --enable remi-php71
			yum install -y httpd php php-common php-dev php-xml php-mbstring php-pear php-pecl-geoip php-devel geoip geoip-devel php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo
			sudo pecl install geoip
		fi

fi

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
rm -rf ioncube*
systemctl enable httpd.service
systemctl restart httpd.service
clear
ee_lib_echo "Cek Spesifikasi:"
php -v
httpd -v
