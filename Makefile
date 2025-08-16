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
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '^(up-all|down-all|status|urls|help|network|setup|ps)' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "Docker Maintenance:"
	@grep -E '^docker-[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "Backup & Health:"
	@grep -E '^(backup|restore|health)[a-zA-Z_-]*:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
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
	@$(MAKE) -C elasticsearch up
	@$(MAKE) -C minio up
	@echo "$(GREEN)✅ All services started!$(NC)"

.PHONY: up-all-admin
up-all-admin: network ## Start all services with admin UIs
	@echo "$(GREEN)Starting all services with admin UIs...$(NC)"
	@$(MAKE) -C mysql up-admin
	@$(MAKE) -C redis up-admin
	@$(MAKE) -C dynamodb up-admin
	@$(MAKE) -C mongodb up-admin
	@$(MAKE) -C kafka up-admin
	@$(MAKE) -C elasticsearch up-admin
	@$(MAKE) -C minio up
	@echo "$(GREEN)✅ All services with admin UIs started!$(NC)"

.PHONY: down-all
down-all: ## Stop all services
	@echo "$(YELLOW)Stopping all services...$(NC)"
	@$(MAKE) -C mysql down 2>/dev/null || true
	@$(MAKE) -C redis down 2>/dev/null || true
	@$(MAKE) -C dynamodb down 2>/dev/null || true
	@$(MAKE) -C mongodb down 2>/dev/null || true
	@$(MAKE) -C kafka down 2>/dev/null || true
	@$(MAKE) -C elasticsearch down 2>/dev/null || true
	@$(MAKE) -C minio down 2>/dev/null || true
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
	@echo ""
	@echo "Elasticsearch:"
	@$(MAKE) -C elasticsearch status 2>/dev/null || echo "  Not running"
	@echo ""
	@echo "MinIO:"
	@$(MAKE) -C minio status 2>/dev/null || echo "  Not running"

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
	@$(MAKE) -C elasticsearch clean 2>/dev/null || true
	@$(MAKE) -C minio clean 2>/dev/null || true
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
# Elasticsearch Commands
# ============================================
.PHONY: elasticsearch-up
elasticsearch-up: network ## Start Elasticsearch
	@$(MAKE) -C elasticsearch up

.PHONY: elasticsearch-up-admin
elasticsearch-up-admin: network ## Start Elasticsearch with Kibana
	@$(MAKE) -C elasticsearch up-admin

.PHONY: elasticsearch-down
elasticsearch-down: ## Stop Elasticsearch
	@$(MAKE) -C elasticsearch down

.PHONY: elasticsearch-logs
elasticsearch-logs: ## Show Elasticsearch logs
	@$(MAKE) -C elasticsearch logs

.PHONY: elasticsearch-indices
elasticsearch-indices: ## List Elasticsearch indices
	@$(MAKE) -C elasticsearch indices

# ============================================
# MinIO Commands
# ============================================
.PHONY: minio-up
minio-up: network ## Start MinIO
	@$(MAKE) -C minio up

.PHONY: minio-down
minio-down: ## Stop MinIO
	@$(MAKE) -C minio down

.PHONY: minio-logs
minio-logs: ## Show MinIO logs
	@$(MAKE) -C minio logs

.PHONY: minio-buckets
minio-buckets: ## List MinIO buckets
	@$(MAKE) -C minio buckets

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
	@if docker ps | grep -q local-elasticsearch; then \
		echo "$(YELLOW)Elasticsearch:$(NC)"; \
		echo "  Database: http://localhost:9200"; \
		if docker ps | grep -q local-kibana; then \
			echo "  Kibana: http://localhost:5601"; \
		fi; \
		echo ""; \
	fi
	@if docker ps | grep -q local-minio; then \
		echo "$(YELLOW)MinIO:$(NC)"; \
		echo "  API: http://localhost:9000"; \
		echo "  Console: http://localhost:9001"; \
		echo ""; \
	fi

# ============================================
# Backup and Restore Commands
# ============================================
.PHONY: backup
backup: ## Backup all service data
	@echo "$(GREEN)Starting backup process...$(NC)"
	@./scripts/backup.sh all
	@echo "$(GREEN)✅ Backup completed!$(NC)"

