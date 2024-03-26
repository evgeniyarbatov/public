resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_for_lambda" {
  name = "iam_for_lambda"
  role = aws_iam_role.iam_for_lambda.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

data "archive_file" "rewrite_request_path" {
  type = "zip"

  source_dir  = "${path.module}/rewrite_request_path"
  output_path = "${path.module}/rewrite_request_path.zip"
}

resource "aws_lambda_function" "rewrite_request_path" {
  provider      = aws.lamda_edge_provider
  filename      = "rewrite_request_path.zip"
  function_name = "arn:aws:lambda:us-east-1:655701728733:function:rewriteRequestPath"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"

  runtime = "nodejs18.x"

  publish = true

  source_code_hash = filebase64sha256(
    data.archive_file.rewrite_request_path.output_path
  )
}
