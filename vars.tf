variable "private_key_path" {
  default = "/Users/asherrankin/.ssh/nginx_key.pem"
}
variable "public_key_path" {
  default = "/Users/asherrankin/.ssh/nginx_key.pub"
}
variable "ec2_user" {
  default = "ubuntu"
}