.PHONY: backup-service
backup-service: ## Backup specific service (use SERVICE=mysql|redis|mongodb|etc)
	@./scripts/backup.sh $(SERVICE)

.PHONY: restore
restore: ## Restore from backup (use BACKUP_DIR=backups/YYYYMMDD_HHMMSS)
	@if [ -z "$(BACKUP_DIR)" ]; then \
		echo "$(RED)Error: BACKUP_DIR is required$(NC)"; \
		echo "Usage: make restore BACKUP_DIR=backups/20240101_120000"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Starting restore process...$(NC)"
	@./scripts/restore.sh $(BACKUP_DIR) all
	@echo "$(GREEN)✅ Restore completed!$(NC)"

.PHONY: health
health: ## Show health check dashboard
	@./scripts/health-check.sh

.PHONY: health-json
health-json: ## Show health check in JSON format
	@./scripts/health-check.sh --json

.PHONY: ps
ps: status ## Alias for status

# ============================================
# Docker Maintenance & Troubleshooting
# ============================================
.PHONY: docker-clean
docker-clean: ## Clean up stopped containers and unused images
	@echo "$(YELLOW)Cleaning up Docker resources...$(NC)"
	@docker container prune -f
	@docker image prune -f
	@echo "$(GREEN)✅ Docker cleanup completed$(NC)"

.PHONY: docker-clean-all
docker-clean-all: ## Deep clean - remove all stopped containers, unused images, volumes, networks
	@echo "$(RED)WARNING: This will remove all unused Docker resources!$(NC)"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	@docker system prune -af --volumes
	@echo "$(GREEN)✅ Deep cleanup completed$(NC)"

.PHONY: docker-stats
docker-stats: ## Show real-time resource usage statistics
	@docker stats --format "table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

.PHONY: docker-disk
docker-disk: ## Show Docker disk usage
	@echo "$(YELLOW)Docker Disk Usage:$(NC)"
	@docker system df -v
	@echo ""
	@echo "$(YELLOW)Volume Sizes:$(NC)"
	@docker volume ls -q | xargs -I {} sh -c 'echo -n "{}: " && docker run --rm -v {}:/data alpine du -sh /data 2>/dev/null | cut -f1'

.PHONY: docker-logs-size
docker-logs-size: ## Show size of container logs
	@echo "$(YELLOW)Container Log Sizes:$(NC)"
	@for container in $$(docker ps -aq); do \
		name=$$(docker inspect -f '{{.Name}}' $$container | sed 's/\///'); \
		size=$$(docker inspect -f '{{.LogPath}}' $$container | xargs ls -lh 2>/dev/null | awk '{print $$5}'); \
		if [ -n "$$size" ]; then \
			echo "$$name: $$size"; \
		fi; \
	done

.PHONY: docker-clean-logs
docker-clean-logs: ## Clear all container logs
	@echo "$(YELLOW)Clearing container logs...$(NC)"
	@for container in $$(docker ps -aq); do \
		docker inspect -f '{{.LogPath}}' $$container | xargs truncate -s 0 2>/dev/null || true; \
	done
	@echo "$(GREEN)✅ Logs cleared$(NC)"

.PHONY: docker-remove-volumes
docker-remove-volumes: ## Remove all unused volumes
	@echo "$(YELLOW)Removing unused volumes...$(NC)"
	@docker volume prune -f
	@echo "$(GREEN)✅ Unused volumes removed$(NC)"

.PHONY: docker-remove-networks
docker-remove-networks: ## Remove all unused networks (except local-infra)
	@echo "$(YELLOW)Removing unused networks...$(NC)"
	@docker network prune -f
	@echo "$(GREEN)✅ Unused networks removed$(NC)"

.PHONY: docker-fix-space
docker-fix-space: ## Emergency space recovery - aggressive cleanup
	@echo "$(RED)🚨 Emergency Docker Space Recovery 🚨$(NC)"
	@echo "This will:"
	@echo "  1. Stop all our services"
	@echo "  2. Remove stopped containers"
	@echo "  3. Remove unused images"
	@echo "  4. Clear container logs"
	@echo "  5. Remove unused volumes and networks"
	@echo ""
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	@$(MAKE) down-all
	@docker container prune -f
	@docker image prune -af
	@for container in $$(docker ps -aq); do \
		docker inspect -f '{{.LogPath}}' $$container | xargs truncate -s 0 2>/dev/null || true; \
	done
	@docker volume prune -f
	@docker network prune -f
	@docker system prune -af --volumes
	@echo "$(GREEN)✅ Emergency cleanup completed!$(NC)"
	@docker system df

