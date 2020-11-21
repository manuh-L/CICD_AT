##################################################################################
# VARIABLES
##################################################################################

#temp
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "private_key_path" {}
variable "key_name" {}
variable "user" {
    description = "user for ssh"
}
variable "tag_Name" {}
variable "tag_Role" {}
variable "instance_type" {}
variable "region" {}
variable "sec_name" {}
variable "aws_ami" {}
#variable "commit_hash" {}
#variable "region" {
#    default = "af-south-1"
#}

