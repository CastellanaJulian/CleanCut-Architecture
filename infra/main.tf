provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
  }
}

resource "aws_dynamodb_table" "tabla_turnos" {
  name         = "turnosPeluqueria"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PeluqueroID"
  range_key    = "FechaHora"

  attribute {
    name = "PeluqueroID"
    type = "S"
  }
  attribute {
    name = "FechaHora"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Name        = "TablaTurnosPeluquería"
    ManagedBy   = "terraform"
  }
}
