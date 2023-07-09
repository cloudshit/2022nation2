data "aws_iam_policy_document" "worker" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "worker" {
  name               = "skills-role-worker"
  assume_role_policy = data.aws_iam_policy_document.worker.json
}


resource "aws_iam_role_policy_attachment" "worker" {
  role       = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "worker" {
  name = "skills-profile-worker"
  role = aws_iam_role.worker.name
}

resource "aws_launch_configuration" "worker" {
  image_id             = "ami-0063312c13bc1e1ad"
  iam_instance_profile = aws_iam_instance_profile.worker.name
  security_groups      = [aws_security_group.ecs.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config"
  instance_type        = "c5.large"
}

resource "aws_autoscaling_group" "worker" {
  name                      = "skills-workers"
  vpc_zone_identifier       = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id
  ]
  launch_configuration      = aws_launch_configuration.worker.name

  desired_capacity          = 3
  min_size                  = 3
  max_size                  = 32
  health_check_grace_period = 300
  health_check_type         = "EC2"

  protect_from_scale_in = true

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_ecs_capacity_provider" "capacity" {
  name = "ec2_capacity"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.worker.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 60
    }
  } 
}
