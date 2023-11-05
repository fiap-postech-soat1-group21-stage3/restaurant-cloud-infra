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
      name      = "${var.AWS_TASK_CONTAINER_NAME}"
      image     = "${aws_ecr_repository.ecr.repository_url}:latest"
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
        { "name" : "MYSQL_DSN", "value" : "${var.DB_USER}:${var.DB_PASSWORD}@tcp(${data.terraform_remote_state.restaurant_database.outputs.restaurant_database_address}:${var.DB_PORT})/${var.DB_NAME}?multiStatements=true&&charset=utf8mb4&parseTime=True&loc=Local" },
      ]
      healthCheck = {
        command : ["CMD-SHELL", "wget --spider --server-response http://localhost:8080${var.APP_HEALTH_TEST_PATH} || exit 1"],
        startPeriod : 30,
        interval : 10,
        timeout : 15,
        retries : 5,
      }
      logConfiguration = {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "/ecs/${var.AWS_TASK_CONTAINER_NAME}",
          "awslogs-region" : "${var.AWS_REGION}",
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

resource "aws_iam_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  name       = "ecs_task_execution_role_policy_attachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
