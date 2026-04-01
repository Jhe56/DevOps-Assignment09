# Packer, Terraform, Prometheus, and Graphana
Based on 
Note: In this repo is a packer and terraform directory. After going through the packer steps, in /terraform/variables.tf change any [YOUR PUBLIC IP] and/or [YOUR AMI ID] to the expected values before proceeding with the terraform instructions

## Getting Started
* Ubuntu/WSL users must install HashiCorp's latest version of Packer and Terraform
* User should also have an ssh key and a key-pair created in their ~/.ssh directory
* Users should also have run [aws configure] and input their aws academy credentials

## Packer
In the packer directory run the following commands:
* packer init amazon-linux.pkr.hcl
* packer build -var "public_key_path=/YOUR PUBLIC KEY PATH/.ssh/id_rsa.pub" amazon-linux.pkr.hcl

Running that last command should start the AMI build process and start with:
<img width="881" height="59" alt="image" src="https://github.com/user-attachments/assets/3d47ac84-1cf2-45ea-b481-9e0baf02e6c0" />

Ending with:
<img width="603" height="48" alt="image" src="https://github.com/user-attachments/assets/5593969b-75cc-4cd6-8df5-a35b9ee5f381" />

Don't be alarmed by anything else. If an error comes up, make sure you've run aws configure and pasted in your credentials correctly, no preceeding or trailing new lines!

During the process you'll see a "transaction summary" of the the following installations being packaged:
<img width="1928" height="861" alt="image" src="https://github.com/user-attachments/assets/c1673a1b-fea8-47e3-8c5c-1e7d9415afba" />

To tell our EC2 instances: "THIS should be here" 
They can also be viewed/edited in our .hcl file, ln 40, in build{...}

At some point the process may hang for 4-6 minutes, with the message:
<img width="1045" height="40" alt="image" src="https://github.com/user-attachments/assets/a480d1c2-0979-4d65-b42e-ff25f9b63d32" />

Just let it run, and at the very end it will spit out your AMI ID, which you can also view in aws ec2 under AMIs

## Terraform
In the terraform directory:
* (refer to top note) Replace ANY and ALL [YOUR PUBLIC IP] and/or [YOUR AMI ID] in the files variables.tf and terraform.tfvars
Run:
* terraform init:
<img width="1540" height="358" alt="image" src="https://github.com/user-attachments/assets/37e89853-75e7-447a-ac21-3d2b1824af1e" />

* terraform apply -> double checks configuration and replaces existing EC2 instances / creates a number (6) of new ones.

This number can be viewed/edited on line 84 of our main.tf

At the end, users should see green text saying output with our bastion's public dns, ip, and our private instances' ids and ips.

Running terraform apply after the first run will prompt terraform to check for any changes that needs to be made and output (numbers change from zero to the number of changes made to the configuration files in our terraform directory):
<img width="1154" height="154" alt="image" src="https://github.com/user-attachments/assets/5726a7ba-2b00-4391-9086-be4a2b64e15d" />

## SSH Instructions
To ssh into bastion you must temporarily "forward" your "local ssh agent" telling it, "USE THIS KEY":

**ssh-add ~/.ssh/[your ssh name (same as what you created at the beginning)]**
**ssh-add -l**

Now you can ssh into your bastion using the following:

**ssh -A -i ~/.ssh/assignment08-key.pem ec2-user@<BASTION_PUBLIC_IP>**

And then ssh into your ec2 instance with:
**ssh ec2-user@<Private_IP>**

For further confirmation you can check if docker is available by running **docker version** 

To exit out of the ec2 instance and return to the bastion you can just hit Ctrl+D and again if you wish to exit out of the bastion.
