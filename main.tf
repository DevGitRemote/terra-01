provider "aws" {
  region = "us-east-1" 
  access_keys = ""
  secret_keys = ""
}
resource "aws_instance" "ec2" {
  ami = ""
  instance_type = ""
  user_data = <<-EOL
  #!/bin/bash -xe
  sudo apt-get update
  sudo apt-get install apache2
  EOL
  subnet_id = "${aws_subnet.publicsubnet.id}"
  tags = {
  Name = "bastion-server"
  }
}
resource "aws_vpc" "myvpc" {
  cidr_block = ""
  enable_dns_support = "1"
  enable_dns_hostnames = "1"
  tags = {
  Name = "terra-case-study"
  }
}
resource "aws_subnet" "publicsubnet" {
  cidr_block = ""
  availability_zone = ""
  map_public_ip_on_launch = 1
  vpc_id = "${aws_vpc.myvpc.id}"
  tags = {
  Name = "sub1"
  }
}
resource "aws_default_security_group" "default-sg" {
  ingress {
    from_port = 0
	to_port = 0
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
	to_port = 0
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.myvpc.id}"
  tags = {
  Name = "allow_all"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.myvpc.id}"
  tags = {
  Name = "myvpc-igw"
  }
}
resource "aws_route" "internet" {
  subnet_id = "${aws_subnet.publicsubnet.id}"
  route_table_id = "${aws_vpc.myvpc.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"
}
resource "aws_route_table_association" "a" {
  subnet_id = "${aws_subnet.publicsubnet.id}"
  route_table_id = "${aws_vpc.myvpc.default_route_table_id}"
}
resource "aws_network_interface" "first" {
  subnet_id = "${aws_subnet.publicsubnet.id}"
  tags = {
      Name = "mynetworkinterface"
          }

}

resource "aws_network_interface_attachment" "connection" {
  instance_id          = "${aws_instance.ec2.id}"
  network_interface_id = "${aws_network_interface.first.id}"
  device_index         = 1
}

output "IPs" {
  value = "Terraform-casestudy -  ${aws_instance.firstec2.public_ip}"
}
  
