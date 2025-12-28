# URL de la API para ser consumida por el frontend
output "api_url" {
  value = "${aws_api_gateway_stage.dev.invoke_url}/turnos"
}

# URL LocalStack para acceder al recurso /turnos desde localhost
output "api_url_localstack" {
  value = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.gateway.id}/${aws_api_gateway_stage.dev.stage_name}/_user_request_/turnos"
}
