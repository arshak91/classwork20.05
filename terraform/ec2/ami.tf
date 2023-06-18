
data "aws_ami" "web" {
  most_recent      = true
  owners           = ["self"]
}