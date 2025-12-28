# Valores comunes para CORS (para reducir duplicación y facilitar lectura)
locals {
  cors_allow_headers      = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  cors_allow_methods_post = "'POST,OPTIONS'"
  cors_allow_origin       = "'*'"
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
  depends_on = [
    aws_api_gateway_integration.turnos_options_integration,
    aws_api_gateway_method_response.turnos_options_200
  ]
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = local.cors_allow_headers,
    "method.response.header.Access-Control-Allow-Methods" = local.cors_allow_methods_post,
    "method.response.header.Access-Control-Allow-Origin"  = local.cors_allow_origin
  }
}

# --- CORS para /staff ---
resource "aws_api_gateway_method" "staff_options" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.staff.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "staff_options_integration" {
  rest_api_id       = aws_api_gateway_rest_api.gateway.id
  resource_id       = aws_api_gateway_resource.staff.id
  http_method       = aws_api_gateway_method.staff_options.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}

resource "aws_api_gateway_method_response" "staff_options_200" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.staff.id
  http_method = aws_api_gateway_method.staff_options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "staff_options_response" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.staff.id
  http_method = aws_api_gateway_method.staff_options.http_method
  status_code = aws_api_gateway_method_response.staff_options_200.status_code
  depends_on = [
    aws_api_gateway_integration.staff_options_integration,
    aws_api_gateway_method_response.staff_options_200
  ]
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = local.cors_allow_headers,
    "method.response.header.Access-Control-Allow-Methods" = local.cors_allow_methods_post,
    "method.response.header.Access-Control-Allow-Origin"  = local.cors_allow_origin
  }
}
