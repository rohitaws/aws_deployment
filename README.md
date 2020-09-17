# aws_deployment
CI/CD via terraform

Centralized automation server or Jenkins server required with terraform packages pre-installed.

Fetch the startup.sh script from github and store in the Jenkins/automation server.

Execute the main.tf file via Jenkins job/automation server. (Fetch the code from github).

The code main.tf helps in bootstrapping the ec2 instance with the following packages installed.
(httpd, php, php-mysql, php-gd, php-xml, mariadb-server, mariadb, php-mbstring, wget)

Once the instance created the startup.sh (shell script) will be pushed into the server and will execute the configuration.

Then, with successful completion mediawiki website will be accessible.

