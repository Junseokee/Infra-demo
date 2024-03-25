resource "aws_security_group" "external-alb-sg" {
  name        = "ec2-sg"
  description = "Security group for Nginx EC2 instances"
  vpc_id      = data.terraform_remote_state.project-network-dmz.outputs.public_vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "project-EC2-Nginx-SG"
  }
}


# Application Load Balancer (ALB) 생성
resource "aws_lb" "nginx_alb" {
  name               = "project-nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.external-alb-sg.id] # ALB에 대한 보안 그룹 ID
  subnets            = tolist(data.terraform_remote_state.project-network-dmz.outputs.subnet_dmz_public[*])

  enable_deletion_protection = false

  tags = {
    Name = "project-nginx-alb"
  }
}

# Target Group 생성
resource "aws_lb_target_group" "nginx_tg" {
  name     = "project-nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.project-network-dmz.outputs.public_vpc_id

  health_check {
    enabled = true
    path    = "/"
    port    = "80"
    protocol= "HTTP"
  }

  tags = {
    Name = "nginx-tg"
  }
}

resource "aws_lb_target_group_attachment" "nginx_tg_attachment2" {
  count            = 2
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = aws_instance.nginx_instance.*.id[count.index]
  port             = 80
}
resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:ap-northeast-2:123456789010:certificate/51ecfbb6-069d-4643-b3df-ae07a093a524"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

resource "aws_lb_listener" "nginx_listener2" {
  load_balancer_arn = aws_lb.nginx_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}