resource "local_file" "appspec" {
  filename = "../src/appspec.yaml"
  content  = <<EOF
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "${aws_ecs_task_definition.td.arn_without_revision}"
        LoadBalancerInfo: 
          ContainerName: "app" 
          ContainerPort: 80
Hooks:
  - AfterInstall: "${aws_lambda_function.hook.arn}"
EOF
}
