resource "aws_security_group" "ecs" {
  name = "skills-ecs-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }

  egress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }
}


resource "aws_ecs_task_definition" "td" {
  family                   = "skills-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 512
  memory                   = 1024

  container_definitions = <<DEFINITION
[
  {
    "image": "${aws_ecr_repository.skills_ecr.repository_url}:latest",
    "cpu": 512,
    "memory": 1024,
    "name": "app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "healthCheck": {
      "command": ["CMD-SHELL", "curl http://localhost:80/health || exit 1"],
      "interval": 5,
      "timeout": 2,
      "retries": 1,
      "startPeriod": 0
    },
    "essential": true
  }
]
DEFINITION
}

resource "aws_ecs_cluster" "cluster" {
  name = "skills-cluster"
}

resource "aws_ecs_service" "svc" {
  name            = "skills-svc"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.td.arn
  desired_count   = 3
  health_check_grace_period_seconds = 0
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id,
      aws_subnet.private_c.id
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = false
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg1.arn
    container_name   = "app"
    container_port   = 80
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [ap-notheast-2a, ap-northeast-2b, ap-northeast-2c]"
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}

resource "aws_ecs_cluster_capacity_providers" "workers" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = [
    aws_ecs_capacity_provider.capacity.name
  ]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.capacity.name
  }
}
