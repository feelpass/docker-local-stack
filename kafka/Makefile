# Kafka Local Infrastructure Makefile

# Use parent directory .env file
ENV_FILE := ../.env
DOCKER_COMPOSE := docker compose --env-file $(ENV_FILE)

.PHONY: up
up: network check-env ## Start Kafka cluster
	@echo "🚀 Starting Zookeeper and Kafka..."
	@$(DOCKER_COMPOSE) up -d zookeeper kafka
	@echo "✅ Kafka is running on port $${KAFKA_PORT:-9092}"

.PHONY: up-admin
up-admin: up ## Start Kafka with UI
	@echo "🚀 Starting Kafka UI..."
	@$(DOCKER_COMPOSE) --profile admin up -d
	@echo "✅ Kafka UI is running on http://localhost:$${KAFKA_UI_PORT:-8080}"

.PHONY: down
down: ## Stop Kafka cluster
	@echo "🛑 Stopping Kafka cluster..."
	@$(DOCKER_COMPOSE) --profile admin down

.PHONY: restart
restart: down up ## Restart Kafka cluster

.PHONY: logs
logs: ## Show Kafka logs
	@$(DOCKER_COMPOSE) logs -f kafka

.PHONY: logs-zk
logs-zk: ## Show Zookeeper logs
	@$(DOCKER_COMPOSE) logs -f zookeeper

.PHONY: status
status: ## Check Kafka status
	@docker compose ps

.PHONY: clean
clean: down ## Remove Kafka data
	@echo "⚠️  Removing Kafka data..."
	@docker volume rm kafka-data zookeeper-data zookeeper-logs 2>/dev/null || true
	@echo "✅ Kafka data removed"

.PHONY: init
init: ## Create sample topics
	@echo "📝 Creating Kafka topics..."
	@docker exec -it local-kafka kafka-topics --create --topic test-topic --bootstrap-server localhost:29092 --partitions 3 --replication-factor 1 2>/dev/null || true
	@docker exec -it local-kafka kafka-topics --create --topic events --bootstrap-server localhost:29092 --partitions 3 --replication-factor 1 2>/dev/null || true
	@docker exec -it local-kafka kafka-topics --list --bootstrap-server localhost:29092
	@echo "✅ Topics created"

.PHONY: topics
topics: ## List all topics
	@docker exec -it local-kafka kafka-topics --list --bootstrap-server localhost:29092

.PHONY: create-topic
create-topic: ## Create a topic (use TOPIC=name PARTITIONS=3)
	@docker exec -it local-kafka kafka-topics --create --topic $(TOPIC) --bootstrap-server localhost:29092 --partitions $(PARTITIONS) --replication-factor 1

.PHONY: delete-topic
delete-topic: ## Delete a topic (use TOPIC=name)
	@docker exec -it local-kafka kafka-topics --delete --topic $(TOPIC) --bootstrap-server localhost:29092

.PHONY: produce
produce: ## Start console producer (use TOPIC=name)
	@docker exec -it local-kafka kafka-console-producer --topic $(TOPIC) --bootstrap-server localhost:29092

.PHONY: consume
consume: ## Start console consumer (use TOPIC=name)
	@docker exec -it local-kafka kafka-console-consumer --topic $(TOPIC) --from-beginning --bootstrap-server localhost:29092

.PHONY: shell
shell: ## Open Kafka container shell
	@docker exec -it local-kafka /bin/bash

.PHONY: network
network: ## Create docker network if not exists
	@docker network create local-infra 2>/dev/null || true

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'