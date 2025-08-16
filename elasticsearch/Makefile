# Elasticsearch Local Infrastructure Makefile

# Use parent directory .env file
ENV_FILE := ../.env
DOCKER_COMPOSE := docker compose --env-file $(ENV_FILE)

.PHONY: up
up: network check-env ## Start Elasticsearch
	@echo "🚀 Starting Elasticsearch..."
	@$(DOCKER_COMPOSE) up -d elasticsearch
	@echo "⏳ Waiting for Elasticsearch to be ready..."
	@sleep 10
	@echo "✅ Elasticsearch is running on http://localhost:$${ELASTICSEARCH_PORT:-9200}"

.PHONY: up-admin
up-admin: up ## Start Elasticsearch with Kibana
	@echo "🚀 Starting Kibana..."
	@$(DOCKER_COMPOSE) --profile admin up -d
	@echo "✅ Kibana is running on http://localhost:$${KIBANA_PORT:-5601}"

.PHONY: down
down: ## Stop Elasticsearch and Kibana
	@echo "🛑 Stopping Elasticsearch and Kibana..."
	@$(DOCKER_COMPOSE) --profile admin down

.PHONY: restart
restart: down up ## Restart Elasticsearch

.PHONY: logs
logs: ## Show Elasticsearch logs
	@$(DOCKER_COMPOSE) logs -f elasticsearch

.PHONY: logs-kibana
logs-kibana: ## Show Kibana logs
	@$(DOCKER_COMPOSE) logs -f kibana

.PHONY: status
status: ## Check Elasticsearch status
	@docker compose ps

.PHONY: health
health: ## Check Elasticsearch health
	@curl -s http://localhost:$${ELASTICSEARCH_PORT:-9200}/_cluster/health?pretty

.PHONY: clean
clean: down ## Remove Elasticsearch data
	@echo "⚠️  Removing Elasticsearch data..."
	@docker volume rm elasticsearch-data 2>/dev/null || true
	@echo "✅ Elasticsearch data removed"

.PHONY: init
init: ## Create sample indices
	@echo "📝 Creating sample indices..."
	@curl -X PUT "localhost:$${ELASTICSEARCH_PORT:-9200}/logs" -H 'Content-Type: application/json' -d '{"settings":{"number_of_shards":1,"number_of_replicas":0}}' 2>/dev/null || true
	@curl -X PUT "localhost:$${ELASTICSEARCH_PORT:-9200}/metrics" -H 'Content-Type: application/json' -d '{"settings":{"number_of_shards":1,"number_of_replicas":0}}' 2>/dev/null || true
	@echo "✅ Sample indices created"

.PHONY: indices
indices: ## List all indices
	@curl -s http://localhost:$${ELASTICSEARCH_PORT:-9200}/_cat/indices?v

.PHONY: search
search: ## Search in all indices (use QUERY="search term")
	@curl -s "http://localhost:$${ELASTICSEARCH_PORT:-9200}/_search?q=$${QUERY}" | jq '.'

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