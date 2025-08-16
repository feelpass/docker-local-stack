# DynamoDB Local Infrastructure Makefile

# Use parent directory .env file
ENV_FILE := ../.env
DOCKER_COMPOSE := docker compose --env-file $(ENV_FILE)

.PHONY: up
up: network check-env ## Start DynamoDB Local
	@echo "🚀 Starting DynamoDB Local..."
	@$(DOCKER_COMPOSE) up -d dynamodb
	@echo "✅ DynamoDB is running on http://localhost:$${DYNAMODB_PORT:-8000}"

.PHONY: up-admin
up-admin: up ## Start DynamoDB with Admin UI
	@echo "🚀 Starting DynamoDB Admin..."
	@$(DOCKER_COMPOSE) --profile admin up -d
	@echo "✅ DynamoDB Admin is running on http://localhost:$${DYNAMODB_ADMIN_PORT:-8001}"

.PHONY: down
down: ## Stop DynamoDB
	@echo "🛑 Stopping DynamoDB..."
	@$(DOCKER_COMPOSE) --profile admin down

.PHONY: restart
restart: down up ## Restart DynamoDB

.PHONY: logs
logs: ## Show DynamoDB logs
	@$(DOCKER_COMPOSE) logs -f dynamodb

.PHONY: status
status: ## Check DynamoDB status
	@$(DOCKER_COMPOSE) ps

.PHONY: check-env
check-env: ## Check if parent .env exists
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "⚠️  Parent .env file not found. Run 'make setup' in parent directory."; \
		exit 1; \
	fi

.PHONY: clean
clean: down ## Remove DynamoDB data
	@echo "⚠️  DynamoDB Local runs in-memory, no data to clean"

.PHONY: init
init: ## Initialize DynamoDB tables
	@echo "📝 Initializing DynamoDB tables..."
	@./init.sh
	@echo "✅ DynamoDB initialized"

.PHONY: list-tables
list-tables: ## List all tables
	@aws dynamodb list-tables --endpoint-url http://localhost:8000 --region ap-northeast-2

.PHONY: scan
scan: ## Scan table (use TABLE=tablename)
	@aws dynamodb scan --table-name $(TABLE) --endpoint-url http://localhost:8000 --region ap-northeast-2

.PHONY: shell
shell: ## Open AWS CLI shell in container
	@docker run --rm -it --network local-infra \
		-e AWS_ACCESS_KEY_ID=local \
		-e AWS_SECRET_ACCESS_KEY=local \
		-e AWS_DEFAULT_REGION=ap-northeast-2 \
		amazon/aws-cli dynamodb list-tables --endpoint-url http://dynamodb:8000

.PHONY: network
network: ## Create docker network if not exists
	@docker network create local-infra 2>/dev/null || true

# ============================================
# AWS Profile Management
# ============================================
.PHONY: aws-profile
aws-profile: ## Switch AWS profile (use PROFILE=dev|staging|prod)
	@../aws/switch-profile.sh $(PROFILE)

.PHONY: aws-whoami
aws-whoami: ## Show current AWS profile and credentials
	@echo "Current AWS Profile: $${AWS_PROFILE:-default}"
	@echo "Region: $${AWS_REGION:-ap-northeast-2}"
	@echo "Access Key: $${AWS_ACCESS_KEY_ID:0:10}..."
	@aws sts get-caller-identity --endpoint-url http://localhost:8000 2>/dev/null || echo "DynamoDB Local (no real AWS connection)"

.PHONY: aws-test
aws-test: ## Test AWS credentials with DynamoDB
	@echo "Testing DynamoDB connection..."
	@aws dynamodb list-tables --endpoint-url http://localhost:8000 --region $${AWS_REGION:-ap-northeast-2} && echo "✅ Connection successful" || echo "❌ Connection failed"

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'