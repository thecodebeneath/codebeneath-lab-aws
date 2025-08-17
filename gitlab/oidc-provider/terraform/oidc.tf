resource "aws_iam_openid_connect_provider" "gitlab-oidc" {
  url = "https://gitlab.codebeneath-labs.org"
  client_id_list = [
    "https://gitlab.codebeneath-labs.org",
  ]
  # Also depends on:
  # 1. the docker compose gitlab service being up, which is a manual step at the moment
  # 2. Route53 being updated to point the gitlab A record to the ALB DNS name
  # depends_on = [ aws_instance.gitlab-ec2, aws_lb.gitlab-alb, aws_lb_target_group.gitlab-server ]
}
