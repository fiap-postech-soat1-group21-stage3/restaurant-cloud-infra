resource "aws_ecs_cluster" "cluster_name" {
  name = var.AWS_ECS_CLUSTER
}

resource "aws_ecs_service" "this" {
  name                              = "restaurant-cluster-service"
  cluster                           = aws_ecs_cluster.cluster_name.id
  task_definition                   = aws_ecs_task_definition.this.arn
  launch_type                       = "FARGATE"
  desired_count                     = 2
  health_check_grace_period_seconds = 10


  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "restaurant-task-container"
    container_port   = 8080
  }

  network_configuration {
    subnets          = [aws_subnet.public-us-east-1a.id, aws_subnet.public-us-east-1b.id]
    security_groups  = [aws_security_group.service_sg.id]
    assign_public_ip = true
  }

  deployment_controller {
    type = "ECS"
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.this.arn
    service {
      port_name      = "restaurant-task-port"
      discovery_name = "restaurant-ecr"
      client_alias {
        dns_name = "restaurant-ecr"
        port     = 8080
      }
    }
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

}

resource "aws_service_discovery_http_namespace" "this" {
  description = "Namespace para descoberta dos services do ECS"
  name        = "restaurant-ecs-services"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
