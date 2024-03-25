resource "aws_security_group" "share-ci-alb-sg" {
  name        = "ec2-sg"
  description = "Security group for project ci node"
  vpc_id      = data.terraform_remote_state.project-network-share.outputs.vpc_share

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
    Name = "project-ci-SG"
  }
}


resource "aws_lb" "ci_alb" {
  name               = "project-ci-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.share-ci-alb-sg.id] # ALB에 대한 보안 그룹 ID
  subnets            = tolist(data.terraform_remote_state.project-network-share.outputs.subnet_share_id[*])

  enable_deletion_protection = false

  tags = {
    Name = "project-ci-alb"
  }
}

resource "aws_lb" "project_alb" {
  name               = "project-ci-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.share-ci-alb-sg.id] # ALB에 대한 보안 그룹 ID
  subnets            = tolist(data.terraform_remote_state.project-network-share.outputs.subnet_share_id[*])

  enable_deletion_protection = false

  tags = {
    Name = "project-share-alb"
  }
}

resource "aws_lb_listener" "ci_listener" {
  load_balancer_arn = aws_lb.ci_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "page not found"
      status_code  = "404"
    }
  }
}