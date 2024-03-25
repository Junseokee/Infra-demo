resource "aws_db_subnet_group" "app-db" {
  subnet_ids = data.terraform_remote_state.network-app.outputs.subnet_app_db
  tags = {
    Name = "app-db"
  }
}

resource "aws_db_instance" "app-db" {
  count                = 2
  identifier           = "app-db-${count.index}"
  allocated_storage    = 100
  db_name              = ""
  engine               = "mariadb"
  engine_version       = "10.11.6"
  instance_class       = "db.t3.micro"
  db_subnet_group_name = aws_db_subnet_group.app-db.name
  username             = "admin"
  password             = var.DB_PASSWORD
  skip_final_snapshot  = true
}
