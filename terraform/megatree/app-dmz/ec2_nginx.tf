resource "aws_security_group" "nginx_sg" {
  name   = "dmz-nginx-sg"
  vpc_id = data.terraform_remote_state.project-network-dmz.outputs.public_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP에서 HTTPS 접근 허용
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dmz-nginx-sg"
  }
}


resource "aws_instance" "nginx_instance" {
  count         = 2 # 인스턴스 2개 생성
  ami           = "ami-0382ac14e5f06eb95"
  instance_type = "t3.small"
  key_name      = "project-bastion-key"

  subnet_id = tolist(data.terraform_remote_state.project-network-dmz.outputs.subnet_dmz_private)[count.index]

  # 사용자 데이터를 통해 Nginx 설치
  user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install nginx -y
  sudo ufw disable
  sudo ufw allow 'Nginx HTTP'
  sudo systemctl start nginx
  sudo systemctl enable nginx
  EOF

  # SSH 접속을 위한 보안 그룹 설정 (보안상의 이유로 실제 사용시 보다 엄격한 규칙 적용 필요)
  vpc_security_group_ids = [aws_security_group.nginx_sg.id,aws_security_group.external-alb-sg.id]

  tags = {
    Name = "project-nginx${count.index}-ec2"
  }
}