resource "aws_lb_target_group" "grafana_tg" {
  name     = "megatree-grafana-tg"
  port     = 80
  protocol = "HTTP"
  protocol_version = "HTTP1"
  target_type = "instance"
  vpc_id   = data.terraform_remote_state.network-app.outputs.vpc_app
  health_check {
    enabled = true
    path = "/"
    matcher = "200-399"
  }
}
output "grafana_tg_arn" {
  value = aws_lb_target_group.grafana_tg.arn
}
resource "aws_lb_target_group" "argo_tg" {
  name     = "megatree-argo-tg"
  port     = 80
  protocol = "HTTP"
  protocol_version = "HTTP1"
  target_type = "instance"
  vpc_id   = data.terraform_remote_state.network-app.outputs.vpc_app
  health_check {
    enabled = true
    path = "/"
    matcher = "200-399"
  }
}

output "argo_tg_arn" {
  value = aws_lb_target_group.argo_tg.arn
}