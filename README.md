the deployed nginx can be accessed through the link: http://k8s-default-nginxser-4a8caaaac2-ee297f1e5c5a69af.elb.ap-southeast-1.amazonaws.com


set your aws crendentail:

vim ~/.aws/credentials

add your credentails in this file from aws:

[default]
aws_access_key_id = AKIxxxxxxxxxxxxxxxx
aws_secret_access_key = 7U6c3hxxxxxxxxxxxx


terraform init
terraform apply -auto-approve




