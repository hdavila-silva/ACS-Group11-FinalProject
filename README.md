# README.md for staging environment

PRE-REQUISITES:

1. Clone our code.

git clone git@github.com:hdavila-silva/ACS-Group11-FinalProject.git

2. Create ssh keys for each environment.

cd ACS-Group11-FinalProject/infrastructure/staging/webservers
ssh-keygen -t rsa -f stagingkey
chmod 400 stagingkey*

TASKS TO TEST CODE:

1. Create S3 buckets needed for the project:

cd ACS-Group11-FinalProject/infrastructure/s3/
terraform init
terraform apply --auto-approve

2. Upload two images to S3 bucket: group11-webpage-bucket located here:

ACS-Group11-FinalProject/infrastructure/s3/ilovecats.jpg
ACS-Group11-FinalProject/infrastructure/s3/ilovedogs.jpg

Note: please enable Read access in object ACLs

3. Deploy and validate development environment:

cd ACS-Group11-FinalProject/infrastructure/staging/networking/
terraform init
terraform apply --auto-approve

cd ACS-Group11-FinalProject/infrastructure/staging/webservers/
terraform init
terraform apply --auto-approve

Browse the load balancer url and refresh several times.

This is it... Thank you for teaching us this.

Happy Holidays
Group11
Hector / Kristoffer / Harmandeep / Manish