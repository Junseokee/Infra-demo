resource "aws_ecr_repository" "project_ecr" {
  name                 = "project"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "null_for_ecr_get_login_password" {
  provisioner "local-exec" {
    command = <<EOF
      aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ${aws_ecr_repository.project_ecr.repository_url}
    EOF
  }
}



output "ecr_registry_id" {
  value = aws_ecr_repository.project_ecr.registry_id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.project_ecr.repository_url
}