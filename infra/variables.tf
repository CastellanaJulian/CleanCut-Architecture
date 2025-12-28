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
