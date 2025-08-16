# MySQL Local Infrastructure Makefile

# Use parent directory .env file
ENV_FILE := ../.env
DOCKER_COMPOSE := docker compose --env-file $(ENV_FILE)

.PHONY: up
up: network check-env ## Start MySQL
	@echo "🚀 Starting MySQL..."
	@$(DOCKER_COMPOSE) up -d mysql
	@echo "✅ MySQL is running on port $${MYSQL_PORT:-3306}"

.PHONY: up-admin
up-admin: up ## Start MySQL with phpMyAdmin
	@echo "🚀 Starting phpMyAdmin..."
	@$(DOCKER_COMPOSE) --profile admin up -d
	@echo "✅ phpMyAdmin is running on http://localhost:$${PHPMYADMIN_PORT:-8082}"

.PHONY: down
down: ## Stop MySQL
	@echo "🛑 Stopping MySQL..."
	@$(DOCKER_COMPOSE) --profile admin down

.PHONY: restart
restart: down up ## Restart MySQL

.PHONY: logs
logs: ## Show MySQL logs
	@$(DOCKER_COMPOSE) logs -f mysql

.PHONY: check-env
check-env: ## Check if parent .env exists
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "⚠️  Parent .env file not found. Run 'make setup' in parent directory."; \
		exit 1; \
	fi

.PHONY: cli
cli: ## Connect to MySQL CLI
	@docker exec -it local-mysql mysql -uroot -proot

.PHONY: exec
exec: ## Execute MySQL command (use CMD="your sql")
	@docker exec -it local-mysql mysql -uroot -proot -e "$(CMD)"

.PHONY: status
status: ## Check MySQL status
	@$(DOCKER_COMPOSE) ps

.PHONY: clean
clean: down ## Remove MySQL data
	@echo "⚠️  Removing MySQL data..."
	@docker volume rm mysql-data 2>/dev/null || true
	@echo "✅ MySQL data removed"

.PHONY: init
init: ## Initialize database with sample data
	@echo "📝 Initializing MySQL database..."
	@docker exec -it local-mysql mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS bomcalendar;"
	@docker exec -it local-mysql mysql -uroot -proot bomcalendar -e "CREATE TABLE IF NOT EXISTS users (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100), email VARCHAR(100));"
	@docker exec -it local-mysql mysql -uroot -proot bomcalendar -e "INSERT IGNORE INTO users (id, name, email) VALUES (1, 'Test User', 'test@example.com');"
	@echo "✅ MySQL initialized"

.PHONY: network
network: ## Create docker network if not exists
	@docker network create local-infra 2>/dev/null || true

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'