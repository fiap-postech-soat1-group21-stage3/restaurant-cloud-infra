variable "AWS_ACCESS_KEY" {
  description = "Access key to AWS console"
}
variable "AWS_SECRET_KEY" {
  description = "Secret key to AWS console"
}
variable "AWS_REGION" {
  description = "AWS region"
}
variable "AWS_ECS_CLUSTER" {
  description = "Restaurant AWS ECS cluster name"
}
variable "AWS_ECR_REPOSITORY" {
  description = "Restaurant AWS ECR name"
}
variable "AWS_TASK_CONTAINER_NAME" {
  description = "Restaurant AWS ECS TASK container name"
}
variable "DB_NAME" {
  description = "Database name"
}
variable "DB_PASSWORD" {
  description = "Database root password"
}
variable "DB_USER" {
  description = "Database root user"
}
variable "DB_PORT" {
  description = "Database port"
}
variable "APP_HEALTH_TEST_PATH" {
  description = "Application endpoint path to health test"
}