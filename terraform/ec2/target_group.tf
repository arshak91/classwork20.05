
resource "aws_lb_target_group" "web" {
  name     = "ExampleTargetGroup"
  port     = 80  # Replace with the desired port
  protocol = "HTTP"
  vpc_id   = "vpc-12345678"  # Replace with the desired VPC ID
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn  = aws_lb_target_group.web.arn
  target_id         = aws_instance.web.id
  port              = 80  # Replace with the desired port
}