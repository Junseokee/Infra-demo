resource "aws_security_group" "app-cd-alb-sg" {
  name        = "ec2-sg"
  description = "Security group for project cd node"
  vpc_id      = data.terraform_remote_state.project-network-app.outputs.vpc_app

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 주의: 실제 사용 시에는 보안을 위해 이 값을 제한적인 IP 범위로 변경하세요.
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP에서 HTTP 접근 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # 모든 트래픽 허용
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-cd-SG"
  }
}


resource "aws_lb" "cd_alb" {
  name               = "project-cd-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app-cd-alb-sg.id] # ALB에 대한 보안 그룹 ID
  subnets            = tolist(data.terraform_remote_state.project-network-app.outputs.subnet_app[*])

  enable_deletion_protection = false

  tags = {
    Name = "project-cd-alb"
  }
}

resource "aws_lb" "project_alb" {
  name               = "project-app-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app-cd-alb-sg.id] # ALB에 대한 보안 그룹 ID
  subnets            = tolist(data.terraform_remote_state.project-network-app.outputs.subnet_app[*])

  enable_deletion_protection = false

  tags = {
    Name = "project-app-alb"
  }
}

#resource "aws_lb_listener" "cd_listener" {
#  load_balancer_arn = aws_lb.cd_alb.arn
#  port              = 443
#  protocol          = "HTTPS"
#  certificate_arn   = "arn:aws:acm:ap-northeast-2:000982191218:certificate/51ecfbb6-069d-4643-b3df-ae07a093a524"
#  default_action {
#    type = "redirect"
#
#    redirect {
#      port        = "80"
#      protocol    = "HTTP"
#      status_code = "HTTP_301"
#    }
#  }
#}

resource "aws_lb_listener" "cd_listener" {
  load_balancer_arn = aws_lb.cd_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "page not found"
      status_code  = "404"
    }
  }
}