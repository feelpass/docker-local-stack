# Root Makefile for Docker Local Infrastructure
# Manages all services across subdirectories

# Color output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

# ============================================
# Help
# ============================================
.PHONY: help
help: ## Show this help message
	@echo "==============================================="
	@echo "Docker Local Infrastructure Management"
	@echo "==============================================="
	@echo ""
	@echo "Each service is in its own directory with independent docker-compose and Makefile"
	@echo ""
	@echo "Available Services:"
	@echo "  $(GREEN)mysql$(NC)      - MySQL database with phpMyAdmin"
	@echo "  $(GREEN)redis$(NC)      - Redis cache with Commander UI"
	@echo "  $(GREEN)dynamodb$(NC)   - DynamoDB Local with Admin UI"
	@echo "  $(GREEN)mongodb$(NC)    - MongoDB with Mongo Express"
	@echo "  $(GREEN)kafka$(NC)      - Kafka cluster with UI"
	@echo ""
	@echo "Global Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "Service Commands:"
	@echo "  make mysql-up      # Start MySQL"
	@echo "  make redis-up      # Start Redis"
	@echo "  make dynamodb-up   # Start DynamoDB"
	@echo "  make kafka-up      # Start Kafka"
	@echo "  make mongodb-up    # Start MongoDB"
	@echo ""
	@echo "Examples:"
	@echo "  make up-all        # Start all services"
	@echo "  make down-all      # Stop all services"
	@echo "  make mysql-up      # Start only MySQL"
	@echo "  make status        # Check all services status"

# ============================================
# Network Management
# ============================================
.PHONY: network
network: ## Create shared docker network
	@docker network create local-infra 2>/dev/null || true
	@echo "$(GREEN)✅ Network 'local-infra' ready$(NC)"

# ============================================
# Global Commands
# ============================================
.PHONY: up-all
up-all: network ## Start all services
	@echo "$(GREEN)Starting all services...$(NC)"
	@$(MAKE) -C mysql up
	@$(MAKE) -C redis up
	@$(MAKE) -C dynamodb up
	@$(MAKE) -C mongodb up
	@$(MAKE) -C kafka up
	@echo "$(GREEN)✅ All services started!$(NC)"

.PHONY: up-all-admin
up-all-admin: network ## Start all services with admin UIs
	@echo "$(GREEN)Starting all services with admin UIs...$(NC)"
	@$(MAKE) -C mysql up-admin
	@$(MAKE) -C redis up-admin
	@$(MAKE) -C dynamodb up-admin
	@$(MAKE) -C mongodb up-admin
	@$(MAKE) -C kafka up-admin
	@echo "$(GREEN)✅ All services with admin UIs started!$(NC)"

.PHONY: down-all
down-all: ## Stop all services
	@echo "$(YELLOW)Stopping all services...$(NC)"
	@$(MAKE) -C mysql down 2>/dev/null || true
	@$(MAKE) -C redis down 2>/dev/null || true
	@$(MAKE) -C dynamodb down 2>/dev/null || true
	@$(MAKE) -C mongodb down 2>/dev/null || true
	@$(MAKE) -C kafka down 2>/dev/null || true
	@echo "$(GREEN)✅ All services stopped!$(NC)"

.PHONY: status
status: ## Show status of all services
	@echo "$(GREEN)Service Status:$(NC)"
	@echo ""
	@echo "MySQL:"
	@$(MAKE) -C mysql status 2>/dev/null || echo "  Not running"
	@echo ""
	@echo "Redis:"
	@$(MAKE) -C redis status 2>/dev/null || echo "  Not running"
	@echo ""
	@echo "DynamoDB:"
	@$(MAKE) -C dynamodb status 2>/dev/null || echo "  Not running"
	@echo ""
	@echo "MongoDB:"
	@$(MAKE) -C mongodb status 2>/dev/null || echo "  Not running"
	@echo ""
	@echo "Kafka:"
	@$(MAKE) -C kafka status 2>/dev/null || echo "  Not running"

.PHONY: clean-all
clean-all: ## Remove all service data (WARNING!)
	@echo "$(RED)WARNING: This will delete all data!$(NC)"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	@$(MAKE) -C mysql clean 2>/dev/null || true
	@$(MAKE) -C redis clean 2>/dev/null || true
	@$(MAKE) -C dynamodb clean 2>/dev/null || true
	@$(MAKE) -C mongodb clean 2>/dev/null || true
	@$(MAKE) -C kafka clean 2>/dev/null || true
	@echo "$(GREEN)✅ All data removed!$(NC)"

