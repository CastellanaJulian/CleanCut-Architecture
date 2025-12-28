# Cargamos las variables del .env e ignoramos líneas comentadas
include .env
export $(shell sed 's/=.*//' .env)

# --- Comandos ---

.PHONY: up down deploy logs destroy reset start frontend-local serve-frontend

# 1. Levantar Docker (Base de datos y Localstack)
up:
	@echo "Levantando contenedores..."
	docker-compose up -d

# 2. Desplegar Infraestructura (Terraform)
deploy:
	@echo "Desplegando infraestructura..."
	python3 -m pip install pg8000 -t ../app/ --upgrade --quiet
	@echo "Esperando a que la base de datos esté lista..."
	@for i in $$(seq 1 60); do \
		docker-compose exec -T postgres_db pg_isready -U "$$TF_VAR_db_user" -d "$$TF_VAR_db_name" -h postgres_db -p "$$TF_VAR_db_port" >/dev/null 2>&1 && echo "DB lista" && break; \
		sleep 1; \
	done
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

# 6. Generar config.js local con la URL de LocalStack
frontend-local:
	@echo "Generando frontend/config.js con URL LocalStack..."
	@API_LOCAL=$$(terraform output -raw api_url_localstack); \
	echo "window.API_URL=\"$${API_LOCAL}\";" > ../frontend/config.js; \
	echo "Escrito ../frontend/config.js -> $${API_LOCAL}"

# 7. Servir frontend localmente (bloquea la terminal)
serve-frontend:
	@echo "Sirviendo frontend en http://localhost:8080 ..."
	cd ../frontend && python3 -m http.server 8080

# 8. Encendido de 0: contenedores + infra + config frontend
start: up deploy frontend-local
	@echo "Todo listo. Abrí http://localhost:8080 tras ejecutar: make serve-frontend"

# 9. Apagar: destruir recursos Terraform y bajar contenedores
destroy:
	@echo "Destruyendo infraestructura y contenedores..."
	terraform destroy -auto-approve || true
	docker-compose down