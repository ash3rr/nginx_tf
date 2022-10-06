resource "aws_vpc" "nginx-vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "dev-subnet" {
  vpc_id                  = aws_vpc.nginx-vpc.id // Referencing the id of the VPC from above
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = "true" // public on startup
  availability_zone       = "eu-central-1b"

  tags = {
    Name = "Dev-public-subnet"
  }
}

resource "aws_internet_gateway" "prod-igw" { // allow vm to access internet 
  vpc_id = aws_vpc.nginx-vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "dev-rt-public" { // route traffic from subnet to internet gateway 
  vpc_id = aws_vpc.nginx-vpc.id
  route {
    cidr_block = "0.0.0.0/0" //associated subnet can reach everywhere
    gateway_id = aws_internet_gateway.prod-igw.id
  }
  tags = {
    Name = "dev-public-rt"
  }
}

resource "aws_route_table_association" "rta-public" { // bridges the gap between a route table and a subnet 
  subnet_id      = aws_subnet.dev-subnet.id
  route_table_id = aws_route_table.dev-rt-public.id
}

resource "aws_security_group" "dev-sg" {
  vpc_id = aws_vpc.nginx-vpc.id

  ingress { // all traffic
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                                     // all protocols
    cidr_blocks = ["37.47.187.125/32", "212.146.63.50/32"] // 32 = only this ip 
  }

  # ingress { // ssh
  #     from_port = 22
  #     to_port = 22
  #     protocol = "tcp"
  #     cidr_blocks = ["37.47.185.207/32","212.146.63.50/32"] // 32 = only this ip 
  # }
  # ingress { // http
  #     from_port   = 80
  #     to_port     = 80
  #     protocol    = "tcp"
  # cidr_blocks = ["37.47.185.207/32","212.146.63.50/32"] // 32 = only this ip 
  #   }
  # ingress { // https
  #     from_port   = 443
  #     to_port     = 443
  #     protocol    = "tcp"
  # cidr_blocks = ["37.47.185.207/32","212.146.63.50/32"] // 32 = only this ip 
  #   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"] // it can access anything outside 
  }
}

resource "aws_key_pair" "aws-key" {
  key_name   = "aws-key"
  public_key = file(var.public_key_path) // pulled from vars.tf
}

resource "aws_instance" "nginx_server" {
  ami                    = "ami-0b1077098d8cb5431"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.dev-subnet.id // subnet
  vpc_security_group_ids = [aws_security_group.dev-sg.id]
  key_name               = aws_key_pair.aws-key.id
  user_data              = file("userdata.tpl")
  
  tags = {
    Name = "nginx_server"
  }
  

  # Setting up the ssh connection to install the nginx server
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("${var.private_key_path}")
  }
}