# Cargamos las variables del .env e ignoramos líneas comentadas
include .env
export $(shell sed 's/=.*//' .env)

# --- Comandos ---

.PHONY: up down deploy logs destroy

# 1. Levantar Docker (Base de datos y Localstack)
up:
	@echo "Levantando contenedores..."
	docker-compose up -d

# 2. Desplegar Infraestructura (Terraform)
deploy:
	@echo "Desplegando infraestructura..."
	python3 -m pip install pg8000 -t ../app/ --upgrade --quiet
	terraform init
	terraform apply -auto-approve

# 3. Ver logs
logs:
	docker-compose logs -f

# 4. Apagar todo
down:
	docker-compose down

# 5. 
reset: down up
	@echo "Esperando a que arranque la DB..."
	sleep 5
	$(MAKE) deploy