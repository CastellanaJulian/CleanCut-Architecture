# Empaquetado del código Python en formato ZIP para la función Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../app"
  output_path = "${path.module}/lambda_function.zip"
  excludes = [
    "__pycache__"
  ]
}

# Función Lambda que procesa las solicitudes de creación de turnos
resource "aws_lambda_function" "api_turnos" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "CrearTurnoFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = "adapters.api.lambda_handler.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DB_HOST     = var.db_host
      DB_PORT     = var.db_port
      DB_NAME     = var.db_name
      DB_USER     = var.db_user
      DB_PASSWORD = var.db_password
    }
  }
}

# Rol IAM que permite a Lambda acceder a servicios necesarios
resource "aws_iam_role" "lambda_role" {
  name = "serverless_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Política IAM para permitir logs en CloudWatch
resource "aws_iam_role_policy" "lambda_logs" {
  name = "lambda_logs_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}

# Permiso para que API Gateway invoque la función Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_turnos.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gateway.execution_arn}/*/*"
}
