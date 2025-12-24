variable "db_user" {
  description = "Usuario de la base de datos PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Contraseña de la base de datos PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nombre de la base de datos PostgreSQL"
  type        = string
}

variable "db_host" {
  description = "Host de la base de datos PostgreSQL"
  type        = string
  default     = "postgres_db"
}

variable "db_port" {
  description = "Puerto de la base de datos PostgreSQL"
  type        = number
  default     = 5432
}

# Configuración del proveedor AWS apuntando a LocalStack para desarrollo local
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    apigateway   = "http://localhost:4566"
    apigatewayv2 = "http://localhost:4566"
    cloudwatch   = "http://localhost:4566"
    iam          = "http://localhost:4566"
    lambda       = "http://localhost:4566"
    s3           = "http://localhost:4566"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

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

# API Gateway REST para exponer la función Lambda como endpoint HTTP
resource "aws_api_gateway_rest_api" "gateway" {
  name        = "PeluqueriaAPI_REST"
  description = "API REST para gestión de turnos"
}

# Recurso /turnos en la API Gateway
resource "aws_api_gateway_resource" "turnos" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  parent_id   = aws_api_gateway_rest_api.gateway.root_resource_id
  path_part   = "turnos"
}

# Método POST para crear turnos
resource "aws_api_gateway_method" "crear_turno" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.turnos.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integración entre API Gateway y la función Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.gateway.id
  resource_id             = aws_api_gateway_resource.turnos.id
  http_method             = aws_api_gateway_method.crear_turno.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_turnos.invoke_arn
}

# Despliegue de la API Gateway
resource "aws_api_gateway_deployment" "produccion" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.lambda_barberos,
    aws_api_gateway_integration.turnos_options_integration,
    aws_api_gateway_integration.barberos_options_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.lambda_integration,
      aws_api_gateway_integration.lambda_barberos,
      aws_api_gateway_integration.turnos_options_integration,
      aws_api_gateway_integration.barberos_options_integration
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Stage de desarrollo para la API Gateway
resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.produccion.id
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  stage_name    = "dev"
}

# Permiso para que API Gateway invoque la función Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_turnos.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gateway.execution_arn}/*/*"
}

# Bucket S3 para servir el frontend
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "peluqueria-frontend-app"
}

# Carga del archivo index.html al bucket S3
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.frontend_bucket.id
  key          = "index.html"
  source       = "../frontend/index.html"
  content_type = "text/html"
}

# URL de la API para ser consumida por el frontend
output "api_url" {
  value = "${aws_api_gateway_stage.dev.invoke_url}/turnos"
}

# --- Recurso /barberos ---
resource "aws_api_gateway_resource" "barberos" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  parent_id   = aws_api_gateway_rest_api.gateway.root_resource_id
  path_part   = "barberos"
}

resource "aws_api_gateway_method" "crear_barbero" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.barberos.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_barberos" {
  rest_api_id             = aws_api_gateway_rest_api.gateway.id
  resource_id             = aws_api_gateway_resource.barberos.id
  http_method             = aws_api_gateway_method.crear_barbero.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_turnos.invoke_arn
}

# --- CORS para /turnos ---
resource "aws_api_gateway_method" "turnos_options" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.turnos.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "turnos_options_integration" {
  rest_api_id       = aws_api_gateway_rest_api.gateway.id
  resource_id       = aws_api_gateway_resource.turnos.id
  http_method       = aws_api_gateway_method.turnos_options.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}

resource "aws_api_gateway_method_response" "turnos_options_200" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.turnos.id
  http_method = aws_api_gateway_method.turnos_options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "turnos_options_response" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.turnos.id
  http_method = aws_api_gateway_method.turnos_options.http_method
  status_code = aws_api_gateway_method_response.turnos_options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# --- CORS para /barberos ---
resource "aws_api_gateway_method" "barberos_options" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.barberos.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "barberos_options_integration" {
  rest_api_id       = aws_api_gateway_rest_api.gateway.id
  resource_id       = aws_api_gateway_resource.barberos.id
  http_method       = aws_api_gateway_method.barberos_options.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}

resource "aws_api_gateway_method_response" "barberos_options_200" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.barberos.id
  http_method = aws_api_gateway_method.barberos_options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "barberos_options_response" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.barberos.id
  http_method = aws_api_gateway_method.barberos_options.http_method
  status_code = aws_api_gateway_method_response.barberos_options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}
