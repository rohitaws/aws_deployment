##configure AWS

provider "aws" {
  region  = "us-east-2"
  access_key = ""
  secret_key = ""
}

##Create VPC

resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
     name = "app_vpc"
  }
}

##Create Subnet

resource "aws_subnet" "app_subnet" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "10.0.1.0/24"
  #availability_zone  = "us-east-2a"
  tags = {
     name = "app_subnet"
  }
}

##Create Gateway

resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "app_igw"
  }
}

##Create Route table

resource "aws_route_table" "app_rt" {
  vpc_id =  aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }

  tags = {
    Name = "app_rtable"
  }
}

##Attch route table to Subnet

resource "aws_route_table_association" "app_rsa" {
  subnet_id      = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app_rt.id
}

##Create security group & Allow Traffic

resource "aws_security_group" "app_sg" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 2
    to_port     = 2
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app sec_grp"
  }
}


##Creating a Network Interface

resource "aws_network_interface" "app-nic" {
  subnet_id       = aws_subnet.app_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.app_sg.id]
}

##Elastic ip

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.app-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.app_igw]
}

##Lauch Instance

resource "aws_instance" " "new-server" {
  ami           = "ami-0603cbe34fd08cb81"
  instance_type = "t2.micro"
  key_name =""
  subnet_id = aws_subnet.app_subnet.id
    
 network_interface {
    network_interface_id = aws_network_interface.app-nic.id
    device_index = 0
  }
  
  user_data = <<-EOF 
              #!/bin/bash
			  sudo yum install -y httpd php php-mysql php-gd php-xml mariadb-server mariadb php-mbstring wget
			  sudo systemctl start mariadb
			  sudo systemctl enable mariadb
			  sudo systemctl enable httpd
			  EOF
			  
  provisioner "file" {
    source      = "/home/rohit/startup.sh"
    destination = "/tmp/startup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/startup.sh",
      "sudo /tmp/startup.sh args",
    ]
  }
}
