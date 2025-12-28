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
    aws_api_gateway_integration.lambda_staff,
    aws_api_gateway_integration.turnos_options_integration,
    aws_api_gateway_integration.staff_options_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.lambda_integration,
      aws_api_gateway_integration.lambda_staff,
      aws_api_gateway_integration.turnos_options_integration,
      aws_api_gateway_integration.staff_options_integration
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

# --- Recurso /staff ---
resource "aws_api_gateway_resource" "staff" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  parent_id   = aws_api_gateway_rest_api.gateway.root_resource_id
  path_part   = "staff"
}

resource "aws_api_gateway_method" "crear_staff" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.staff.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_staff" {
  rest_api_id             = aws_api_gateway_rest_api.gateway.id
  resource_id             = aws_api_gateway_resource.staff.id
  http_method             = aws_api_gateway_method.crear_staff.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_turnos.invoke_arn
}
