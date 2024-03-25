# Bastion EC2 sg
resource "aws_security_group" "bastion_sg" {
  name   = "dmz-bastion-sg"
  vpc_id = data.terraform_remote_state.project-network-dmz.outputs.public_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "dmz-bastion-sg"
  }
}
# bastion EIP
resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  count    = 1
  tags = {
    Name = "project-bastion-eip"
  }
}
# bastion ec2
resource "aws_instance" "bastion" {
  ami                    = "ami-0382ac14e5f06eb95"
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = data.terraform_remote_state.project-network-dmz.outputs.subnet_dmz_public[0]
  key_name               = "project-bastion-key"
  user_data              = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install unzip 
sudo apt remove -y awscli
# awscli install
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
# docker install
sudo wget -qO- http://get.docker.com/ | sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ubuntu
# kubectl install
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.28.5/2024-01-04/bin/linux/amd64/kubectl	# 버전 1.28
chmod +x ./kubectl
HOME=/home/ubuntu
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
# helm install
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
# eksctl install
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin
# git install
sudo apt install git-all
EOF
  tags = {
    Name = "project-bastion-ec2"
  }
}