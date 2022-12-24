PRE-REQUISITES:

1. Clone our code.

git clone git@github.com:hdavila-silva/ACS-Group11-FinalProject.git

2. Create ssh keys for each environment.

infrastructure/dev/webserver
ssh-keygen -t rsa -f devkey
chmod 400 devkey*

infrastructure/staging/webserver
ssh-keygen -t rsa -f stagingkey
chmod 400 stagingkey*

infrastructure/prod/webserver
ssh-keygen -t rsa -f prodkey
chmod 400 prodkey*

TASKS TO TEST CODE:

1. Create S3 buckets needed for the project:

cd ACS-Group11-FinalProject/infrastructure/s3/
terraform init
terraform apply --auto-approve

2. Upload two images to S3 bucket: group11-webpage-bucket

ACS-Group11-FinalProject/infrastructure/s3/ilovecats.jpg
ACS-Group11-FinalProject/infrastructure/s3/ilovedogs.jpg

Note: please enable Read access in object AC

3. Deploy and validate development environment:

ACS-Group11-FinalProject/infrastructure/dev/networking/
terraform init
terraform apply --auto-approve

ACS-Group11-FinalProject/infrastructure/dev/webservers/
terraform init
terraform apply --auto-approve

Browse the load balancer url and refresh several times.

4. Deploy and validate staging environment:

ACS-Group11-FinalProject/infrastructure/staging/networking/
terraform init
terraform apply --auto-approve

ACS-Group11-FinalProject/infrastructure/staging/webservers/
terraform init
terraform apply --auto-approve

Browse the load balancer url and refresh several times.

4. Deploy and validate the production environment:

ACS-Group11-FinalProject/infrastructure/prod/networking/
terraform init
terraform apply --auto-approve

ACS-Group11-FinalProject/infrastructure/prod/webservers/
terraform init
terraform apply --auto-approve

Browse the load balancer url and refresh several times.


This is it... Thank you for teaching us this.

Happy Holidays
Group11
Hector / Kristoffer / Harmandeep / Manish

