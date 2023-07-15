
variable "private_key_path" {
  type    = string
  default = "~/.ssh/virginia.pem"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type    = string
  default = "ami-007855ac798b5175e"
}
variable "name" {
  type    = string
  default = "Test"
}


# Create an EC2 instance
resource "aws_instance" "web" {
  ami           = "${data.aws_ami.web.id}"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.web.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name      = "virginia"
  tags = {
    Name = "${var.name}"
  }
}

output "EC2_Instance_Public_IP" {
  value = aws_instance.web.public_ip
}
output "EC2_Instance_Public_DNS" {
  value = aws_instance.web.public_dns
}
# "sudo scp -i ./Desktop/pem/virginia.pem ./Desktop/pem/virginia.pem ubuntu@${self.public_dns}:/home/ubuntu"