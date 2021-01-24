##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {}
#  access_key = var.aws_access_key
#  secret_key = var.aws_secret_key
#  region     = var.region


##################################################################################
# DATA
##################################################################################

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["self"]
  name_regex       = "web*"

  filter {
    name   = "name"
    values = ["webs*"]
  }

 # filter {
 #   name   = "name"
 #   values = ["webserver"]
  #}

#   filter {
 #   name   = "Description"
 #   values = ["Apache"]
#  }

tags = {
  "Name" = "Apache_latest"
}

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

   filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  

}

##################################################################################
# RESOURCES
##################################################################################


resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "allow_ssh" {
  name        = var.sec_name
  description = "Allow ports 22 & 80 aws"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  } 
}

resource "aws_instance" "apache_terraform" {
  count = 2
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
      Name = "${var.tag_Name} ${count.index}"
#            Role = var.tag_Role [count.index]

  }

  

  connection {
    type        = "ssh"
    user        = var.user
    host        = self.public_ip    
    private_key = file(var.private_key_path)

  }


  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      
    ]
  }


    provisioner "local-exec" {
    command = "chmod 400 ./PrivateSvr.pem"
  }

#Creates inventory for ansible
  provisioner "local-exec" {
      command = <<EOD
 cat <<EOF > inv.ini
[web] 
${aws_instance.apache_terraform.*.public_ip }
[web:vars]
ansible_user=${var.user}
ansible_ssh_private_key_file=${var.private_key_path}
EOF
EOD
  }
# "${var.azure_bastionserver}${format("%02d", count.index + 1)}"



#executes ansible playbook to install apache
#  provisioner "local-exec" {
#    command = "ansible-playbook -i inv.ini apache.yml"
#  }

}
