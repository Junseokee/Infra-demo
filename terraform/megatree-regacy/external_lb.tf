## Application Load Balancer, 리스너 및 타겟 그룹 생성
#resource "aws_lb" "alb" {
#  name               = "project-external-alb"
#  internal           = false
#  load_balancer_type = "application"
#  security_groups    = [aws_security_group.alb_sg.id]
#  subnets            = aws_subnet.public_subnet.*.id
#}
#
#resource "aws_lb_target_group" "tg" {
#  name     = "project-tg"
#  port     = 80
#  protocol = "HTTP"
#  vpc_id   = aws_vpc.public_vpc.id
#}
#
#resource "aws_lb_listener" "listener" {
#  load_balancer_arn = aws_lb.alb.arn
#  port              = 80
#  protocol          = "HTTP"
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.tg.arn
#  }
#}
#
## ALB용 보안 그룹 (인바운드 HTTP 트래픽 허용)
#resource "aws_security_group" "alb_sg" {
#  vpc_id = aws_vpc.public_vpc.id
#
#  ingress {
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}