.PHONY: docker-inspect-size
docker-inspect-size: ## Show detailed size breakdown of Docker resources
	@echo "$(YELLOW)=== Docker Resource Usage ===$(NC)"
	@echo ""
	@echo "$(BLUE)Images:$(NC)"
	@docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | head -20
	@echo ""
	@echo "$(BLUE)Containers:$(NC)"
	@docker ps -as --format "table {{.Names}}\t{{.Status}}\t{{.Size}}"
	@echo ""
	@echo "$(BLUE)Volumes:$(NC)"
	@docker volume ls -q | while read vol; do \
		size=$$(docker run --rm -v $$vol:/data alpine du -sh /data 2>/dev/null | cut -f1); \
		echo "$$vol: $$size"; \
	done
	@echo ""
	@echo "$(BLUE)System Summary:$(NC)"
	@docker system df

.PHONY: docker-restart-daemon
docker-restart-daemon: ## Restart Docker daemon (requires sudo)
	@echo "$(YELLOW)Restarting Docker daemon...$(NC)"
	@if [ "$$(uname)" = "Darwin" ]; then \
		echo "Please restart Docker Desktop manually on macOS"; \
	elif [ "$$(uname)" = "Linux" ]; then \
		sudo systemctl restart docker; \
		echo "$(GREEN)✅ Docker daemon restarted$(NC)"; \
	else \
		echo "$(RED)Unsupported OS$(NC)"; \
	fi

.PHONY: docker-check
docker-check: ## Check Docker installation and resources
	@echo "$(YELLOW)Docker System Information:$(NC)"
	@docker version
	@echo ""
	@echo "$(YELLOW)Docker Info:$(NC)"
	@docker info 2>/dev/null | grep -E "Containers|Images|Server Version|Storage Driver|Memory|CPUs"
	@echo ""
	@echo "$(YELLOW)Disk Space:$(NC)"
	@df -h | grep -E "^/|Filesystem"
	@echo ""
	@$(MAKE) docker-disk

.PHONY: containers-restart
containers-restart: ## Restart all running containers
	@echo "$(YELLOW)Restarting all containers...$(NC)"
	@docker restart $$(docker ps -q) 2>/dev/null || echo "No containers to restart"
	@echo "$(GREEN)✅ Containers restarted$(NC)"

.PHONY: containers-stop-all
containers-stop-all: ## Stop ALL Docker containers (not just our services)
	@echo "$(RED)Stopping ALL Docker containers...$(NC)"
	@docker stop $$(docker ps -aq) 2>/dev/null || echo "No containers to stop"
	@echo "$(GREEN)✅ All containers stopped$(NC)"

.PHONY: fix-permissions
fix-permissions: ## Fix permission issues with volumes
	@echo "$(YELLOW)Fixing volume permissions...$(NC)"
	@for vol in mysql-data redis-data mongodb-data kafka-data elasticsearch-data minio-data; do \
		docker run --rm -v $$vol:/data alpine chown -R 1000:1000 /data 2>/dev/null || true; \
	done
	@echo "$(GREEN)✅ Permissions fixed$(NC)"

.PHONY: docker-pull-all
docker-pull-all: ## Update all service images to latest versions
	@echo "$(YELLOW)Pulling latest images...$(NC)"
	@docker compose -f mysql/docker-compose.yml pull
	@docker compose -f redis/docker-compose.yml pull
	@docker compose -f mongodb/docker-compose.yml pull
	@docker compose -f dynamodb/docker-compose.yml pull
	@docker compose -f kafka/docker-compose.yml pull
	@docker compose -f elasticsearch/docker-compose.yml pull
	@docker compose -f minio/docker-compose.yml pull
	@echo "$(GREEN)✅ All images updated$(NC)"

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