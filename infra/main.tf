## Archivo modularizado
# Este archivo 'main.tf' ha sido vaciado para mejorar la legibilidad.
# La configuración se ha dividido en:
# - variables.tf: Variables de entorno y DB
# - provider.tf: Proveedor AWS y versiones
# - lambda.tf: Función Lambda e IAM
# - api.tf: API Gateway recursos, métodos, integraciones y stage
# - cors.tf: Bloques de CORS reutilizando 'locals'
# - s3.tf: Bucket y objeto del frontend
# - outputs.tf: Salidas (URL de la API)
