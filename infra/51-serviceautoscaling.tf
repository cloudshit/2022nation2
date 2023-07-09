resource "aws_appautoscaling_target" "tg" {
  max_capacity = 32
  min_capacity = 3
  resource_id = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.svc.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "memory" {
  name               = "memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.tg.resource_id
  scalable_dimension = aws_appautoscaling_target.tg.scalable_dimension
  service_namespace  = aws_appautoscaling_target.tg.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80
  }
}

resource "aws_appautoscaling_policy" "cpu" {
  name = "cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.tg.resource_id
  scalable_dimension = aws_appautoscaling_target.tg.scalable_dimension
  service_namespace = aws_appautoscaling_target.tg.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}
