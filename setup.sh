#!/bin/bash
echo -n "Enter your domain name and press [ENTER]: "
read domain

sudo apt-get update

#Install SSH
sudo apt-get install ssh -y

#Install Apache, PHP, Unzip 
sudo apt-get install apache2 -y
sudo apt-get install php -y
sudo apt-get install libapache2-mod-php -y
sudo apt-get install php-mysql -y
sudo apt-get install php-gd php-mcrypt php-mbstring php-xml php-ssh2 php-curl php-zip php-intl -y
sudo apt-get install unzip -y

DB_ROOT_PASS='root'

# Install MySQL Server in a Non-Interactive mode. Default root password will be same DB_ROOT_PASS
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password $DB_ROOT_PASS'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $DB_ROOT_PASS'
sudo apt-get -y install mysql-server

#Download prestashop
wget https://download.prestashop.com/download/releases/prestashop_1.7.0.5.zip

#Extract prestashop to directory web
sudo unzip prestashop_1.7.0.5.zip -d /var/www/html/prestashop

# Change owenrship to www-data (webserver)
sudo chown -R www-data:www-data /var/www/html/prestashop

DB_Name='prestashop'
DB_User='prestashopuser'
DB_Pass='password@123Presta'

#Create database with DB_Name, DB_User, and DB_Pass
mysql -u root --password=$DB_ROOT_PASS <<MYSQL_SCRIPT
CREATE DATABASE $DB_Name;
CREATE USER '$DB_User'@'localhost' IDENTIFIED BY '$DB_Pass';
GRANT ALL PRIVILEGES ON $DB_Name.* TO '$DB_User'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "MySQL user created."
echo "Database Name	:   $DB_Name"
echo "Database Username	:   $DB_User"
echo "Database Password :   $DB_Pass"


#Configuring Apache web server for PrestaShop.
sudo a2enmod rewrite
sudo touch /etc/apache2/sites-available/prestashop.conf
sudo ln -s /etc/apache2/sites-available/prestashop.conf /etc/apache2/sites-enabled/prestashop.conf
sudo rm /etc/apache2/sites-enabled/prestashop.conf
sudo echo "<VirtualHost *:80>
ServerAdmin admin@$domain
DocumentRoot /var/www/html/prestashop/
ServerName $domain
ServerAlias www.$domain
<Directory /var/www/html/prestashop/>
Options FollowSymLinks
AllowOverride All
Order allow,deny
allow from all
</Directory>
ErrorLog /var/log/apache2/$domain-error_log
CustomLog /var/log/apache2/$domain-access_log common
</VirtualHost>" >> prestashop.conf
sudo cp prestashop.conf /etc/apache2/sites-enabled/
sudo rm prestashop.conf

#Restart Apache
sudo service apache2 restart
echo "PrestaShop Successfully Installed"
echo "Open your $domain or http://localhost/prestashop"
echo "Continue installation in your browser"
echo "Save this information"
echo "MYSQL Root Password : $DB_ROOT_PASS"
echo "Database Name	:   $DB_Name"
echo "Database Username	:   $DB_User"
echo "Database Password :   $DB_Pass"
