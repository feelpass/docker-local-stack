# Redis Local Infrastructure Makefile

# Use parent directory .env file
ENV_FILE := ../.env
DOCKER_COMPOSE := docker compose --env-file $(ENV_FILE)

.PHONY: up
up: network check-env ## Start Redis
	@echo "🚀 Starting Redis..."
	@$(DOCKER_COMPOSE) up -d redis
	@echo "✅ Redis is running on port $${REDIS_PORT:-6379}"

.PHONY: up-admin
up-admin: up ## Start Redis with Commander UI
	@echo "🚀 Starting Redis Commander..."
	@$(DOCKER_COMPOSE) --profile admin up -d
	@echo "✅ Redis Commander is running on http://localhost:$${REDIS_COMMANDER_PORT:-8081}"

.PHONY: down
down: ## Stop Redis
	@echo "🛑 Stopping Redis..."
	@$(DOCKER_COMPOSE) --profile admin down

.PHONY: restart
restart: down up ## Restart Redis

.PHONY: logs
logs: ## Show Redis logs
	@$(DOCKER_COMPOSE) logs -f redis

.PHONY: cli
cli: ## Connect to Redis CLI
	@docker exec -it local-redis redis-cli

.PHONY: exec
exec: ## Execute Redis command (use CMD="your command")
	@docker exec -it local-redis redis-cli $(CMD)

.PHONY: status
status: ## Check Redis status
	@$(DOCKER_COMPOSE) ps

.PHONY: clean
clean: down ## Remove Redis data
	@echo "⚠️  Removing Redis data..."
	@docker volume rm redis-data 2>/dev/null || true
	@echo "✅ Redis data removed"

.PHONY: info
info: ## Show Redis info
	@docker exec -it local-redis redis-cli INFO

.PHONY: monitor
monitor: ## Monitor Redis commands in real-time
	@docker exec -it local-redis redis-cli MONITOR

.PHONY: flush
flush: ## Flush all Redis data
	@docker exec -it local-redis redis-cli FLUSHALL

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