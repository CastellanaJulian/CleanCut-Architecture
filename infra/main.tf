# Definimos el proveedor de AWS con endpoints personalizados para LocalStack
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  # Redirigimos todos los servicios a LocalStack
  endpoints {
    apigateway   = "http://localhost:4566"
    apigatewayv2 = "http://localhost:4566"
    cloudwatch   = "http://localhost:4566"
    dynamodb     = "http://localhost:4566"
    iam          = "http://localhost:4566"
    lambda       = "http://localhost:4566"
    s3           = "http://localhost:4566"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0" # 👈 La llave maestra
    }
  }
}

# ... resto del archivo ...

# Base de Datos No-SQL (DynamoDB)
resource "aws_dynamodb_table" "turnos" {
  name         = "TurnosPeluqueria"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ID"

  attribute {
    name = "ID"
    type = "S" # String
  }
}

# Empaquetado del Código (ZIP) para Lambda

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../app"
  output_path = "${path.module}/lambda_function.zip"
  excludes = [
    "__pycache__"
  ]
}

# El Backend (Lambda)
resource "aws_lambda_function" "api_turnos" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "CrearTurnoFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = "adapters.api.lambda_handler.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # 
  environment {
    variables = {
      TABLE_NAME       = aws_dynamodb_table.turnos.name
      AWS_ENDPOINT_URL = "http://localstack:4566" # Lambda ve a LocalStack así
    }
  }
}

# 5. Permisos (IAM Role)
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
# 1. El Edificio (API Gateway REST)
resource "aws_api_gateway_rest_api" "gateway" {
  name        = "PeluqueriaAPI_REST"
  description = "API para la peluqueria (Version REST)"
}

# 2. El Pasillo (Recurso: /turnos)
resource "aws_api_gateway_resource" "turnos" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  parent_id   = aws_api_gateway_rest_api.gateway.root_resource_id
  path_part   = "turnos"
}

# 3. La Puerta (Método: POST)
resource "aws_api_gateway_method" "crear_turno" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.turnos.id
  http_method   = "POST"
  authorization = "NONE"
}

# 4. El Cableado (Integración con Lambda)
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.gateway.id
  resource_id             = aws_api_gateway_resource.turnos.id
  http_method             = aws_api_gateway_method.crear_turno.http_method
  integration_http_method = "POST" # Lambda siempre se invoca por POST internamente
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_turnos.invoke_arn
}

# 5. El Despliegue (Deployment) - ¡Vital para que funcione!
# 5. El Despliegue (La acción de publicar)
resource "aws_api_gateway_deployment" "produccion" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.gateway.id

  # Quitamos 'stage_name' de aquí porque daba error.

  # TRUCO: Esto obliga a redesplegar si cambia la integración
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_integration.lambda_integration))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 5.5 La Etiqueta del Stage (Aquí definimos "dev")
resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.produccion.id
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  stage_name    = "dev"
}

# 6. Permiso para que API Gateway despierte a Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_turnos.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gateway.execution_arn}/*/*"
}

# Frontend (S3)
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "peluqueria-frontend-app"
}

# Subimos el index.html automáticamente
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.frontend_bucket.id
  key          = "index.html"
  source       = "../frontend/index.html"
  content_type = "text/html"
}

# Output Final
output "api_url" {
  value = "${aws_api_gateway_stage.dev.invoke_url}/turnos"
}
