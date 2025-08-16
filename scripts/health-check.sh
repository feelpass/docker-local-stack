#!/bin/bash

# Docker Infrastructure Health Check Dashboard
# Usage: ./health-check.sh [--json]

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if JSON output is requested
JSON_OUTPUT=false
if [ "$1" == "--json" ]; then
    JSON_OUTPUT=true
fi

# Function to check service health
check_service() {
    local service_name=$1
    local container_name=$2
    local port=$3
    local check_command=$4
    
    if docker ps | grep -q "$container_name"; then
        # Check if container is healthy
        health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "none")
        
        # Additional port check
        if [ -n "$port" ]; then
            if nc -z localhost "$port" 2>/dev/null; then
                status="running"
            else
                status="unhealthy"
            fi
        else
            status="running"
        fi
        
        # Override with health check status if available
        if [ "$health_status" == "healthy" ]; then
            status="healthy"
        elif [ "$health_status" == "unhealthy" ]; then
            status="unhealthy"
        fi
        
        echo "$status"
    else
        echo "stopped"
    fi
}

# Function to get container stats
get_container_stats() {
    local container_name=$1
    if docker ps | grep -q "$container_name"; then
        docker stats --no-stream --format "{{json .}}" "$container_name" 2>/dev/null || echo "{}"
    else
        echo "{}"
    fi
}

# Collect health data using individual variables instead of associative array
mysql_status=$(check_service "MySQL" "local-mysql" "3306")
redis_status=$(check_service "Redis" "local-redis" "6379")
mongodb_status=$(check_service "MongoDB" "local-mongodb" "27017")
dynamodb_status=$(check_service "DynamoDB" "local-dynamodb" "8000")
kafka_status=$(check_service "Kafka" "local-kafka" "9092")
zookeeper_status=$(check_service "Zookeeper" "local-zookeeper" "2181")
elasticsearch_status=$(check_service "Elasticsearch" "local-elasticsearch" "9200")
kibana_status=$(check_service "Kibana" "local-kibana" "5601")
minio_status=$(check_service "MinIO" "local-minio" "9000")

# Count statistics
total=9
running=0
healthy=0
unhealthy=0
stopped=0

# Count each service status
for status in $mysql_status $redis_status $mongodb_status $dynamodb_status $kafka_status $zookeeper_status $elasticsearch_status $kibana_status $minio_status; do
    case $status in
        "healthy")
            healthy=$((healthy + 1))
            running=$((running + 1))
            ;;
        "running")
            running=$((running + 1))
            ;;
        "unhealthy")
            unhealthy=$((unhealthy + 1))
            running=$((running + 1))
            ;;
        "stopped")
            stopped=$((stopped + 1))
            ;;
    esac
done

if [ "$JSON_OUTPUT" == "true" ]; then
    # JSON output
    echo "{"
    echo "  \"timestamp\": \"$(date -Iseconds)\","
    echo "  \"summary\": {"
    echo "    \"total\": $total,"
    echo "    \"running\": $running,"
    echo "    \"healthy\": $healthy,"
    echo "    \"unhealthy\": $unhealthy,"
    echo "    \"stopped\": $stopped"
    echo "  },"
    echo "  \"services\": {"
    echo "    \"MySQL\": \"$mysql_status\","
    echo "    \"Redis\": \"$redis_status\","
    echo "    \"MongoDB\": \"$mongodb_status\","
    echo "    \"DynamoDB\": \"$dynamodb_status\","
    echo "    \"Kafka\": \"$kafka_status\","
    echo "    \"Zookeeper\": \"$zookeeper_status\","
    echo "    \"Elasticsearch\": \"$elasticsearch_status\","
    echo "    \"Kibana\": \"$kibana_status\","
    echo "    \"MinIO\": \"$minio_status\""
    echo "  }"
    echo "}"
else
    # Terminal output with colors
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          Docker Infrastructure Health Dashboard              ║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC} Last Update: $(date '+%Y-%m-%d %H:%M:%S')                     ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${BLUE}📊 Summary${NC}"
    echo -e "├─ Total Services: $total"
    echo -e "├─ Running: ${GREEN}$running${NC}"
    echo -e "├─ Healthy: ${GREEN}$healthy${NC}"
    echo -e "├─ Unhealthy: ${YELLOW}$unhealthy${NC}"
    echo -e "└─ Stopped: ${RED}$stopped${NC}"
    echo ""
    
    echo -e "${BLUE}🔍 Service Status${NC}"
    echo -e "┌──────────────────┬──────────────┬──────────┐"
    echo -e "│ Service          │ Status       │ Port     │"
    echo -e "├──────────────────┼──────────────┼──────────┤"
    
    # Service details with status and ports
    for service in MySQL Redis MongoDB DynamoDB Kafka Zookeeper Elasticsearch Kibana MinIO; do
        # Get status for each service
        case $service in
            "MySQL")
                status=$mysql_status
                port="3306"
                ;;
            "Redis")
                status=$redis_status
                port="6379"
                ;;
            "MongoDB")
                status=$mongodb_status
                port="27017"
                ;;
            "DynamoDB")
                status=$dynamodb_status
                port="8000"
                ;;
            "Kafka")
                status=$kafka_status
                port="9092"
                ;;
            "Zookeeper")
                status=$zookeeper_status
                port="2181"
                ;;
            "Elasticsearch")
                status=$elasticsearch_status
                port="9200"
                ;;
            "Kibana")
                status=$kibana_status
                port="5601"
                ;;
            "MinIO")
                status=$minio_status
                port="9000"
                ;;
        esac
        
        # Format service name
        printf "│ %-16s │ " "$service"
        
        # Format status with color
        case $status in
            "healthy")
                printf "${GREEN}%-12s${NC} │ " "● Healthy"
                ;;
            "running")
                printf "${GREEN}%-12s${NC} │ " "● Running"
                ;;
            "unhealthy")
                printf "${YELLOW}%-12s${NC} │ " "● Unhealthy"
                ;;
            "stopped")
                printf "${RED}%-12s${NC} │ " "○ Stopped"
                ;;
        esac
        
        # Format port
        printf "%-8s │\n" "$port"
    done
    
    echo -e "└──────────────────┴──────────────┴──────────┘"
    echo ""
    
    echo -e "${BLUE}🔗 Service URLs${NC}"
    echo -e "├─ MySQL:          localhost:3306"
    echo -e "├─ phpMyAdmin:     http://localhost:8082"
    echo -e "├─ Redis:          localhost:6379"
    echo -e "├─ Redis Commander: http://localhost:8081"
    echo -e "├─ MongoDB:        localhost:27017"
    echo -e "├─ Mongo Express:  http://localhost:8083"
    echo -e "├─ DynamoDB:       http://localhost:8000"
    echo -e "├─ DynamoDB Admin: http://localhost:8001"
    echo -e "├─ Kafka:          localhost:9092"
    echo -e "├─ Kafka UI:       http://localhost:8080"
    echo -e "├─ Elasticsearch:  http://localhost:9200"
    echo -e "├─ Kibana:         http://localhost:5601"
    echo -e "├─ MinIO API:      http://localhost:9000"
    echo -e "└─ MinIO Console:  http://localhost:9001"
    echo ""
    
    echo -e "${BLUE}💡 Quick Commands${NC}"
    echo -e "├─ Start all:      make up-all"
    echo -e "├─ Stop all:       make down-all"
    echo -e "├─ View logs:      make [service]-logs"
    echo -e "├─ Backup all:     ./scripts/backup.sh all"
    echo -e "└─ Health (JSON):  ./scripts/health-check.sh --json"
fi