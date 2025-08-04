data "aws_acm_certificate" "codebeneath-labs-org" {
  domain      = var.gitlab-cert-domain
  statuses    = [ "ISSUED" ]
  key_types   = [ "EC_prime256v1" ]
  most_recent = true
}

# Public-facing load balancer
resource "aws_lb" "gitlab-alb" {
  name               = "${var.project-name}-gitlab-alb"
  internal           = false
  load_balancer_type = "application"
    ip_address_type  = "ipv4"
  subnets            = [ data.aws_subnet.lab-subnet-2a.id, data.aws_subnet.lab-subnet-2b.id ]
  security_groups    = [ aws_security_group.gitlab-sg.id ]
  connection_logs {
    enabled = "false"
    bucket  = ""
  }
  access_logs {
    enabled = "false"
    bucket  = ""
  }
  tags = {
    Name = "${var.project-name}-gitlab-alb"
  }
}

resource "aws_lb_listener" "port-80" {
  load_balancer_arn = aws_lb.gitlab-alb.arn
  port              = "80"
  protocol          = "HTTP"
  routing_http_response_server_enabled = "true"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gitlab-server.arn
  }
}

# resource "aws_lb_listener" "port-443" {
#   # ...
# }

# resource "aws_lb_listener_certificate" "gitlab-listener-cert" {
#   listener_arn    = aws_lb_listener.port-443.arn
#   certificate_arn = data.aws_acm_certificate.codebeneath-labs-org.arn
# }

resource "aws_lb_target_group" "gitlab-server" {
  name     = "gitlab-80"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.lab-vpc.id
}

resource "aws_lb_target_group_attachment" "gitlab-server" {
  target_group_arn = aws_lb_target_group.gitlab-server.arn
  target_id        = aws_instance.gitlab-ec2.id
  port             = 80
}
