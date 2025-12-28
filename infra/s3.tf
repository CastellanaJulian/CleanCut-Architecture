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

# Archivo de configuración con la URL de la API para el frontend
resource "aws_s3_object" "config_js" {
  bucket       = aws_s3_bucket.frontend_bucket.id
  key          = "config.js"
  content      = "window.API_URL=\"http://localhost:4566/restapis/${aws_api_gateway_rest_api.gateway.id}/${aws_api_gateway_stage.dev.stage_name}/_user_request_/turnos\";"
  content_type = "application/javascript"
}