# ============================================
# MySQL Commands
# ============================================
.PHONY: mysql-up
mysql-up: network ## Start MySQL
	@$(MAKE) -C mysql up

.PHONY: mysql-up-admin
mysql-up-admin: network ## Start MySQL with phpMyAdmin
	@$(MAKE) -C mysql up-admin

.PHONY: mysql-down
mysql-down: ## Stop MySQL
	@$(MAKE) -C mysql down

.PHONY: mysql-logs
mysql-logs: ## Show MySQL logs
	@$(MAKE) -C mysql logs

.PHONY: mysql-cli
mysql-cli: ## Connect to MySQL CLI
	@$(MAKE) -C mysql cli

# ============================================
# Redis Commands
# ============================================
.PHONY: redis-up
redis-up: network ## Start Redis
	@$(MAKE) -C redis up

.PHONY: redis-up-admin
redis-up-admin: network ## Start Redis with Commander
	@$(MAKE) -C redis up-admin

.PHONY: redis-down
redis-down: ## Stop Redis
	@$(MAKE) -C redis down

.PHONY: redis-logs
redis-logs: ## Show Redis logs
	@$(MAKE) -C redis logs

.PHONY: redis-cli
redis-cli: ## Connect to Redis CLI
	@$(MAKE) -C redis cli

# ============================================
# DynamoDB Commands
# ============================================
.PHONY: dynamodb-up
dynamodb-up: network ## Start DynamoDB
	@$(MAKE) -C dynamodb up

.PHONY: dynamodb-up-admin
dynamodb-up-admin: network ## Start DynamoDB with Admin UI
	@$(MAKE) -C dynamodb up-admin

.PHONY: dynamodb-down
dynamodb-down: ## Stop DynamoDB
	@$(MAKE) -C dynamodb down

.PHONY: dynamodb-logs
dynamodb-logs: ## Show DynamoDB logs
	@$(MAKE) -C dynamodb logs

.PHONY: dynamodb-init
dynamodb-init: ## Initialize DynamoDB tables
	@$(MAKE) -C dynamodb init

# ============================================
# MongoDB Commands
# ============================================
.PHONY: mongodb-up
mongodb-up: network ## Start MongoDB
	@$(MAKE) -C mongodb up

.PHONY: mongodb-up-admin
mongodb-up-admin: network ## Start MongoDB with Mongo Express
	@$(MAKE) -C mongodb up-admin

.PHONY: mongodb-down
mongodb-down: ## Stop MongoDB
	@$(MAKE) -C mongodb down

.PHONY: mongodb-logs
mongodb-logs: ## Show MongoDB logs
	@$(MAKE) -C mongodb logs

.PHONY: mongodb-cli
mongodb-cli: ## Connect to MongoDB CLI
	@$(MAKE) -C mongodb cli

# ============================================
# Kafka Commands
# ============================================
.PHONY: kafka-up
kafka-up: network ## Start Kafka cluster
	@$(MAKE) -C kafka up

.PHONY: kafka-up-admin
kafka-up-admin: network ## Start Kafka with UI
	@$(MAKE) -C kafka up-admin

.PHONY: kafka-down
kafka-down: ## Stop Kafka cluster
	@$(MAKE) -C kafka down

.PHONY: kafka-logs
kafka-logs: ## Show Kafka logs
	@$(MAKE) -C kafka logs

.PHONY: kafka-topics
kafka-topics: ## List Kafka topics
	@$(MAKE) -C kafka topics

# ============================================
# Development Presets
# ============================================
.PHONY: dev
dev: network ## Start common dev services (MySQL, Redis, DynamoDB)
	@echo "$(GREEN)Starting development environment...$(NC)"
	@$(MAKE) -C mysql up
	@$(MAKE) -C redis up
	@$(MAKE) -C dynamodb up
	@echo "$(GREEN)✅ Development environment ready!$(NC)"
	@make urls

.PHONY: dev-full
dev-full: network ## Start all services with admin UIs
	@echo "$(GREEN)Starting full development environment...$(NC)"
	@$(MAKE) up-all-admin
	@echo "$(GREEN)✅ Full development environment ready!$(NC)"
	@make urls

