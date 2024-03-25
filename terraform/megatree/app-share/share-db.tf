resource "aws_db_subnet_group" "project-gitlab-db" {
  subnet_ids = data.terraform_remote_state.project-network-share.outputs.subnet_share_db_id
  tags = {
    Name = "project-gitlab-db"
  }
}

resource "aws_db_instance" "default" {
  identifier = "project-gitlab-db"
  allocated_storage    = 30
  db_name              = "project_gitlab"
  engine               = "postgres"
  engine_version       = "15.5"
  instance_class       = "db.t3.micro"
  db_subnet_group_name = aws_db_subnet_group.project-gitlab-db.name
  username             = "project"
  password             = var.DB_PASSWORD
  skip_final_snapshot  = true
}









#resource "aws_db_parameter_group" "project-gitlab-db-parameters"{
#  name   = "education"
#  family = "postgres14"
#
#  parameter {
#    name  = "log_connections"
#    value = "1"
#  }
#}