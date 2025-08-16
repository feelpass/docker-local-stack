# MongoDB Local Infrastructure Makefile

# Use parent directory .env file
ENV_FILE := ../.env
DOCKER_COMPOSE := docker compose --env-file $(ENV_FILE)

.PHONY: up
up: network check-env ## Start MongoDB
	@echo "🚀 Starting MongoDB..."
	@$(DOCKER_COMPOSE) up -d mongodb
	@echo "✅ MongoDB is running on port $${MONGO_PORT:-27017}"

.PHONY: up-admin
up-admin: up ## Start MongoDB with Mongo Express
	@echo "🚀 Starting Mongo Express..."
	@$(DOCKER_COMPOSE) --profile admin up -d
	@echo "✅ Mongo Express is running on http://localhost:$${MONGO_EXPRESS_PORT:-8083}"

.PHONY: down
down: ## Stop MongoDB
	@echo "🛑 Stopping MongoDB..."
	@$(DOCKER_COMPOSE) --profile admin down

.PHONY: restart
restart: down up ## Restart MongoDB

.PHONY: logs
logs: ## Show MongoDB logs
	@$(DOCKER_COMPOSE) logs -f mongodb

.PHONY: cli
cli: ## Connect to MongoDB shell
	@docker exec -it local-mongodb mongosh -u root -p root123

.PHONY: exec
exec: ## Execute MongoDB command (use CMD="your command")
	@docker exec -it local-mongodb mongosh -u root -p root123 --eval "$(CMD)"

.PHONY: status
status: ## Check MongoDB status
	@$(DOCKER_COMPOSE) ps

.PHONY: clean
clean: down ## Remove MongoDB data
	@echo "⚠️  Removing MongoDB data..."
	@docker volume rm mongodb-data 2>/dev/null || true
	@echo "✅ MongoDB data removed"

.PHONY: init
init: ## Initialize database with sample data
	@echo "📝 Initializing MongoDB..."
	@docker exec -it local-mongodb mongosh -u root -p root123 --eval "use bomcalendar; db.users.insertOne({name: 'Test User', email: 'test@example.com'})"
	@echo "✅ MongoDB initialized"

.PHONY: dbs
dbs: ## List all databases
	@docker exec -it local-mongodb mongosh -u root -p root123 --eval "show dbs"

.PHONY: collections
collections: ## List collections in database (use DB=dbname)
	@docker exec -it local-mongodb mongosh -u root -p root123 --eval "use $(DB); show collections"

.PHONY: network
network: ## Create docker network if not exists
	@docker network create local-infra 2>/dev/null || true

.PHONY: check-env
check-env: ## Check if parent .env exists
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "⚠️  Parent .env file not found. Run 'make setup' in parent directory."; \
		exit 1; \
	fi

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'