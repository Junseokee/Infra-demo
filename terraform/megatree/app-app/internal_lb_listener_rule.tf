resource "aws_lb_listener_rule" "grafana_rule" {
  tags = {
    Name = aws_lb_target_group.grafana_tg.name
  }
  depends_on = [
    aws_lb.cd_alb,
    aws_lb_listener.cd_listener,
    aws_lb_target_group.grafana_tg
  ]
  listener_arn = aws_lb_listener.cd_listener.arn
  priority     = 1

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }

  condition {
    host_header {
      values = [var.HOST_HEADER_GF]
    }
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_listener_rule" "argo_rule" {
  tags = {
    Name = aws_lb_target_group.argo_tg.name
  }
  depends_on = [
    aws_lb.cd_alb,
    aws_lb_listener.cd_listener,
    aws_lb_target_group.argo_tg
  ]
  listener_arn = aws_lb_listener.cd_listener.arn
  priority     = 2

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.argo_tg.arn
  }

  condition {
    host_header {
      values = [var.HOST_HEADER_AG]
    }
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}