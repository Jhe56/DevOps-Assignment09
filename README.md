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
Now that terraform apply is done running you should see an output (that can always be printed again with **terraform output**)
```
bastion_public_dns = "ec2-**-***-187-159.compute-1.amazonaws.com"
bastion_public_ip = "bastion-ip"
observer_id = "observer-instance-id"
observer_ip = "observer-instance-ip"
private_instance_ids = [
  "private-instance-01",
  "private-instance-02",
  "private-instance-03",
  "private-instance-04",
  "private-instance-05",
  "private-instance-06",
]
private_instance_private_ips = [
  "PI-01-IP",
  "PI-01-IP",
  "PI-01-IP",
  "PI-01-IP",
  "PI-01-IP",
  "PI-01-IP",
]
```
To ssh into bastion you must temporarily "forward" your "local ssh agent" telling it, "USE THIS KEY":

**ssh-add ~/.ssh/[your ssh name (same as what you created at the beginning)]**
**ssh-add -l**

Now you can ssh into your bastion using the following:

**ssh -A -i ~/.ssh/assignment08-key.pem ec2-user@<BASTION_PUBLIC_IP>**

And then ssh into your ec2 instance with:
**ssh ec2-user@<INSTANCE_IP>**

For further confirmation you can check if docker is available by running **docker version** 

To exit out of the ec2 instance and return to the bastion you can just hit Ctrl+D and again if you wish to exit out of the bastion.

## Observer Instance
After ssh'ing into bastion and then into your observer instance you'll want to check that docker is running images of grafana and prometheus using the command:
**docker ps -a**
<img width="2527" height="262" alt="image" src="https://github.com/user-attachments/assets/b40fd271-d805-482f-acf1-a2f4300cd8fe" />

Once confirmed you can step back to your local machine and run:
```
ssh -A -i ~/.ssh/YOUR KEY PAIR.pem \
  -L 9090:YOUR OBSERVER IP:9090 \
  -L 3000:YOUR OBSERVER IP:3000 \
  ec2-user@YOUR BASTION IP
```
And this will use your key pair to ssh into your bastion but also link your localhost port 9090 and 3000 to your observer's ports. Following those links will bring you to prometheus (here you can check the state of your instances and check if node extrator is down for any of them):
<img width="2450" height="836" alt="image" src="https://github.com/user-attachments/assets/3767c9c6-bc45-47ca-9cbf-ad688dc13010" />

And Grafana where you can login with admin/admin (You can choose whether or not to set a more official password.): 
<img width="2430" height="913" alt="image" src="https://github.com/user-attachments/assets/5a558f47-5187-41cc-91e8-6ad97a2eb41a" />

## Prometheus and Grafana
Then from there you can navigate through connections > datasources and select prometheus and input:
**http:\\YOUR OBSERVER IP:9090**
<img width="2428" height="1070" alt="image" src="https://github.com/user-attachments/assets/5d0ae024-8b7b-4507-934b-11d19a6dd29d" />
<sub>It won't work with http:\\localhost:9090</sub>

Scroll further down and hit save before you navigate to dashboard and create new visualizations of your instances' metrics
<img width="2447" height="1231" alt="image" src="https://github.com/user-attachments/assets/b26e50e6-8590-48ee-b42b-3a00edd726b5" />

You'll be redirected here where, upon clicking the blue button, you'll select prometheus (our only datasource):
<img width="1817" height="508" alt="image" src="https://github.com/user-attachments/assets/54e41ab4-81a5-4411-8089-fa087e820249" />
<img width="1965" height="661" alt="image" src="https://github.com/user-attachments/assets/aba9616d-328a-4784-aaa8-0a8889753681" />

And then be taken to your first panel:
<img width="2432" height="1357" alt="image" src="https://github.com/user-attachments/assets/153e8651-d44d-4e4b-afd4-d0bb4bd7bcf9" />

Here you can edit how the data is displayed, and at the very bottom add or remove the metrics you want to query.

For example: **CPU Utilization - node_cpu_seconds_total**
<img width="2407" height="1028" alt="Screenshot 2026-04-01 090854" src="https://github.com/user-attachments/assets/c1c9cac9-9a22-49ee-b6eb-325f5ed41928" />

And: **Memory Utilization/bytes available - node_memory_MemAvailable_bytes**
<img width="2414" height="1028" alt="Screenshot 2026-04-01 090757" src="https://github.com/user-attachments/assets/49c46fef-2014-4b4a-905a-ffe3984e217f" />
