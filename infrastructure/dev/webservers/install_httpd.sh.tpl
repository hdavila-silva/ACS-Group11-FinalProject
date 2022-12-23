#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

 

cat > /var/www/html/index.html <<EOL
<html>
<head>
<meta charset="utf-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
<link rel="shortcut icon" href="#">
<title>Welcome to Group11's Cats and Dogs website in ${env} environment!</title>
</head>
<style media="screen">
  body {
          background-color: #003153;
          font-size: 30pt;
          color: white;
    }
</style>
<body>

<div class="container-fluid">
<div id="one" class="text-center">
<span>Welcome to Group11's Cats and Dogs website in ${env} environment!</span>
</div>
<div class="row">
<div class="col-md-6 text-center">
<a href="../cats/"><img src="https://group11-webpage-bucket.s3.amazonaws.com/ilovecats.jpg" width="300" height="300" alt="..." class="img-rounded"></a>
</div>
<div class="col-md-6 text-center">
<a href="../dogs/"><img src="https://group11-webpage-bucket.s3.amazonaws.com/ilovedogs.jpg" width="300" height="300" alt="..." class="img-rounded"></a>
</div>

 


<div class="container-fluid">
<div id="one" class="text-center">
<span>$myip</span>
</div>

 

 

    
<p style="margin: 10px">
<div id="one" style="text-align: left;margin: 10px;">
<span>Group Members:</span>
</div>
<div style="text-align: left;margin: 15px;">
<a>Hector</a>   
<div style="text-align: left;margin: 15px;">       
</div>
<a>Manish</a>  
<div style="text-align: left;margin: 15px;">      
</div>
<a>Harman</a>  
<div style="text-align: left;margin: 15px;">
</div>
<a> Kristoffer</a>  

</div>
</div>
</div>
</p>
</body>
</html>
EOL
sudo systemctl start httpd
sudo systemctl enable httpd