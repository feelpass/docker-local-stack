# MinIO Local Infrastructure Makefile

# Use parent directory .env file
ENV_FILE := ../.env
DOCKER_COMPOSE := docker compose --env-file $(ENV_FILE)

.PHONY: up
up: network check-env ## Start MinIO
	@echo "🚀 Starting MinIO..."
	@$(DOCKER_COMPOSE) up -d
	@echo "✅ MinIO is running"
	@echo "   API: http://localhost:$${MINIO_PORT:-9000}"
	@echo "   Console: http://localhost:$${MINIO_CONSOLE_PORT:-9001}"
	@echo "   Username: $${MINIO_ROOT_USER:-minioadmin}"
	@echo "   Password: $${MINIO_ROOT_PASSWORD:-minioadmin}"

.PHONY: down
down: ## Stop MinIO
	@echo "🛑 Stopping MinIO..."
	@$(DOCKER_COMPOSE) down

.PHONY: restart
restart: down up ## Restart MinIO

.PHONY: logs
logs: ## Show MinIO logs
	@$(DOCKER_COMPOSE) logs -f

.PHONY: status
status: ## Check MinIO status
	@docker compose ps

.PHONY: clean
clean: down ## Remove MinIO data
	@echo "⚠️  Removing MinIO data..."
	@docker volume rm minio-data 2>/dev/null || true
	@echo "✅ MinIO data removed"

.PHONY: init
init: ## Create default buckets
	@echo "📝 Creating default buckets..."
	@docker exec local-minio sh -c 'mc alias set local http://localhost:9000 $$MINIO_ROOT_USER $$MINIO_ROOT_PASSWORD && \
		mc mb local/uploads --ignore-existing && \
		mc mb local/backups --ignore-existing && \
		mc mb local/logs --ignore-existing && \
		mc mb local/public --ignore-existing'
	@echo "✅ Default buckets created"

.PHONY: buckets
buckets: ## List all buckets
	@docker exec local-minio sh -c 'mc alias set local http://localhost:9000 $$MINIO_ROOT_USER $$MINIO_ROOT_PASSWORD && mc ls local'

.PHONY: upload
upload: ## Upload a file (use FILE=path/to/file BUCKET=bucket-name)
	@docker cp $(FILE) local-minio:/tmp/upload-file
	@docker exec local-minio sh -c 'mc alias set local http://localhost:9000 $$MINIO_ROOT_USER $$MINIO_ROOT_PASSWORD && mc cp /tmp/upload-file local/$(BUCKET)/'
	@echo "✅ File uploaded to $(BUCKET)"

.PHONY: download
download: ## Download a file (use FILE=filename BUCKET=bucket-name)
	@docker exec local-minio sh -c 'mc alias set local http://localhost:9000 $$MINIO_ROOT_USER $$MINIO_ROOT_PASSWORD && mc cp local/$(BUCKET)/$(FILE) /tmp/$(FILE)'
	@docker cp local-minio:/tmp/$(FILE) ./$(FILE)
	@echo "✅ File downloaded to ./$(FILE)"

.PHONY: shell
shell: ## Open MinIO container shell
	@docker exec -it local-minio /bin/sh

.PHONY: network
network: ## Create docker network if not exists
	@docker network create local-infra 2>/dev/null || true

.PHONY: check-env
check-env: ## Check if environment file exists
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "❌ Environment file $(ENV_FILE) not found!"; \
		echo "Please run 'make setup' from the root directory first."; \
		exit 1; \
	fi

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'