resource "aws_ecs_task_definition" "this" {
  family                   = "restaurant-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 3072
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "restaurant-task-container"
      image     = "731771597147.dkr.ecr.us-east-1.amazonaws.com/restaurant-ecr:latest"
      essential = true
      cpu       = 1024
      memory    = 3072
      portMappings = [{
        name          = "restaurant-task-port"
        protocol      = "tcp"
        appProtocol   = "http"
        containerPort = 8080
        hostPort      = 8080
      }]
      environment = [
        { "name" : "API_PORT", "value" : "8080" },
        { "name" : "MYSQL_DSN", "value" : "restaurantuser:restaurantpass@tcp(restaurant.cjs7ovml0deq.us-east-1.rds.amazonaws.com:3306)/restaurant?multiStatements=true&&charset=utf8mb4&parseTime=True&loc=Local" },
      ]
      healthCheck = {
        command : ["CMD-SHELL", "wget --spider --server-response http://localhost:8080/api/v1/health || exit 1"],
        startPeriod : 30,
        interval : 10,
        timeout : 15,
        retries : 5,
      }
      logConfiguration = {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "/ecs/test-task",
          "awslogs-region" : "us-east-1",
          "awslogs-stream-prefix" : "ecs"
      } }

    }
  ])

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "restaurant-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
