resource "aws_cloudwatch_event_rule" "codebuild_failed" {
  name        = "codebuild-failed-event"
  description = "Captura eventos de falha no CodeBuild"
  event_pattern = <<EOF
{
  "source": ["aws.codebuild"],
  "detail-type": ["CodeBuild Build State Change"],
  "detail": {
    "build-status": ["FAILED"]
  }
}
EOF
}


# Filtrando a mensagem para enviar somente as informações necessarias 
resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.codebuild_failed.name
  target_id = "send-to-sns"
  role_arn  = aws_iam_role.eventbridge_role.arn
  arn       = aws_sns_topic.codebuild_failures.arn

  input_transformer {
    input_paths = {
      project   = "$.detail.project-name"
      build_id  = "$.detail.build-id"
      status    = "$.detail.build-status"
      # ATENÇÃO: as fases ficam em additional-information.phases
      # O índice 6 foi o da sua amostra (fase BUILD). Se variar, considere Lambda.
      error     = "$.detail.additional-information.phases[6].phase-context[0]"
      log_link  = "$.detail.additional-information.logs.deep-link"
    }

    input_template = <<EOT
{
  "title": "CodeBuild failure",
  "status": <status>,
  "project": <project>,
  "build_id": <build_id>,
  "error": <error>,
  "logs": <log_link>
}
EOT
  }
}

resource "aws_sns_topic" "codebuild_failures" {
  name = "codebuild-failures-topic"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.codebuild_failures.arn
  protocol  = "email"
  endpoint  = "aramisoliveira@ymail.com"
}

resource "aws_iam_role" "eventbridge_role" {
  name = "eventbridge_sns_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "events.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_sns_policy" {
  name = "eventbridge_sns_policy"
  role = aws_iam_role.eventbridge_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = aws_sns_topic.codebuild_failures.arn
      }
    ]
  })
}

#resource "aws_cloudwatch_event_target" "sns_with_role" {
#  rule      = aws_cloudwatch_event_rule.codebuild_failed.name
#  target_id = "sns-target"
#  arn       = aws_sns_topic.codebuild_failures.arn
#  role_arn  = aws_iam_role.eventbridge_role.arn
#}
