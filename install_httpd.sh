#!/bin/bash
#yum -y update
#yum -y install httpd
#myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
#echo "<h1>Hello world! My private IP is $myip</h1>"  >  /var/www/html/index.html
#sudo systemctl start httpd
#sudo systemctl enable httpd

#!/bin/bash
apt update -y
apt install apache2 -y
systemctl start apache2
systemctl enable apache2
sudo echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
apt install stress -y