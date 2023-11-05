resource "aws_lb" "this" {
  name               = "restaurant-alb"
  security_groups    = [aws_security_group.alb_sg.id]
  load_balancer_type = "application"

  subnets = [aws_subnet.public-us-east-1a.id, aws_subnet.public-us-east-1b.id]

}

resource "aws_lb_target_group" "this" {
  name        = "alb-target-gp"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200,301,302"
    path                = "/api/v1/health"
    timeout             = "5"
    unhealthy_threshold = "5"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}