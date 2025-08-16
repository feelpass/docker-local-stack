#!/bin/bash

# Docker Infrastructure Backup Script
# Usage: ./backup.sh [service|all]

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get current date for backup directory
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/${DATE}"

# Create backup directory
mkdir -p "${BACKUP_DIR}"

echo -e "${YELLOW}Starting backup process...${NC}"
echo -e "Backup directory: ${BACKUP_DIR}"

# Function to backup MySQL
backup_mysql() {
    if docker ps | grep -q local-mysql; then
        echo -e "${YELLOW}Backing up MySQL...${NC}"
        docker exec local-mysql mysqldump -uroot -proot --all-databases > "${BACKUP_DIR}/mysql_all_databases.sql"
        echo -e "${GREEN}✅ MySQL backup completed${NC}"
    else
        echo -e "${RED}⚠️  MySQL is not running${NC}"
    fi
}

# Function to backup MongoDB
backup_mongodb() {
    if docker ps | grep -q local-mongodb; then
        echo -e "${YELLOW}Backing up MongoDB...${NC}"
        docker exec local-mongodb mongodump --uri="mongodb://root:root123@localhost:27017" --archive > "${BACKUP_DIR}/mongodb_all.archive"
        echo -e "${GREEN}✅ MongoDB backup completed${NC}"
    else
        echo -e "${RED}⚠️  MongoDB is not running${NC}"
    fi
}

# Function to backup Redis
backup_redis() {
    if docker ps | grep -q local-redis; then
        echo -e "${YELLOW}Backing up Redis...${NC}"
        docker exec local-redis redis-cli BGSAVE
        sleep 2
        docker cp local-redis:/data/dump.rdb "${BACKUP_DIR}/redis_dump.rdb"
        echo -e "${GREEN}✅ Redis backup completed${NC}"
    else
        echo -e "${RED}⚠️  Redis is not running${NC}"
    fi
}

# Function to backup DynamoDB
backup_dynamodb() {
    if docker ps | grep -q local-dynamodb; then
        echo -e "${YELLOW}Backing up DynamoDB tables...${NC}"
        # List all tables and backup each one
        tables=$(aws dynamodb list-tables --endpoint-url http://localhost:8000 --output json | jq -r '.TableNames[]' 2>/dev/null || echo "")
        if [ -n "$tables" ]; then
            mkdir -p "${BACKUP_DIR}/dynamodb"
            for table in $tables; do
                echo "  Backing up table: $table"
                aws dynamodb scan --table-name "$table" --endpoint-url http://localhost:8000 --output json > "${BACKUP_DIR}/dynamodb/${table}.json"
            done
            echo -e "${GREEN}✅ DynamoDB backup completed${NC}"
        else
            echo -e "${YELLOW}No DynamoDB tables to backup${NC}"
        fi
    else
        echo -e "${RED}⚠️  DynamoDB is not running${NC}"
    fi
}

# Function to backup Elasticsearch
backup_elasticsearch() {
    if docker ps | grep -q local-elasticsearch; then
        echo -e "${YELLOW}Backing up Elasticsearch indices...${NC}"
        mkdir -p "${BACKUP_DIR}/elasticsearch"
        # Get all indices
        indices=$(curl -s http://localhost:9200/_cat/indices?h=index | grep -v "^\.")
        for index in $indices; do
            echo "  Backing up index: $index"
            elasticdump --input=http://localhost:9200/${index} --output="${BACKUP_DIR}/elasticsearch/${index}.json" 2>/dev/null || \
                curl -s "http://localhost:9200/${index}/_search?size=10000" > "${BACKUP_DIR}/elasticsearch/${index}.json"
        done
        echo -e "${GREEN}✅ Elasticsearch backup completed${NC}"
    else
        echo -e "${RED}⚠️  Elasticsearch is not running${NC}"
    fi
}

# Function to backup MinIO
backup_minio() {
    if docker ps | grep -q local-minio; then
        echo -e "${YELLOW}Backing up MinIO buckets...${NC}"
        mkdir -p "${BACKUP_DIR}/minio"
        docker exec local-minio sh -c 'mc alias set local http://localhost:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD && mc mirror local/ /tmp/minio-backup/' 2>/dev/null
        docker cp local-minio:/tmp/minio-backup "${BACKUP_DIR}/minio/"
        echo -e "${GREEN}✅ MinIO backup completed${NC}"
    else
        echo -e "${RED}⚠️  MinIO is not running${NC}"
    fi
}

# Main backup logic
SERVICE=${1:-all}

case $SERVICE in
    mysql)
        backup_mysql
        ;;
    mongodb)
        backup_mongodb
        ;;
    redis)
        backup_redis
        ;;
    dynamodb)
        backup_dynamodb
        ;;
    elasticsearch)
        backup_elasticsearch
        ;;
    minio)
        backup_minio
        ;;
    all)
        backup_mysql
        backup_mongodb
        backup_redis
        backup_dynamodb
        backup_elasticsearch
        backup_minio
        ;;
    *)
        echo -e "${RED}Unknown service: $SERVICE${NC}"
        echo "Usage: $0 [mysql|mongodb|redis|dynamodb|elasticsearch|minio|all]"
        exit 1
        ;;
esac

# Create metadata file
cat > "${BACKUP_DIR}/backup_info.txt" << EOF
Backup Date: $(date)
Services Backed Up: $SERVICE
Backup Directory: ${BACKUP_DIR}
EOF

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Backup completed successfully!${NC}"
echo -e "${GREEN}Location: ${BACKUP_DIR}${NC}"
echo -e "${GREEN}========================================${NC}"

# Compress backup if requested
if [ "$2" == "--compress" ]; then
    echo -e "${YELLOW}Compressing backup...${NC}"
    tar -czf "backups/backup_${DATE}.tar.gz" -C backups "${DATE}"
    rm -rf "${BACKUP_DIR}"
    echo -e "${GREEN}✅ Backup compressed to backups/backup_${DATE}.tar.gz${NC}"
fi