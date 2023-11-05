resource "aws_ecr_repository" "ecr" {
  name                 = var.AWS_ECS_CLUSTER
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository_policy" "policy" {
  repository = aws_ecr_repository.ecr.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "AllowPushPullImage",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.ecr.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "last 10 docker images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}