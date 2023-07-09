resource "aws_lb" "alb" {
  name            = "skills-alb"
  subnets         = [
    aws_subnet.public_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id
  ]
  internal = false
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "tg1" {
  name        = "skills-tg1"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  deregistration_delay = 0

  health_check {
    path = "/health"
    matcher = "200"
    timeout = 2
    interval = 5
    unhealthy_threshold = 2
    healthy_threshold = 2
  }
}

resource "aws_lb_target_group" "tg2" {
  name        = "skills-tg2"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  deregistration_delay = 0

  health_check {
    path = "/health"
    matcher = "200"
    timeout = 2
    interval = 5
    unhealthy_threshold = 2
    healthy_threshold = 2
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.tg1.arn
        weight = 1
      }

      target_group {
        arn = aws_lb_target_group.tg2.arn
        weight = 0
      }
    }
  }
}
