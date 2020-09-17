#!/bin/bash
sudo yum install -y httpd php php-mysql php-gd php-xml mariadb-server mariadb php-mbstring wget
sudo systemctl start mariadb
sudo bash -c 'echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('admin');" | mysql -u root'
sudo bash -c 'echo "UPDATE mysql.user SET authentication_string = PASSWORD('admin') WHERE User = 'root' AND Host = 'localhost';" |  mysql -u root -padmin'
sudo bash -c 'mysql -u root -p"admin" -e "CREATE USER 'wiki'@'localhost' IDENTIFIED BY 'THISpasswordSHOULDbeCHANGED';"'
sudo bash -c 'mysql -u root -p"admin" -e "GRANT ALL PRIVILEGES ON wikidatabase.* TO 'wiki'@'localhost';"'
sudo bash -c 'mysql -u root -p"admin" -e "FLUSH PRIVILEGES"'
sudo bash -c 'mysql -u root -p"admin" -e "SHOW DATABASES;" >>/home/output.txt'
sudo bash -c 'mysql -u root -p"admin" -e "SHOW GRANTS FOR 'wiki'@'localhost';" >>/home/output.txt'
sudo systemctl enable mariadb
sudo systemctl enable httpd
sudo wget https://releases.wikimedia.org/mediawiki/1.34/mediawiki-1.34.2.tar.gz .
sudo bash -c 'tar -zxf mediawiki-1.34.2.tar.gz'
sudo bash -c 'mv mediawiki-1.34.2 /var/www | ln -s mediawiki-1.34.2/ mediawiki'
sudo bash -c 'chown -R apache:apache /var/www/mediawiki-1.34.2'
sudo bash -c 'chown -R apache:apache /var/www/mediawiki'
sudo service httpd restart
sudo bash -c 'sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config'
sudo bash -c 'firewall-cmd --permanent --zone=public --add-service=http'
sudo bash -c 'firewall-cmd --permanent --zone=public --add-service=https'
sudo systemctl restart firewalld
sudo bash -c 'restorecon -FR /var/www/mediawiki-1.34.2/'
sudo bash -c 'restorecon -FR /var/www/mediawiki'
sudo bash -c 'sed -i 's/index.html/index.html index.html.var index.php/g' /etc/httpd/conf/httpd.conf'
sudo systemctl restart httpd
