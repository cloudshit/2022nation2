data "aws_iam_policy_document" "assume_role_hook" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "hook" {
  name               = "skills-role-hook"
  assume_role_policy = data.aws_iam_policy_document.assume_role_hook.json
}

data "aws_iam_policy_document" "hook" {
  statement {
    effect = "Allow"

    actions = [
      "logs:*",
      "ecs:*",
      "codedeploy:PutLifecycleEventHookExecutionStatus"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "hook" {
  role   = aws_iam_role.hook.name
  policy = data.aws_iam_policy_document.hook.json
}

data "archive_file" "hook" {
  type        = "zip"
  source_file = "../scripts/hook.js"
  output_path = "../temp/hook.zip"
}

resource "aws_lambda_function" "hook" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../temp/hook.zip"
  function_name = "skills-hook"
  role          = aws_iam_role.hook.arn
  handler       = "hook.handler"

  source_code_hash = data.archive_file.hook.output_base64sha256

  runtime = "nodejs16.x"
}