# ============================================
# Utility Commands
# ============================================
.PHONY: urls
urls: ## Show all service URLs
	@echo "$(GREEN)Service URLs:$(NC)"
	@echo ""
	@if docker ps | grep -q local-mysql; then \
		echo "$(YELLOW)MySQL:$(NC)"; \
		echo "  Database: localhost:3306"; \
		if docker ps | grep -q local-phpmyadmin; then \
			echo "  phpMyAdmin: http://localhost:8082"; \
		fi; \
		echo ""; \
	fi
	@if docker ps | grep -q local-redis; then \
		echo "$(YELLOW)Redis:$(NC)"; \
		echo "  Database: localhost:6379"; \
		if docker ps | grep -q local-redis-commander; then \
			echo "  Commander: http://localhost:8081"; \
		fi; \
		echo ""; \
	fi
	@if docker ps | grep -q local-dynamodb; then \
		echo "$(YELLOW)DynamoDB:$(NC)"; \
		echo "  Database: http://localhost:8000"; \
		if docker ps | grep -q local-dynamodb-admin; then \
			echo "  Admin UI: http://localhost:8001"; \
		fi; \
		echo ""; \
	fi
	@if docker ps | grep -q local-mongodb; then \
		echo "$(YELLOW)MongoDB:$(NC)"; \
		echo "  Database: localhost:27017"; \
		if docker ps | grep -q local-mongo-express; then \
			echo "  Mongo Express: http://localhost:8083"; \
		fi; \
		echo ""; \
	fi
	@if docker ps | grep -q local-kafka; then \
		echo "$(YELLOW)Kafka:$(NC)"; \
		echo "  Broker: localhost:9092"; \
		echo "  Zookeeper: localhost:2181"; \
		if docker ps | grep -q local-kafka-ui; then \
			echo "  Kafka UI: http://localhost:8080"; \
		fi; \
		echo ""; \
	fi

.PHONY: ps
ps: status ## Alias for status

# ============================================
# AWS Profile Management
# ============================================
.PHONY: aws-profile
aws-profile: ## Switch AWS profile (use PROFILE=dev|staging|prod)
	@./aws/switch-profile.sh $(PROFILE)

.PHONY: aws-profiles
aws-profiles: ## List available AWS profiles
	@echo "$(GREEN)Available AWS Profiles:$(NC)"
	@echo "  - default (local/testing)"
	@echo "  - dev"
	@echo "  - staging"
	@echo "  - prod"
	@echo ""
	@echo "Current Profile: $${AWS_PROFILE:-default}"

.PHONY: aws-whoami
aws-whoami: ## Show current AWS profile
	@echo "$(GREEN)Current AWS Configuration:$(NC)"
	@echo "  Profile: $${AWS_PROFILE:-default}"
	@echo "  Region: $${AWS_REGION:-ap-northeast-2}"
	@echo "  Access Key: $${AWS_ACCESS_KEY_ID:0:10}..."

.PHONY: aws-test
aws-test: ## Test AWS credentials
	@echo "$(YELLOW)Testing AWS credentials...$(NC)"
	@if docker ps | grep -q local-dynamodb; then \
		aws dynamodb list-tables --endpoint-url http://localhost:8000 --region $${AWS_REGION:-ap-northeast-2} && \
		echo "$(GREEN)✅ DynamoDB Local connection successful$(NC)" || \
		echo "$(RED)❌ DynamoDB Local connection failed$(NC)"; \
	else \
		echo "$(YELLOW)DynamoDB Local is not running. Start it with: make dynamodb-up$(NC)"; \
	fi

.PHONY: aws-config
aws-config: ## Edit AWS profile configuration
	@echo "$(YELLOW)Opening .env file for AWS configuration...$(NC)"
	@$${EDITOR:-nano} .env

# ============================================
# Environment Setup
# ============================================
.PHONY: setup
setup: ## Initial setup - copy env files
	@echo "$(GREEN)Setting up environment files...$(NC)"
	@cp -n .env.example .env 2>/dev/null || echo "$(YELLOW).env file already exists$(NC)"
	@for dir in mysql redis dynamodb mongodb kafka; do \
		if [ -f $$dir/.env.example ]; then \
			cp -n $$dir/.env.example $$dir/.env 2>/dev/null || echo "$(YELLOW)$$dir/.env already exists$(NC)"; \
		fi; \
	done
	@echo "$(GREEN)✅ Environment files ready!$(NC)"
	@echo "$(YELLOW)Edit .env files to customize settings$(NC)"