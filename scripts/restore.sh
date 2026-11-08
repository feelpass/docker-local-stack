#!/bin/bash

# Docker Infrastructure Restore Script
# Usage: ./restore.sh <backup_directory> [service|all]

set -e

# DynamoDB Local용 가짜 자격 (실계정 자격 불필요)
export AWS_ACCESS_KEY_ID=local AWS_SECRET_ACCESS_KEY=local AWS_DEFAULT_REGION=ap-northeast-2

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Backup directory required${NC}"
    echo "Usage: $0 <backup_directory> [service|all]"
    echo "Example: $0 backups/20240101_120000 all"
    exit 1
fi

BACKUP_DIR="$1"
SERVICE=${2:-all}

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}Error: Backup directory not found: $BACKUP_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}Starting restore process...${NC}"
echo -e "Restore from: ${BACKUP_DIR}"

# Function to restore MySQL
restore_mysql() {
    if [ -f "${BACKUP_DIR}/mysql_all_databases.sql" ]; then
        if docker ps | grep -q local-mysql; then
            echo -e "${YELLOW}Restoring MySQL...${NC}"
            docker exec -i local-mysql mysql -uroot -proot < "${BACKUP_DIR}/mysql_all_databases.sql"
            echo -e "${GREEN}✅ MySQL restore completed${NC}"
        else
            echo -e "${RED}⚠️  MySQL is not running. Start it first with: make mysql-up${NC}"
        fi
    else
        echo -e "${YELLOW}No MySQL backup found${NC}"
    fi
}

# Function to restore MongoDB
restore_mongodb() {
    if [ -f "${BACKUP_DIR}/mongodb_all.archive" ]; then
        if docker ps | grep -q local-mongodb; then
            echo -e "${YELLOW}Restoring MongoDB...${NC}"
            docker exec -i local-mongodb mongorestore --uri="mongodb://root:root123@localhost:27017" --archive < "${BACKUP_DIR}/mongodb_all.archive"
            echo -e "${GREEN}✅ MongoDB restore completed${NC}"
        else
            echo -e "${RED}⚠️  MongoDB is not running. Start it first with: make mongodb-up${NC}"
        fi
    else
        echo -e "${YELLOW}No MongoDB backup found${NC}"
    fi
}

# Function to restore Redis
restore_redis() {
    if [ -f "${BACKUP_DIR}/redis_dump.rdb" ]; then
        if docker ps | grep -q local-redis; then
            echo -e "${YELLOW}Restoring Redis...${NC}"
            docker cp "${BACKUP_DIR}/redis_dump.rdb" local-redis:/data/dump.rdb
            docker exec local-redis redis-cli SHUTDOWN NOSAVE
            sleep 2
            docker start local-redis
            echo -e "${GREEN}✅ Redis restore completed${NC}"
        else
            echo -e "${RED}⚠️  Redis is not running. Start it first with: make redis-up${NC}"
        fi
    else
        echo -e "${YELLOW}No Redis backup found${NC}"
    fi
}

# Function to restore DynamoDB
restore_dynamodb() {
    if [ -d "${BACKUP_DIR}/dynamodb" ]; then
        if docker ps | grep -q local-dynamodb; then
            echo -e "${YELLOW}Restoring DynamoDB tables...${NC}"
            for file in "${BACKUP_DIR}"/dynamodb/*.json; do
                if [ -f "$file" ]; then
                    table=$(basename "$file" .json)
                    echo "  Restoring table: $table"
                    
                    # Extract table schema from backup (simplified - may need adjustment)
                    aws dynamodb create-table \
                        --table-name "$table" \
                        --attribute-definitions AttributeName=id,AttributeType=S \
                        --key-schema AttributeName=id,KeyType=HASH \
                        --billing-mode PAY_PER_REQUEST \
                        --endpoint-url http://localhost:8000 2>/dev/null || true
                    
                    # Restore items
                    jq -c '.Items[]' "$file" | while read -r item; do
                        aws dynamodb put-item --table-name "$table" --item "$item" --endpoint-url http://localhost:8000
                    done
                fi
            done
            echo -e "${GREEN}✅ DynamoDB restore completed${NC}"
        else
            echo -e "${RED}⚠️  DynamoDB is not running. Start it first with: make dynamodb-up${NC}"
        fi
    else
        echo -e "${YELLOW}No DynamoDB backup found${NC}"
    fi
}

# Function to restore Elasticsearch
restore_elasticsearch() {
    if [ -d "${BACKUP_DIR}/elasticsearch" ]; then
        if docker ps | grep -q local-elasticsearch; then
            echo -e "${YELLOW}Restoring Elasticsearch indices...${NC}"
            for file in "${BACKUP_DIR}"/elasticsearch/*.json; do
                if [ -f "$file" ]; then
                    index=$(basename "$file" .json)
                    echo "  Restoring index: $index"
                    
                    # Delete existing index if exists
                    curl -X DELETE "http://localhost:9200/${index}" 2>/dev/null || true
                    
                    # Restore data
                    if command -v elasticdump &> /dev/null; then
                        elasticdump --input="$file" --output="http://localhost:9200/${index}"
                    else
                        # Simple restore using curl (may need adjustment based on data format)
                        curl -X POST "http://localhost:9200/${index}/_bulk" -H "Content-Type: application/json" --data-binary "@$file"
                    fi
                fi
            done
            echo -e "${GREEN}✅ Elasticsearch restore completed${NC}"
        else
            echo -e "${RED}⚠️  Elasticsearch is not running. Start it first with: make elasticsearch-up${NC}"
        fi
    else
        echo -e "${YELLOW}No Elasticsearch backup found${NC}"
    fi
}

# Function to restore MinIO
restore_minio() {
    if [ -d "${BACKUP_DIR}/minio" ]; then
        if docker ps | grep -q local-minio; then
            echo -e "${YELLOW}Restoring MinIO buckets...${NC}"
            docker cp "${BACKUP_DIR}/minio/." local-minio:/tmp/minio-restore/
            docker exec local-minio sh -c 'mc alias set local http://localhost:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD && mc mirror /tmp/minio-restore/ local/'
            echo -e "${GREEN}✅ MinIO restore completed${NC}"
        else
            echo -e "${RED}⚠️  MinIO is not running. Start it first with: make minio-up${NC}"
        fi
    else
        echo -e "${YELLOW}No MinIO backup found${NC}"
    fi
}

# Main restore logic
case $SERVICE in
    mysql)
        restore_mysql
        ;;
    mongodb)
        restore_mongodb
        ;;
    redis)
        restore_redis
        ;;
    dynamodb)
        restore_dynamodb
        ;;
    elasticsearch)
        restore_elasticsearch
        ;;
    minio)
        restore_minio
        ;;
    all)
        restore_mysql
        restore_mongodb
        restore_redis
        restore_dynamodb
        restore_elasticsearch
        restore_minio
        ;;
    *)
        echo -e "${RED}Unknown service: $SERVICE${NC}"
        echo "Usage: $0 <backup_directory> [mysql|mongodb|redis|dynamodb|elasticsearch|minio|all]"
        exit 1
        ;;
esac

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Restore completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"